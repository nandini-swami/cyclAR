//
//  NavigationViewModel.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
//
import SwiftUI
import CoreLocation

final class NavigationViewModel: ObservableObject {
    @Published var origin = "Houston Hall, Philadelphia"
    @Published var destination = "Penn Museum, Philadelphia"
    @Published var steps: [DirectionStep] = []
    @Published var errorMsg: String?
    @Published var demoMode = false
    @Published var currentStepIndex = 0
    @Published var isSimulating = false
    @Published var liveDisplayStep: DirectionStep?
    
    // Search autocomplete variables
    @Published var destinationSuggestions: [PlaceSuggestion] = []
    @Published var selectedDestinationAddress: String?
    @Published var selectedDestinationPlaceID: String?

    private var destinationSessionToken = UUID().uuidString
    private var autocompleteWorkItem: DispatchWorkItem?
    
    let ble = BLEManager.shared
    let loc = LocationManager()

    var navTimer: Timer?
    var demoTimer: Timer?

    // MARK: - Preview Route (Text Origin + Destination)
    func previewRoute() {
        NavService.instance.getBikeDirections(origin: origin,
                                            destination: destination) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newSteps):
                    self.errorMsg = nil
                    self.steps = newSteps
                case .failure(let e):
                    self.errorMsg = e.localizedDescription
                }
            }
        }
    }

    // MARK: - Live Navigation (GPS → Destination)
    func startLiveNavigation() {
        navTimer?.invalidate()

        navTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            guard let current = self.loc.current else {
                DispatchQueue.main.async {
                    self.errorMsg = "Waiting for GPS..."
                }
                return
            }

            NavService.instance.getBikeDirections(origin: current,
                                                destination: self.destination) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let newSteps):
                        self.errorMsg = nil
                            self.steps = newSteps
                            self.liveDisplayStep = newSteps.first
                            
                            if let stepToDisplay = self.liveDisplayStep {
                                self.sendStepOverBLE(stepToDisplay)
                            }

                            print("LIVE NAV UPDATE")
                            for (idx, step) in newSteps.enumerated() {
                                print("[\(idx)] \(step.simple) | \(step.streetName) | \(step.distanceText)")
                            }

                            if let stepToDisplay = self.liveDisplayStep {
                                print("DISPLAY PREVIEW -> \(stepToDisplay.simple) | \(stepToDisplay.distanceText) | \(stepToDisplay.streetName)")
                            }
                    case .failure(let e):
                        self.errorMsg = e.localizedDescription
                    }
                }
            }
        }
    }

    func stopLiveNavigation() {
        navTimer?.invalidate()
            navTimer = nil
            liveDisplayStep = nil
    }

    // MARK: - Manual Send Functions
    func sendLeft() {
        ble.sendNavUpdate(street: "", arrow: "←", distance: "")
    }

    func sendRight() {
        ble.sendNavUpdate(street: "", arrow: "→", distance: "")
    }

    func sendUp() {
        ble.sendNavUpdate(street: "", arrow: "↑", distance: "")
    }

    // MARK: - Simulation Logic
    func startSimulation() {
        guard !steps.isEmpty else { return }

        print("Starting Simulation...")
        isSimulating = true
        currentStepIndex = 0

        // 1. Send the very first step immediately
        sendCurrentStep()

        // 2. Schedule timer for subsequent steps (every 3 seconds)
        demoTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.currentStepIndex += 1

            if self.currentStepIndex < self.steps.count {
                self.sendCurrentStep()
            } else {
                self.stopSimulation()
            }
        }
    }

    // old http version
//    func sendCurrentStep() {
//        let step = steps[currentStepIndex]
//
//        let direction = step.simple.lowercased()
//        var commandToSend = "up"
//
//        if direction.contains("left") {
//            commandToSend = "left"
//        } else if direction.contains("right") {
//            commandToSend = "right"
//        }
//
//        print("Simulating Step \(currentStepIndex) (\(step.simple)) -> Sending: \(commandToSend)")
//        connectionStatus = "Simulating: \(commandToSend)..."
//
//        NavService.instance.sendDataToESP32(message: commandToSend) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    self.connectionStatus = "Sent: \(commandToSend) (\(response))"
//                case .failure(let error):
//                    self.connectionStatus = "Err: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
    func sendCurrentStep() {
        let step = steps[currentStepIndex]
        sendStepOverBLE(step)
    }

    func stopSimulation() {
        demoTimer?.invalidate()
        demoTimer = nil
        isSimulating = false
        print("Simulation Stopped")
    }
    private func arrowForStep(_ step: DirectionStep) -> String {
        let text = step.simple.lowercased()

        if text.contains("uturn") || text.contains("u-turn") {
            return "↩"
        } else if text.contains("slight right") {
            return "↗"
        } else if text.contains("slight left") {
            return "↖"
        } else if text.contains("right") {
            return "→"
        } else if text.contains("left") {
            return "←"
        } else {
            return "↑"
        }
    }

    func sendStepOverBLE(_ step: DirectionStep) {
        let street = step.streetName
        let arrow = arrowForStep(step)
        let distance = step.distanceText

        ble.sendNavUpdate(street: street, arrow: arrow, distance: distance)
    }
    
    // Autocomplete functions
    func destinationTextChanged(_ newValue: String) {
        selectedDestinationAddress = nil
        selectedDestinationPlaceID = nil

        autocompleteWorkItem?.cancel()

        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count >= 3 else {
            destinationSuggestions = []
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            PlacesService.shared.fetchSuggestions(
                input: trimmed,
                sessionToken: self.destinationSessionToken
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let suggestions):
                        self.destinationSuggestions = suggestions
                    case .failure:
                        self.destinationSuggestions = []
                    }
                }
            }
        }

        autocompleteWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30, execute: workItem)
    }

    func selectDestinationSuggestion(_ suggestion: PlaceSuggestion) {
        destination = suggestion.fullText
        selectedDestinationAddress = suggestion.fullText
        selectedDestinationPlaceID = suggestion.id
        destinationSuggestions = []

        // start a new session next time user begins typing again
        destinationSessionToken = UUID().uuidString
    }

}


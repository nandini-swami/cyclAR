//
//  NavigationViewModel.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
//
import SwiftUI
import CoreLocation

final class NavigationViewModel: ObservableObject {
    @Published var origin = ""
    @Published var destination = ""
    @Published var steps: [DirectionStep] = []
    @Published var errorMsg: String?
    @Published var demoMode = false
    @Published var currentStepIndex = 0
    @Published var isSimulating = false
    @Published var liveDisplayStep: DirectionStep?
    
    // destination autocomplete
    @Published var destinationSuggestions: [PlaceSuggestion] = []
    @Published var selectedDestinationAddress: String?
    @Published var selectedDestinationPlaceID: String?

    // origin autocomplete
    @Published var originSuggestions: [PlaceSuggestion] = []
    @Published var selectedOriginAddress: String?
    @Published var selectedOriginPlaceID: String?

    private var destinationSessionToken = UUID().uuidString
    private var destinationAutocompleteWorkItem: DispatchWorkItem?

    private var originSessionToken = UUID().uuidString
    private var originAutocompleteWorkItem: DispatchWorkItem?
    
    @Published var isEditingOrigin = false
    @Published var isEditingDestination = false
    @Published var isSelectingSuggestion = false

    @Published var isLiveNavigating = false
    
    let ble = BLEManager.shared
    let loc = LocationManager()

    var navTimer: Timer?
    var demoTimer: Timer?

    // MARK: - Preview Route (Text Origin + Destination)
    func previewRoute() {
        let trimmedOrigin = origin.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedDestination = destination.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmedOrigin.isEmpty else {
                errorMsg = "Please enter start point."
                return
            }

            guard !trimmedDestination.isEmpty else {
                errorMsg = "Please enter destination."
                return
            }
        
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
        let trimmedDestination = destination.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedDestination.isEmpty else {
            errorMsg = "Please enter destination."
            return
        }

        errorMsg = nil
        isLiveNavigating = true
        navTimer?.invalidate()

        navTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            guard let current = self.loc.current else {
                DispatchQueue.main.async {
                    self.errorMsg = "Waiting for GPS..."
                }
                return
            }

            NavService.instance.getBikeDirections(origin: current,
                                                  destination: trimmedDestination) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let newSteps):
                        self.errorMsg = nil
                        self.steps = newSteps
                        self.liveDisplayStep = newSteps.first

                        if let stepToDisplay = self.liveDisplayStep {
                            self.sendStepOverBLE(stepToDisplay)
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
        steps = []
        isLiveNavigating = false
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
    
    // MARK: - Destination autocomplete
    func destinationTextChanged(_ newValue: String) {
        selectedDestinationAddress = nil
        selectedDestinationPlaceID = nil

        destinationAutocompleteWorkItem?.cancel()

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

        destinationAutocompleteWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30, execute: workItem)
    }

    func selectDestinationSuggestion(_ suggestion: PlaceSuggestion) {
        isSelectingSuggestion = true
        isEditingDestination = false

        destination = suggestion.fullText
        selectedDestinationAddress = suggestion.fullText
        selectedDestinationPlaceID = suggestion.id
        destinationSuggestions = []
        destinationSessionToken = UUID().uuidString

        DispatchQueue.main.async {
            self.isSelectingSuggestion = false
        }
    }
    
    // MARK: - Origin autocomplete
    func originTextChanged(_ newValue: String) {
        selectedOriginAddress = nil
        selectedOriginPlaceID = nil

        originAutocompleteWorkItem?.cancel()

        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count >= 3 else {
            originSuggestions = []
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            PlacesService.shared.fetchSuggestions(
                input: trimmed,
                sessionToken: self.originSessionToken
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let suggestions):
                        self.originSuggestions = suggestions
                    case .failure:
                        self.originSuggestions = []
                    }
                }
            }
        }

        originAutocompleteWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30, execute: workItem)
    }

    func selectOriginSuggestion(_ suggestion: PlaceSuggestion) {
        isSelectingSuggestion = true
        isEditingOrigin = false
        
        origin = suggestion.fullText
        selectedOriginAddress = suggestion.fullText
        selectedOriginPlaceID = suggestion.id
        originSuggestions = []
        originSessionToken = UUID().uuidString
        
        DispatchQueue.main.async {
            self.isSelectingSuggestion = false
        }
    }

}


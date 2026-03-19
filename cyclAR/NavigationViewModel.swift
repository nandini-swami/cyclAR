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
    @Published var liveMode = false
    @Published var connectionStatus = "Not Connected"
    @Published var currentStepIndex = 0
    @Published var isSimulating = false

    let loc = LocationManager()

    var navTimer: Timer?
    var demoTimer: Timer?

    // MARK: - Preview Route (Text Origin + Destination)
    func previewRoute() {
        APICalls.instance.getBikeDirections(origin: origin,
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

            APICalls.instance.getBikeDirections(origin: current,
                                                destination: self.destination) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let newSteps):
                        self.errorMsg = nil
                        self.steps = Array(newSteps.prefix(2))

                        print("LIVE NAV UPDATE")
                        for (idx, step) in newSteps.enumerated() {
                            print("[\(idx)] \(step.simple) | \(step.streetName) | \(step.distanceText)")
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
    }

    // MARK: - Manual Send Functions
    func sendLeft() {
        print("Button Pressed: Left")
        connectionStatus = "Sending Left..."
        APICalls.instance.sendDataToESP32(message: "left") { result in
            self.handleResult(result)
        }
    }

    func sendRight() {
        print("Button Pressed: Right")
        connectionStatus = "Sending Right..."
        APICalls.instance.sendDataToESP32(message: "right") { result in
            self.handleResult(result)
        }
    }

    func sendUp() {
        print("Button Pressed: Up")
        connectionStatus = "Sending Up..."
        APICalls.instance.sendDataToESP32(message: "up") { result in
            self.handleResult(result)
        }
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
                self.connectionStatus = "Simulation Complete"
            }
        }
    }

    func sendCurrentStep() {
        let step = steps[currentStepIndex]

        let direction = step.simple.lowercased()
        var commandToSend = "up"

        if direction.contains("left") {
            commandToSend = "left"
        } else if direction.contains("right") {
            commandToSend = "right"
        }

        print("Simulating Step \(currentStepIndex) (\(step.simple)) -> Sending: \(commandToSend)")
        connectionStatus = "Simulating: \(commandToSend)..."

        APICalls.instance.sendDataToESP32(message: commandToSend) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.connectionStatus = "Sent: \(commandToSend) (\(response))"
                case .failure(let error):
                    self.connectionStatus = "Err: \(error.localizedDescription)"
                }
            }
        }
    }

    func stopSimulation() {
        demoTimer?.invalidate()
        demoTimer = nil
        isSimulating = false
        print("Simulation Stopped")
    }

    func handleResult(_ result: Result<String, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let response):
                self.connectionStatus = "Success: \(response)"
            case .failure(let error):
                self.connectionStatus = "Error: \(error.localizedDescription)"
            }
        }
    }
}

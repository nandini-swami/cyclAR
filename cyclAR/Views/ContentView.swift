import SwiftUI
struct ContentView: View {
    @StateObject private var vm = NavigationViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {

                // TOP BAR
                HStack(alignment: .top) {
                    ConnectionStatusBox(connectionStatus: vm.connectionStatus)

                    Spacer()

                    ModeToggleMenu(demoMode: $vm.demoMode) { isOn in
                        if isOn {
                            vm.stopLiveNavigation()
                            vm.errorMsg = nil
                        } else {
                            vm.stopSimulation()
                        }
                    }
                }
                .padding(.horizontal)

                // TITLE + MODE
                HStack(spacing: 10) {
                    Text("CyclAR")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))

                    ModeBadge(demoMode: vm.demoMode)

                    Spacer()
                }
                .padding(.horizontal)

                // DEMO-ONLY CONTROL PANEL
                if vm.demoMode {
                    BLEControlPanel(
                        onLeft: vm.sendLeft,
                        onRight: vm.sendRight,
                        onUp: vm.sendUp
                    )
                    .padding(.horizontal)
                }

                // INPUTS + MAIN BUTTON
                VStack(spacing: 12) {
                    if vm.demoMode {
                        TextField("Start", text: $vm.origin)
                            .textFieldStyle(.roundedBorder)
                    }

                    // 
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Destination", text: $vm.destination)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: vm.destination) { newValue in
                                vm.destinationTextChanged(newValue)
                            }

                        if !vm.destinationSuggestions.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(vm.destinationSuggestions) { suggestion in
                                    Button {
                                        vm.selectDestinationSuggestion(suggestion)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(suggestion.primaryText)
                                                .foregroundColor(.primary)

                                            if !suggestion.secondaryText.isEmpty {
                                                Text(suggestion.secondaryText)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                    }

                                    Divider()
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4))
                            )
                        }

                        if let selected = vm.selectedDestinationAddress {
                            Text("Selected: \(selected)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Button(vm.demoMode ? "Preview Route" : "Go") {
                            if vm.demoMode {
                                vm.previewRoute()
                            } else {
                                vm.startLiveNavigation()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.isSimulating)

                        if vm.demoMode && !vm.steps.isEmpty {
                            Button(vm.isSimulating ? "Stop Sim" : "Send to Display") {
                                if vm.isSimulating {
                                    vm.stopSimulation()
                                } else {
                                    vm.startSimulation()
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(.purple)
                        }
                    }

                    if let errorMsg = vm.errorMsg {
                        Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                .padding(.horizontal)
                
                if !vm.demoMode, let step = vm.liveDisplayStep {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sending to Display")
                            .font(.headline)

                        HStack {
                            Text(icon(for: step.simple))
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.simple)
                                    .font(.headline)
                                Text(step.streetName.isEmpty ? "—" : step.streetName)
                                    .font(.subheadline)
                                Text(step.distanceText)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }

                        Divider()

                        Text("Direction: \(step.simple)")
                        Text("Street: \(step.streetName.isEmpty ? "—" : step.streetName)")
                        Text("Distance: \(step.distanceText)")
                    }
                    .font(.subheadline)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                }

                List(vm.steps.indices, id: \.self) { idx in
                    StepRowView(
                        step: vm.steps[idx],
                        isHighlighted: vm.isSimulating && idx == vm.currentStepIndex
                    )
                }
                .listStyle(.plain)
            }
            .padding(.top, 8)
            .navigationBarHidden(true)
        }
        .onDisappear {
            vm.stopSimulation()
            vm.stopLiveNavigation()
        }
    }
    
    private func icon(for simple: String) -> String {
        let s = simple.uppercased()

        if s.contains("UTURN") || s.contains("U-TURN") {
            return "↩"
        } else if s.contains("SLIGHT RIGHT") {
            return "↗"
        } else if s.contains("SLIGHT LEFT") {
            return "↖"
        } else if s.contains("RIGHT") {
            return "→"
        } else if s.contains("LEFT") {
            return "←"
        } else {
            return "↑"
        }
    }}

#Preview {
    ContentView()
}

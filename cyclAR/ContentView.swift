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
                VStack(alignment: .leading, spacing: 8) {
                    Text("CyclAR")
                        .font(.system(size: 34, weight: .bold))

                    ModeBadge(demoMode: vm.demoMode)
                }
                .padding(.horizontal)

                // DEMO-ONLY CONTROL PANEL
                if vm.demoMode {
                    ESPControlPanel(
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

                    TextField("Destination", text: $vm.destination)
                        .textFieldStyle(.roundedBorder)

                    HStack {
                        Button(vm.demoMode ? "Get Route Preview" : "Start Live Navigation") {
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
}

#Preview {
    ContentView()
}

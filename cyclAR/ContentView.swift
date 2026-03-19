import SwiftUI

struct ContentView: View {
    @StateObject private var vm = NavigationViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ESPControlPanel(
                    espIP: APICalls.instance.espIP,
                    connectionStatus: vm.connectionStatus,
                    onLeft: vm.sendLeft,
                    onRight: vm.sendRight,
                    onUp: vm.sendUp
                )

                Toggle("Live Navigation", isOn: $vm.liveMode)
                    .padding(.horizontal)
                    .onChange(of: vm.liveMode) { isOn in
                        if !isOn {
                            vm.stopLiveNavigation()
                            vm.errorMsg = nil
                        } else {
                            vm.stopSimulation()
                        }
                    }

                VStack(spacing: 12) {
                    if !vm.liveMode {
                        TextField("Start", text: $vm.origin)
                            .textFieldStyle(.roundedBorder)
                    }

                    TextField("Destination", text: $vm.destination)
                        .textFieldStyle(.roundedBorder)

                    HStack {
                        Button(vm.liveMode ? "Start Live Navigation" : "Get Route Preview") {
                            if vm.liveMode {
                                vm.startLiveNavigation()
                            } else {
                                vm.previewRoute()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.isSimulating)

                        if !vm.liveMode && !vm.steps.isEmpty {
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
                .padding()

                List(vm.steps.indices, id: \.self) { idx in
                    StepRowView(
                        step: vm.steps[idx],
                        isHighlighted: vm.isSimulating && idx == vm.currentStepIndex
                    )
                }
                .listStyle(.plain)
            }
            .navigationTitle("CyclAR")
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

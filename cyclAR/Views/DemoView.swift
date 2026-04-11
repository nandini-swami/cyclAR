//
//  DemoView.swift
//  cyclAR
//
//  Created by Nandini Swami on 4/11/26.
//
//  A self-contained demo sandbox for showcasing the helmet navigation
//  system to judges and stakeholders. Entirely separate from live nav.
//

import SwiftUI

struct DemoView: View {
    @StateObject private var vm = NavigationViewModel()

    var body: some View {
        VStack(spacing: 0) {

            // ── NAV BAR (demo pill always visible here) ──────────────
            CyclARNavBar(connectionStatus: vm.connectionStatus, demoMode: true)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── EXPLAINER CARD ───────────────────────────────
                    DemoExplainerCard()
                        .padding(.horizontal, 16)
                        .padding(.top, 14)

                    // ── CURRENTLY SENDING BANNER ─────────────────────
                    if vm.isSimulating, let step = vm.steps[safe: vm.currentStepIndex] {
                        LiveNavBanner(step: step)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // ── ROUTE INPUTS ─────────────────────────────────
                    DemoRouteInputSection(vm: vm)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)

                    // ── MANUAL SEND CONTROLS ─────────────────────────
                    DemoManualControls(vm: vm)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)

                    // ── ERROR ─────────────────────────────────────────
                    if let errorMsg = vm.errorMsg {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 12))
                            Text(errorMsg)
                                .font(.cyclARCaption)
                        }
                        .foregroundColor(.brand)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }

                    // ── ROUTE STEPS ──────────────────────────────────
                    if !vm.steps.isEmpty {
                        DirectionsList(vm: vm, highlightActive: true)
                            .padding(.top, 14)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color.surfaceGray.ignoresSafeArea())
        .onDisappear {
            vm.stopSimulation()
            vm.stopLiveNavigation()
        }
        .animation(.easeInOut(duration: 0.25), value: vm.isSimulating)
    }
}

// MARK: - Explainer card shown to judges
struct DemoExplainerCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.brandLight)
                    .frame(width: 34, height: 34)
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.brand)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Demo Mode")
                    .font(.cyclARSubhead)
                    .foregroundColor(.appBlack)
                Text("Preview a route and simulate sending directions to the helmet visor. Use manual controls to test individual arrow commands.")
                    .font(.cyclARCaption)
                    .foregroundColor(.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderGray, lineWidth: 1))
    }
}

// MARK: - Demo Route Inputs (has origin + destination + preview + sim buttons)
struct DemoRouteInputSection: View {
    @ObservedObject var vm: NavigationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeaderLabel(text: "Route")
                .padding(.bottom, 8)

            // Origin
            RouteInputRow(
                icon: "circle.fill",
                iconColor: .textMuted,
                placeholder: "Start location",
                text: $vm.origin
            )

            // Dashed connector
            HStack {
                Rectangle()
                    .fill(Color.borderGray)
                    .frame(width: 1.5, height: 16)
                    .padding(.leading, 19)
                Spacer()
            }

            // Destination
            VStack(alignment: .leading, spacing: 0) {
                RouteInputRow(
                    icon: "mappin.circle.fill",
                    iconColor: .brand,
                    placeholder: "Destination",
                    text: $vm.destination,
                    onChanged: { vm.destinationTextChanged($0) }
                )
                if !vm.destinationSuggestions.isEmpty {
                    AutocompleteDrop(vm: vm)
                        .padding(.top, 4)
                }
            }

            // Action buttons
            HStack(spacing: 10) {
                // Preview route
                Button {
                    vm.previewRoute()
                } label: {
                    Text("Preview Route")
                        .font(.cyclARHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(vm.isSimulating ? Color.brand.opacity(0.45) : Color.brand)
                        .cornerRadius(12)
                }
                .disabled(vm.isSimulating)

                // Send to visor / Stop
                if !vm.steps.isEmpty {
                    Button {
                        if vm.isSimulating { vm.stopSimulation() }
                        else { vm.startSimulation() }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: vm.isSimulating ? "stop.fill" : "antenna.radiowaves.left.and.right")
                                .font(.system(size: 12))
                            Text(vm.isSimulating ? "Stop" : "Send to Visor")
                                .font(.cyclARSubhead)
                        }
                        .foregroundColor(vm.isSimulating ? Color(hex: "#791F1F") : Color(hex: "#5534B5"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                        .background(vm.isSimulating ? Color(hex: "#FCEBEB") : Color(hex: "#EEEDFE"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    vm.isSimulating ? Color(hex: "#F7C1C1") : Color(hex: "#CEC8F6"),
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
            .padding(.top, 12)

            // Simulation progress bar
            if vm.isSimulating && !vm.steps.isEmpty {
                SimProgressBar(
                    current: vm.currentStepIndex,
                    total: vm.steps.count
                )
                .padding(.top, 10)
            }
        }
    }
}

// MARK: - Manual BLE controls
struct DemoManualControls: View {
    @ObservedObject var vm: NavigationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeaderLabel(text: "Manual Controls")

            HStack(spacing: 10) {
                ManualControlButton(arrow: "←", label: "Left",     action: vm.sendLeft)
                ManualControlButton(arrow: "↑", label: "Straight", action: vm.sendUp)
                ManualControlButton(arrow: "→", label: "Right",    action: vm.sendRight)
            }
        }
    }
}

struct ManualControlButton: View {
    let arrow: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(arrow)
                    .font(.system(size: 18))
                    .foregroundColor(.appBlack)
                Text(label)
                    .font(.cyclARCaption)
                    .foregroundColor(.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.borderGray, lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Simulation progress bar
struct SimProgressBar: View {
    let current: Int
    let total: Int

    private var progress: Double {
        total > 0 ? Double(current + 1) / Double(total) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Step \(current + 1) of \(total)")
                    .font(.cyclARCaption)
                    .foregroundColor(.textMuted)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.cyclARCaption)
                    .foregroundColor(.brand)
                    .fontWeight(.medium)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.borderGray)
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.brand)
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Safe array subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview { DemoView() }

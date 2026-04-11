import SwiftUI
 
struct ContentView: View {
    @StateObject private var vm = NavigationViewModel()
 
    var body: some View {
        VStack(spacing: 0) {
 
            // ── TOP NAV BAR ──────────────────────────────────────────
            CyclARNavBar(
                connectionStatus: vm.connectionStatus,
                demoMode: vm.demoMode
            )
 
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
 
                    // ── LIVE NAV BANNER (live mode only) ─────────────
                    if !vm.demoMode, let step = vm.liveDisplayStep {
                        LiveNavBanner(step: step)
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
 
                    // ── ROUTE INPUTS ─────────────────────────────────
                    RouteInputSection(vm: vm)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
 
                    // ── DEMO CONTROLS (demo mode only) ───────────────
                    if vm.demoMode {
                        DemoControlsRow(
                            onLeft: vm.sendLeft,
                            onRight: vm.sendRight,
                            onUp: vm.sendUp
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
 
                    // ── ERROR ─────────────────────────────────────────
                    if let errorMsg = vm.errorMsg {
                        Text(errorMsg)
                            .font(.cyclARCaption)
                            .foregroundColor(.brand)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                    }
 
                    // ── DIRECTIONS LIST ──────────────────────────────
                    if !vm.steps.isEmpty {
                        DirectionsList(vm: vm)
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
    }
}
 
// MARK: - Nav Bar
struct CyclARNavBar: View {
    let connectionStatus: String
    let demoMode: Bool
 
    private var isConnected: Bool {
        connectionStatus.lowercased().contains("connect") &&
        !connectionStatus.lowercased().contains("not")
    }
 
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Logo
            HStack(spacing: 0) {
                Text("Cycl")
                    .font(.cyclARLogoFont)
                    .foregroundColor(.appBlack)
                Text("AR")
                    .font(.cyclARLogoFont)
                    .foregroundColor(.brand)
            }
 
            if demoMode {
                Text("DEMO")
                    .font(.cyclARLabel)
                    .tracking(0.5)
                    .foregroundColor(Color(hex: "#856404"))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(hex: "#FFF3CD"))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#FFE69C"), lineWidth: 1)
                    )
            }
 
            Spacer()
 
            // Connection pill
            HStack(spacing: 5) {
                Circle()
                    .fill(isConnected ? Color(hex: "#3B6D11") : Color.textMuted)
                    .frame(width: 6, height: 6)
                Text(isConnected ? "Helmet Connected" : connectionStatus)
                    .font(.cyclARCaption)
                    .foregroundColor(isConnected ? Color(hex: "#3B6D11") : .textMuted)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.borderGray),
            alignment: .bottom
        )
    }
}
 
// MARK: - Live Nav Banner
struct LiveNavBanner: View {
    let step: DirectionStep
 
    var body: some View {
        HStack(spacing: 14) {
            // Arrow icon box
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.brand)
                    .frame(width: 48, height: 48)
                Text(arrowEmoji(for: step.simple))
                    .font(.system(size: 22))
            }
 
            VStack(alignment: .leading, spacing: 3) {
                Text(step.streetName.isEmpty ? step.simple : step.streetName)
                    .font(.cyclARHeadline)
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    Text(step.simple)
                        .font(.cyclARCaption)
                        .foregroundColor(Color.white.opacity(0.6))
                    Text("·")
                        .foregroundColor(Color.white.opacity(0.3))
                    Text(step.distanceText)
                        .font(.cyclARCaption)
                        .foregroundColor(Color.white.opacity(0.7))
                    Text("·")
                        .foregroundColor(Color.white.opacity(0.3))
                    Text("Sending to visor")
                        .font(.cyclARCaption)
                        .foregroundColor(Color.brand.opacity(0.85))
                }
            }
 
            Spacer()
        }
        .padding(14)
        .background(Color.appBlack)
        .cornerRadius(14)
    }
}
 
// MARK: - Route Input Section
struct RouteInputSection: View {
    @ObservedObject var vm: NavigationViewModel
 
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
 
            SectionHeaderLabel(text: "Route")
                .padding(.bottom, 8)
 
            // Origin row (demo only)
            if vm.demoMode {
                RouteInputRow(
                    icon: "circle.fill",
                    iconColor: .textMuted,
                    placeholder: "Start location",
                    text: $vm.origin
                )
                // dashed connector
                HStack {
                    Rectangle()
                        .fill(Color.borderGray)
                        .frame(width: 1.5, height: 18)
                        .padding(.leading, 18)
                    Spacer()
                }
            }
 
            // Destination row
            VStack(alignment: .leading, spacing: 0) {
                RouteInputRow(
                    icon: "mappin.circle.fill",
                    iconColor: .brand,
                    placeholder: "Where to?",
                    text: $vm.destination,
                    onChanged: { vm.destinationTextChanged($0) }
                )
 
                // Autocomplete dropdown
                if !vm.destinationSuggestions.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(vm.destinationSuggestions) { suggestion in
                            Button {
                                vm.selectDestinationSuggestion(suggestion)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "mappin")
                                        .font(.system(size: 11))
                                        .foregroundColor(.brand)
                                        .frame(width: 16)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(suggestion.primaryText)
                                            .font(.cyclARBody)
                                            .foregroundColor(.appBlack)
                                        if !suggestion.secondaryText.isEmpty {
                                            Text(suggestion.secondaryText)
                                                .font(.cyclARCaption)
                                                .foregroundColor(.textMuted)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                            }
                            if suggestion.id != vm.destinationSuggestions.last?.id {
                                Divider().padding(.leading, 40)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.borderGray, lineWidth: 1)
                    )
                    .padding(.top, 4)
                }
            }
 
            // Action buttons
            HStack(spacing: 10) {
                // Main CTA
                Button {
                    if vm.demoMode { vm.previewRoute() }
                    else { vm.startLiveNavigation() }
                } label: {
                    Text(vm.demoMode ? "Preview Route" : "Go")
                        .font(.cyclARHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(vm.isSimulating ? Color.brand.opacity(0.5) : Color.brand)
                        .cornerRadius(12)
                }
                .disabled(vm.isSimulating)
 
                // Demo: sim toggle
                if vm.demoMode && !vm.steps.isEmpty {
                    Button {
                        if vm.isSimulating { vm.stopSimulation() }
                        else { vm.startSimulation() }
                    } label: {
                        Text(vm.isSimulating ? "Stop" : "Send to Visor")
                            .font(.cyclARSubhead)
                            .foregroundColor(Color(hex: "#5534B5"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#EEEDFE"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#CEC8F6"), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.top, 12)
        }
    }
}
 
// MARK: - Route Input Row
struct RouteInputRow: View {
    let icon: String
    let iconColor: Color
    let placeholder: String
    @Binding var text: String
    var onChanged: ((String) -> Void)? = nil
 
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(iconColor)
                .frame(width: 20)
 
            TextField(placeholder, text: $text)
                .font(.cyclARBody)
                .foregroundColor(.appBlack)
                .onChange(of: text) { newVal in onChanged?(newVal) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.borderGray, lineWidth: 1.5)
        )
        .padding(.bottom, 0)
    }
}
 
// MARK: - Demo Controls Row
struct DemoControlsRow: View {
    let onLeft: () -> Void
    let onRight: () -> Void
    let onUp: () -> Void
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeaderLabel(text: "Manual Controls")
            HStack(spacing: 10) {
                DemoButton(label: "← Left",   action: onLeft)
                DemoButton(label: "→ Right",  action: onRight)
                DemoButton(label: "↑ Straight", action: onUp)
            }
        }
    }
}
 
struct DemoButton: View {
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.cyclARSubhead)
                .foregroundColor(.appBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.borderGray, lineWidth: 1.5)
                )
        }
    }
}
 
// MARK: - Directions List
struct DirectionsList: View {
    @ObservedObject var vm: NavigationViewModel
 
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeaderLabel(text: "Directions")
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
 
            VStack(spacing: 6) {
                ForEach(vm.steps.indices, id: \.self) { idx in
                    StepRowView(
                        step: vm.steps[idx],
                        isHighlighted: vm.isSimulating && idx == vm.currentStepIndex
                    )
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}
 
// MARK: - Arrow helpers (shared)
func arrowEmoji(for simple: String) -> String {
    let s = simple.uppercased()
    if s.contains("UTURN") || s.contains("U-TURN") { return "↩" }
    if s.contains("SLIGHT RIGHT")                  { return "↗" }
    if s.contains("SLIGHT LEFT")                   { return "↖" }
    if s.contains("RIGHT")                          { return "→" }
    if s.contains("LEFT")                           { return "←" }
    return "↑"
}
 
#Preview {
    ContentView()
}

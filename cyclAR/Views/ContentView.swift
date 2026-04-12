//
//  ContentView.swift
//  cyclAR
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = NavigationViewModel()

    var body: some View {
        VStack(spacing: 0) {

            CyclARNavBar(demoMode: false)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Live nav banner — appears once navigation starts
                    if let step = vm.liveDisplayStep {
                        LiveNavBanner(step: step)
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    LiveRouteInputSection(vm: vm)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)

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

                    if !vm.steps.isEmpty {
                        DirectionsList(vm: vm, highlightActive: false)
                            .padding(.top, 14)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color.surfaceGray.ignoresSafeArea())
        .onDisappear { vm.stopLiveNavigation() }
    }
}

// MARK: - Live Route Input
struct LiveRouteInputSection: View {
    @ObservedObject var vm: NavigationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeaderLabel(text: "Route")
                .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 0) {
                RouteInputRow(
                    icon: "mappin.circle.fill",
                    iconColor: .brand,
                    placeholder: "Where to?",
                    text: $vm.destination,
                    onChanged: { vm.destinationTextChanged($0) }
                )
                if !vm.destinationSuggestions.isEmpty {
                    AutocompleteDrop(vm: vm)
                        .padding(.top, 4)
                }
            }

            Button {
                vm.startLiveNavigation()
            } label: {
                Text("Go")
                    .font(.cyclARHeadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.brand)
                    .cornerRadius(12)
            }
            .padding(.top, 12)
        }
    }
}

// MARK: - Autocomplete dropdown (shared by ContentView + DemoView)
struct AutocompleteDrop: View {
    @ObservedObject var vm: NavigationViewModel

    var body: some View {
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
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderGray, lineWidth: 1))
    }
}

// MARK: - Directions list (shared by ContentView + DemoView)
struct DirectionsList: View {
    @ObservedObject var vm: NavigationViewModel
    let highlightActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeaderLabel(text: "Directions")
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            VStack(spacing: 6) {
                ForEach(vm.steps.indices, id: \.self) { idx in
                    StepRowView(
                        step: vm.steps[idx],
                        isHighlighted: highlightActive && vm.isSimulating && idx == vm.currentStepIndex
                    )
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

#Preview { ContentView() }

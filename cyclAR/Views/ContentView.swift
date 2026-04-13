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
                    onChanged: {
                        guard !vm.isSelectingSuggestion else { return }
                        vm.isEditingDestination = true
                        vm.destinationTextChanged($0)
                    }
                )

                if vm.isEditingDestination && !vm.destinationSuggestions.isEmpty {
                    PlaceAutocompleteDrop(
                        suggestions: vm.destinationSuggestions,
                        onSelect: vm.selectDestinationSuggestion
                    )
                    .padding(.top, 4)
                }
            }

            Button {
                if vm.isLiveNavigating {
                    vm.stopLiveNavigation()
                } else if !vm.isLoadingLiveRoute {
                    vm.startLiveNavigation()
                }
            } label: {
                Text(vm.isLoadingLiveRoute ? "Loading..." : (vm.isLiveNavigating ? "Stop" : "Go"))
                    .font(.cyclARHeadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(vm.isLoadingLiveRoute ? Color.textMuted : (vm.isLiveNavigating ? Color.appBlack : Color.brand))
                    .cornerRadius(12)
            }
            .disabled(vm.isLoadingLiveRoute)
            .padding(.top, 12)
        }
    }
}

// MARK: - Shared autocomplete dropdown
struct PlaceAutocompleteDrop: View {
    let suggestions: [PlaceSuggestion]
    let onSelect: (PlaceSuggestion) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(suggestions) { suggestion in
                Button {
                    onSelect(suggestion)
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

                if suggestion.id != suggestions.last?.id {
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
    }
}

// MARK: - Directions list
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

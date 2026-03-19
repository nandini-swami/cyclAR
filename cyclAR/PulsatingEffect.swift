//
//  PulsatingEffect.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
//
import SwiftUI

extension View {
    func animateForever() -> some View {
        self.modifier(PulsatingEffect())
    }
}

struct PulsatingEffect: ViewModifier {
    @State private var isOn = false

    func body(content: Content) -> some View {
        content
            .opacity(isOn ? 1 : 0.2)
            .animation(.easeInOut(duration: 0.8).repeatForever(), value: isOn)
            .onAppear { isOn = true }
    }
}

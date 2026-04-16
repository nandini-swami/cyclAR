//
//  DirectionStep.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
//

import Foundation

struct DirectionStep: Identifiable {
    let id = UUID()
    let rawInstruction: String
    let maneuver: String
    let simple: String
    let distanceText: String
    let streetName: String
    let isArrival: Bool
}

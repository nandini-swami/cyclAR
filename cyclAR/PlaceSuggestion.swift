//
//  PlaceSuggestion.swift
//  cyclAR
//
//  Created by Nandini Swami on 4/11/26.
//
import Foundation

struct PlaceSuggestion: Identifiable, Hashable {
    let id: String          // place id
    let primaryText: String
    let secondaryText: String
    let fullText: String
}

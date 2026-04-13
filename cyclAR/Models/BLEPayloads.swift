//
//  BLEPayloads.swift
//  cyclAR
//
//  Created by Nandini Swami on 4/11/26.
//
import Foundation

struct NavPayload: Codable {
    let type: String = "nav"
    let street: String
    let arrow: String
    let distance: String
}

struct ConfigPayload: Codable {
    let type: String = "config"
    let displayEnabled: Bool
    let hapticsEnabled: Bool
    let dangerMode: String
}

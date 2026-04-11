//
//  CoreLocation.swift
//  cyclAR
//
//  Created by Nandini Swami on 11/6/25.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var current: CLLocationCoordinate2D?
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastError: String?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        
        // Request permission
        manager.requestWhenInUseAuthorization()
        
        let status = manager.authorizationStatus

        // If already authorized (user previously accepted), start immediately
        if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        
        // don't start until authorized; will start in delegate below
    }
    
    // MARK: - iOS 14+
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            let status = manager.authorizationStatus
            handleAuth(status)
        }
    
    // MARK: - Handle Auth
    private func handleAuth(_ status: CLAuthorizationStatus) {
            authStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                print("▶️ Starting location updates…")
                manager.startUpdatingLocation()

            case .denied, .restricted:
                print("⛔️ Location permission denied.")
                lastError = "Location permission denied. Enable it in Settings."
                manager.stopUpdatingLocation()

            case .notDetermined:
                print("❓ Authorization not determined.")

            @unknown default:
                print("❓ Unknown authorization status.")
            }
        }

    
    // MARK: - Location Updates
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let loc = locations.last else { return }
            current = loc.coordinate
            print("📍 Updated location:", loc.coordinate)
        }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            lastError = error.localizedDescription
            print("💥 Location error:", error.localizedDescription)
        }

    /// Optional one-shot request if you want a single fix
    func requestOnce() {
        debugPrint("📨 requestLocation()")
        manager.requestLocation()
    }
}



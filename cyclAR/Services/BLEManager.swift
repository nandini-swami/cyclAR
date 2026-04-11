//
//  BLEManager.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/24/26.
//

import Foundation
import CoreBluetooth

final class BLEManager: NSObject, ObservableObject {
    static let shared = BLEManager()

    @Published var connectionStatus = "Bluetooth starting..."
    @Published var isConnected = false
    @Published var discoveredDeviceName: String?

    private var centralManager: CBCentralManager!
    private var piPeripheral: CBPeripheral?
    private var commandCharacteristic: CBCharacteristic?

    // these must match the Pi exactly
    private let serviceUUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef0")
    private let characteristicUUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef1")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else {
            connectionStatus = "Bluetooth unavailable"
            return
        }

        connectionStatus = "Scanning for NavDisplay..."
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }

    func disconnect() {
        guard let piPeripheral else { return }
        centralManager.cancelPeripheralConnection(piPeripheral)
    }

    func sendNavUpdate(street: String, arrow: String, distance: String) {
        guard let piPeripheral,
              let commandCharacteristic else {
            connectionStatus = "Not ready to send"
            return
        }

        let payload = NavPayload(
                street: street,
                arrow: arrow,
                distance: distance
            )

        do {
            let data = try JSONEncoder().encode(payload)
            piPeripheral.writeValue(data, for: commandCharacteristic, type: .withResponse)
            connectionStatus = "Sent nav \(street) | \(arrow) | \(distance)"
        } catch {
            connectionStatus = "JSON encode failed"
        }
    }
    
    func sendConfigUpdate(coverage: SafetyAlertCoverage, alertMethods: [AlertMethod]) {
        guard let piPeripheral,
              let commandCharacteristic else {
            connectionStatus = "Not ready to send config"
            return
        }

        let payload = ConfigPayload(
                alertCoverage: coverage.rawValue,
                alertMethods: alertMethods.map(\.rawValue)
            )

        do {
            let data = try JSONEncoder().encode(payload)
            piPeripheral.writeValue(data, for: commandCharacteristic, type: .withResponse)
            connectionStatus = "Sent config update"
        } catch {
            connectionStatus = "Config JSON encode failed"
        }
    }

    // optional helper for debug buttons
    func sendArrowOnly(_ arrow: String) {
        sendNavUpdate(street: "", arrow: arrow, distance: "")
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("BLE state changed: \(central.state.rawValue)")
        switch central.state {
        case .poweredOn:
            connectionStatus = "Bluetooth ready"
            startScanning()
        case .poweredOff:
            connectionStatus = "Bluetooth off"
        case .unauthorized:
            connectionStatus = "Bluetooth unauthorized"
        case .unsupported:
            connectionStatus = "Bluetooth unsupported"
        default:
            connectionStatus = "Bluetooth unavailable"
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        discoveredDeviceName = peripheral.name
        connectionStatus = "Found \(peripheral.name ?? "NavDisplay"), connecting..."
        piPeripheral = peripheral
        piPeripheral?.delegate = self
        print("Discovered peripheral: \(peripheral.name ?? "unknown")")
        centralManager.stopScan()
        print("Discovered peripheral: \(peripheral.name ?? "unknown")")
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        isConnected = true
        connectionStatus = "Connected"
        print("Connected to peripheral: \(peripheral.name ?? "unknown")")
        connectionStatus = "Connected to \(peripheral.name ?? "NavDisplay")"
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        isConnected = false
        connectionStatus = "Connect failed"
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        isConnected = false
        commandCharacteristic = nil
        connectionStatus = "Disconnected"
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        print("Discovered services: \(String(describing: peripheral.services))")
        for service in services where service.uuid == serviceUUID {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        print("Discovered characteristics: \(String(describing: service.characteristics))")
        for characteristic in characteristics where characteristic.uuid == characteristicUUID {
            commandCharacteristic = characteristic
            connectionStatus = "Ready to send"
            
            // send config after BLE connections
            if let user = UserStore.shared.currentUser {
                    sendConfigUpdate(
                        coverage: user.safetyAlertCoverage,
                        alertMethods: user.alertMethods
                    )
                }
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        if let error {
            connectionStatus = "Write failed: \(error.localizedDescription)"
        }
    }
}

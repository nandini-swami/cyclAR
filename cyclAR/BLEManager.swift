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

    // replace these with the UUIDs you use on the Pi
    private let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-1234567890AB")
    private let characteristicUUID = CBUUID(string: "ABCD1234-5678-1234-5678-1234567890AB")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else {
            connectionStatus = "Bluetooth unavailable"
            return
        }

        connectionStatus = "Scanning for Pi..."
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }

    func disconnect() {
        guard let piPeripheral else { return }
        centralManager.cancelPeripheralConnection(piPeripheral)
    }

    func send(_ message: String) {
        guard let piPeripheral,
              let commandCharacteristic,
              let data = message.data(using: .utf8) else {
            connectionStatus = "Not ready to send"
            return
        }

        piPeripheral.writeValue(data, for: commandCharacteristic, type: .withResponse)
        connectionStatus = "Sent: \(message)"
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            connectionStatus = "Bluetooth ready"
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
        connectionStatus = "Found \(peripheral.name ?? "Pi"), connecting..."
        piPeripheral = peripheral
        piPeripheral?.delegate = self
        centralManager.stopScan()
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        isConnected = true
        connectionStatus = "Connected to \(peripheral.name ?? "Pi")"
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

        for service in services where service.uuid == serviceUUID {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics where characteristic.uuid == characteristicUUID {
            commandCharacteristic = characteristic
            connectionStatus = "Ready to send"
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

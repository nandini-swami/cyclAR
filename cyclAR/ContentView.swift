import SwiftUI

struct DirectionStep: Identifiable {
    let id = UUID()
    let rawInstruction: String
    let maneuver: String
    let simple: String
    let distanceText: String
}

struct ContentView: View {
    @State private var origin = "Houston Hall, Philadelphia"
    @State private var destination = "Penn Museum, Philadelphia"
    @State private var steps: [DirectionStep] = []
    @State private var errorMsg: String?
    @StateObject private var loc = LocationManager()
    @State private var liveMode = false
    @State private var navTimer: Timer?
    
    @State private var connectionStatus = "Not Connected"
    


    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // --- NEW TEST SECTION ---
                VStack {
                    Text("ESP32 IP: 10.103.207.13") // Reminding you of the IP
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        
                Text("Status: \(connectionStatus)")
                    .font(.caption)
                    .foregroundColor(connectionStatus.contains("Success") ? .green : .gray)
                    .padding(.bottom, 5)
                    
                    Button("Turn left") {
                        sendLeft()
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                
                    Button("Turn right") {
                        sendRight()
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                
                

                    Button("Go Straight") {
                        sendUp()
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                                }
                                .padding(.bottom, 20)
                

                // Toggle Mode
                Toggle("Live Navigation", isOn: $liveMode)
                    .padding(.horizontal)
                    .onChange(of: liveMode) { isOn in
                            if !isOn {
                                navTimer?.invalidate()
                                navTimer = nil
                                errorMsg = nil
                            }
                        }

                VStack(spacing: 12) {

                    // Show fields depending on mode
                    if liveMode == false {
                        TextField("Start", text: $origin)
                            .textFieldStyle(.roundedBorder)
                    }

                    TextField("Destination", text: $destination)
                        .textFieldStyle(.roundedBorder)

                    Button(liveMode ? "Start Live Navigation" : "Get Route Preview") {
                        if liveMode {
                            startLiveNavigation()
                        } else {
                            previewRoute()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if let errorMsg {
                        Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                .padding()

                // Steps List
                List(steps) { s in
                    HStack(alignment: .top) {
                        Text(icon(for: s.simple))
                            .font(.title2)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(s.simple).font(.headline)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(s.rawInstruction)
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)

                                Text("→ in \(s.distanceText)")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("CyclAR")
        }
    }

    private func icon(for simple: String) -> String {
        switch simple {
        case "LEFT": return "⬅️"
        case "RIGHT": return "➡️"
        default: return "⬆️"
        }
    }

    // MARK: - Preview Route (Text Origin + Destination)
    func previewRoute() {
        APICalls.instance.getBikeDirections(origin: origin,
                                            destination: destination) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newSteps):
                    errorMsg = nil
                    steps = newSteps
                case .failure(let e):
                    errorMsg = e.localizedDescription

                }
            }
        }
    }

    // MARK: - Live Navigation (GPS → Destination)
    func startLiveNavigation() {
        navTimer?.invalidate()
        
        navTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            guard let current = loc.current else {
                errorMsg = "Waiting for GPS..."
                return
            }

            APICalls.instance.getBikeDirections(origin: current,
                                                destination: destination) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let newSteps):
                        errorMsg = nil
                        steps = Array(newSteps.prefix(2))
                    case .failure(let e):
                        errorMsg = e.localizedDescription
                    }
                }
            }
        }
    }
    
    // --- SEND LEFT FUNCTION ---
        func sendLeft() {
            print("Button Pressed")
            connectionStatus = "Sending..."
            
            APICalls.instance.sendDataToESP32(message: "left") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        connectionStatus = "Success: \(response)"
                    case .failure(let error):
                        connectionStatus = "Error: \(error.localizedDescription)"
                    }
                }
            }
        }
    
    // --- SEND RIGHT FUNCTION ---
    func sendRight() {
        print("Button Pressed")
        connectionStatus = "Sending..."
        
        APICalls.instance.sendDataToESP32(message: "right") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    connectionStatus = "Success: \(response)"
                case .failure(let error):
                    connectionStatus = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // --- SEND UP FUNCTION ---
    func sendUp() {
        print("Button Pressed")
        connectionStatus = "Sending..."
        
        APICalls.instance.sendDataToESP32(message: "up") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    connectionStatus = "Success: \(response)"
                case .failure(let error):
                    connectionStatus = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview { ContentView() }

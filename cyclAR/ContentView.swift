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


    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

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

//                // Debug block (optional)
//                Group {
//                    Text("Auth: \(String(describing: loc.authStatus))")
//                    if let c = loc.current {
//                        Text(String(format: "📍 %.5f, %.5f", c.latitude, c.longitude))
//                    } else {
//                        Text("📍 no fix yet")
//                    }
//                    if let e = loc.lastError { Text("⚠️ \(e)") }
//                }
//                .font(.caption)
//                .foregroundColor(.secondary)

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
}

#Preview { ContentView() }

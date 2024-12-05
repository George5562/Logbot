import SwiftUI
import LogbotCore

public struct ControlView: View {
    @StateObject private var sessionManager = SessionManager.shared
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Connected Devices List
                List(Array(sessionManager.connectedDevices.values), id: \.id) { device in
                    DeviceRow(device: device)
                }
                .frame(height: 200)
                .overlay {
                    if sessionManager.connectedDevices.isEmpty {
                        ContentUnavailableView(
                            "No Devices Connected",
                            systemImage: "wifi.slash",
                            description: Text("Start browsing to discover devices")
                        )
                    }
                }
                
                // Session Controls
                VStack(spacing: 15) {
                    // Connection Controls
                    HStack {
                        Button(action: {
                            sessionManager.startBrowsing()
                        }) {
                            Label("Start Browsing", systemImage: "wifi")
                        }
                        .disabled(sessionManager.isSessionActive)
                        
                        Button(action: {
                            sessionManager.stopBrowsing()
                        }) {
                            Label("Stop Browsing", systemImage: "wifi.slash")
                        }
                    }
                    
                    Divider()
                    
                    // Session Controls
                    HStack {
                        Button(action: {
                            sessionManager.startSession()
                        }) {
                            Label("Start Session", systemImage: "play.circle")
                        }
                        .disabled(sessionManager.connectedDevices.isEmpty || sessionManager.isSessionActive)
                        
                        Button(action: {
                            sessionManager.stopSession()
                        }) {
                            Label("Stop Session", systemImage: "stop.circle")
                        }
                        .disabled(!sessionManager.isSessionActive)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Status View
                StatusView(
                    isSessionActive: sessionManager.isSessionActive,
                    deviceCount: sessionManager.connectedDevices.count
                )
            }
            .padding()
            .navigationTitle("Logbot Control")
        }
    }
}

// MARK: - Supporting Views

private struct DeviceRow: View {
    let device: NetworkCommand.DeviceInfo
    
    var body: some View {
        HStack {
            Image(systemName: deviceIcon)
                .foregroundColor(deviceColor)
            
            VStack(alignment: .leading) {
                Text(device.name)
                    .font(.headline)
                Text(device.type.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Capabilities
            HStack {
                ForEach(device.capabilities, id: \.rawValue) { capability in
                    Image(systemName: capabilityIcon(for: capability))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 5)
    }
    
    private var deviceIcon: String {
        switch device.type {
        case .iPhone: return "iphone"
        case .iPad: return "ipad"
        case .watch: return "applewatch"
        case .mac: return "macpro.gen3"
        }
    }
    
    private var deviceColor: Color {
        switch device.type {
        case .iPhone: return .blue
        case .iPad: return .green
        case .watch: return .orange
        case .mac: return .purple
        }
    }
    
    private func capabilityIcon(for capability: DeviceCapability) -> String {
        switch capability {
        case .video: return "video"
        case .lidar: return "lidar"
        case .motion: return "gyroscope"
        case .control: return "slider.horizontal.3"
        }
    }
}

private struct StatusView: View {
    let isSessionActive: Bool
    let deviceCount: Int
    
    var body: some View {
        HStack {
            // Session Status
            Label(
                isSessionActive ? "Session Active" : "Session Inactive",
                systemImage: isSessionActive ? "circle.fill" : "circle"
            )
            .foregroundColor(isSessionActive ? .green : .red)
            
            Divider()
                .frame(height: 20)
            
            // Device Count
            Label(
                "\(deviceCount) Device\(deviceCount == 1 ? "" : "s")",
                systemImage: "device.laptop"
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
} 
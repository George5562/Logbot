import SwiftUI
import LogbotCore

public struct CaptureView: View {
    @StateObject private var captureDevice = CaptureDevice.shared
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Status Card
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: captureDevice.isConnected ? "wifi" : "wifi.slash")
                            .foregroundColor(captureDevice.isConnected ? .green : .red)
                        Text(captureDevice.isConnected ? "Connected" : "Disconnected")
                            .font(.headline)
                    }
                    
                    if let session = captureDevice.currentSession {
                        Text("Session: \(session.id.uuidString.prefix(8))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Capture Status
                if captureDevice.isCapturing {
                    HStack {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                        Text("Recording")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Spacer()
                
                // Camera Preview Placeholder
                ZStack {
                    Color.black
                        .opacity(0.1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .cornerRadius(15)
                    
                    if !captureDevice.isConnected {
                        VStack(spacing: 10) {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Connect to control station to start capture")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Connection Button
                Button(action: {
                    if captureDevice.isConnected {
                        captureDevice.disconnect()
                    } else {
                        captureDevice.connect()
                    }
                }) {
                    HStack {
                        Image(systemName: captureDevice.isConnected ? "wifi.slash" : "wifi")
                        Text(captureDevice.isConnected ? "Disconnect" : "Connect")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(captureDevice.isConnected ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Logbot Capture")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
} 
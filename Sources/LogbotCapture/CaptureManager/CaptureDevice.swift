import Foundation
import LogbotCore
import MultipeerConnectivity
import Logging

/// Manages the capture device's connection and command handling
public class CaptureDevice: ObservableObject {
    public static let shared = CaptureDevice()
    
    private let logger = Logger(label: "com.logbot.capture")
    private let networkManager = NetworkManager.shared
    
    @Published public private(set) var isConnected = false
    @Published public private(set) var isCapturing = false
    @Published public private(set) var currentSession: Session?
    
    private var deviceInfo: NetworkCommand.DeviceInfo
    
    private init() {
        // Initialize device info
        let id = UUID()
        let name = Host.current().localizedName ?? "Unknown Device"
        
        // Determine device type and capabilities
        #if os(iOS)
        let type: DeviceType = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
        var capabilities: [DeviceCapability] = [.video]
        
        if type == .iPhone {
            capabilities.append(.lidar)
        }
        #else
        let type: DeviceType = .watch
        let capabilities: [DeviceCapability] = [.motion]
        #endif
        
        deviceInfo = NetworkCommand.DeviceInfo(
            id: id,
            name: name,
            type: type,
            capabilities: capabilities
        )
        
        setupNetworkCallbacks()
    }
    
    // MARK: - Public Methods
    
    public func connect() {
        networkManager.startAdvertising(as: deviceInfo.type)
    }
    
    public func disconnect() {
        networkManager.stop()
        isConnected = false
        isCapturing = false
        currentSession = nil
    }
    
    // MARK: - Private Methods
    
    private func setupNetworkCallbacks() {
        // Handle peer connections
        networkManager.onPeerConnected = { [weak self] peerID in
            self?.handlePeerConnected(peerID)
        }
        
        // Handle peer disconnections
        networkManager.onPeerDisconnected = { [weak self] peerID in
            self?.handlePeerDisconnected(peerID)
        }
        
        // Handle incoming data
        networkManager.onDataReceived = { [weak self] data, peerID in
            self?.handleDataReceived(data, from: peerID)
        }
    }
    
    private func handlePeerConnected(_ peerID: MCPeerID) {
        logger.info("Connected to control station: \(peerID.displayName)")
        isConnected = true
        
        // Send device info
        do {
            let command = NetworkCommand.deviceInfo(deviceInfo)
            let data = try command.encode()
            networkManager.send(data)
        } catch {
            logger.error("Failed to send device info: \(error.localizedDescription)")
        }
    }
    
    private func handlePeerDisconnected(_ peerID: MCPeerID) {
        logger.info("Disconnected from control station: \(peerID.displayName)")
        isConnected = false
        isCapturing = false
        currentSession = nil
    }
    
    private func handleDataReceived(_ data: Data, from peerID: MCPeerID) {
        do {
            let command = try NetworkCommand.decode(from: data)
            
            switch command {
            case .startSession(let session):
                logger.info("Received start session command")
                currentSession = session
                
            case .stopSession(let sessionId):
                logger.info("Received stop session command")
                if currentSession?.id == sessionId {
                    currentSession = nil
                    isCapturing = false
                }
                
            case .startCapture:
                logger.info("Received start capture command")
                if currentSession != nil {
                    isCapturing = true
                    CaptureManager.shared.startCapture()
                } else {
                    logger.warning("Cannot start capture without active session")
                }
                
            case .stopCapture:
                logger.info("Received stop capture command")
                isCapturing = false
                CaptureManager.shared.stopCapture()
                
            case .deviceInfo, .error:
                // Not handled by capture devices
                break
            }
        } catch {
            logger.error("Failed to decode command: \(error.localizedDescription)")
        }
    }
} 
import Foundation
import LogbotCore
import MultipeerConnectivity
import Logging

/// Manages data collection sessions and device connections from the control station
public class SessionManager: ObservableObject {
    public static let shared = SessionManager()
    
    private let logger = Logger(label: "com.logbot.session")
    private let networkManager = NetworkManager.shared
    
    @Published public private(set) var activeSession: Session?
    @Published public private(set) var connectedDevices: [String: NetworkCommand.DeviceInfo] = [:]
    @Published public private(set) var isSessionActive = false
    
    private init() {
        setupNetworkCallbacks()
    }
    
    // MARK: - Session Control
    
    public func startSession() {
        guard !isSessionActive else {
            logger.warning("Session already active")
            return
        }
        
        guard !connectedDevices.isEmpty else {
            logger.warning("No devices connected")
            return
        }
        
        // Create new session
        let session = Session(
            id: UUID(),
            timestamp: Date(),
            devices: Array(connectedDevices.keys)
        )
        
        do {
            // Encode and send start command
            let command = NetworkCommand.startSession(session)
            let data = try command.encode()
            networkManager.send(data)
            
            // Update local state
            self.activeSession = session
            self.isSessionActive = true
            
            logger.info("Started session: \(session.id)")
        } catch {
            logger.error("Failed to start session: \(error.localizedDescription)")
        }
    }
    
    public func stopSession() {
        guard let session = activeSession else {
            logger.warning("No active session")
            return
        }
        
        do {
            // Encode and send stop command
            let command = NetworkCommand.stopSession(session.id)
            let data = try command.encode()
            networkManager.send(data)
            
            // Update local state
            self.activeSession = nil
            self.isSessionActive = false
            
            logger.info("Stopped session: \(session.id)")
        } catch {
            logger.error("Failed to stop session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Device Management
    
    public func startBrowsing() {
        networkManager.startBrowsing()
    }
    
    public func stopBrowsing() {
        networkManager.stop()
        connectedDevices.removeAll()
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
        logger.info("Device connected: \(peerID.displayName)")
        // Request device info when connected
        do {
            let command = NetworkCommand.deviceInfo(NetworkCommand.DeviceInfo(
                id: UUID(),
                name: peerID.displayName,
                type: .mac,
                capabilities: [.control]
            ))
            let data = try command.encode()
            networkManager.send(data, to: [peerID])
        } catch {
            logger.error("Failed to request device info: \(error.localizedDescription)")
        }
    }
    
    private func handlePeerDisconnected(_ peerID: MCPeerID) {
        logger.info("Device disconnected: \(peerID.displayName)")
        // Remove device from connected devices
        connectedDevices.removeValue(forKey: peerID.displayName)
    }
    
    private func handleDataReceived(_ data: Data, from peerID: MCPeerID) {
        do {
            let command = try NetworkCommand.decode(from: data)
            
            switch command {
            case .deviceInfo(let info):
                // Store device information
                connectedDevices[peerID.displayName] = info
                logger.info("Received device info from \(peerID.displayName): \(info.type)")
                
            case .error(let message):
                logger.error("Error from \(peerID.displayName): \(message)")
                
            case .startSession(let session):
                logger.info("Received start session from \(peerID.displayName)")
                // Handle remote session start (if needed)
                
            case .stopSession(let sessionId):
                logger.info("Received stop session from \(peerID.displayName)")
                // Handle remote session stop (if needed)
                
            case .startCapture:
                logger.info("Received start capture from \(peerID.displayName)")
                // Handle in capture devices
                
            case .stopCapture:
                logger.info("Received stop capture from \(peerID.displayName)")
                // Handle in capture devices
            }
        } catch {
            logger.error("Failed to decode command: \(error.localizedDescription)")
        }
    }
} 
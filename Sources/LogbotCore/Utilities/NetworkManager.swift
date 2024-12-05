import Foundation
import MultipeerConnectivity
import Logging

/// Manages peer-to-peer connectivity between devices
public class NetworkManager: NSObject {
    public static let shared = NetworkManager()
    
    private let logger = Logger(label: "com.logbot.network")
    private let serviceType = "logbot-sync"
    
    public private(set) var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    
    private var peerID: MCPeerID
    
    public var onPeerConnected: ((MCPeerID) -> Void)?
    public var onPeerDisconnected: ((MCPeerID) -> Void)?
    public var onDataReceived: ((Data, MCPeerID) -> Void)?
    
    private override init() {
        // Initialize with device name and type
        let deviceName = Host.current().localizedName ?? "Unknown Device"
        peerID = MCPeerID(displayName: deviceName)
        super.init()
    }
    
    public func startAdvertising(as role: DeviceType) {
        // Create session if not exists
        if session == nil {
            session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
            session?.delegate = self
        }
        
        // Start advertising service
        let info = ["role": role.rawValue]
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: info, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertising()
        
        logger.info("Started advertising as \(role.rawValue)")
    }
    
    public func startBrowsing() {
        // Create session if not exists
        if session == nil {
            session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
            session?.delegate = self
        }
        
        // Start browsing for services
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        
        logger.info("Started browsing for peers")
    }
    
    public func stop() {
        advertiser?.stopAdvertising()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
        
        advertiser = nil
        browser = nil
        session = nil
        
        logger.info("Stopped network services")
    }
    
    public func send(_ data: Data, to peers: [MCPeerID]) {
        guard let session = session else {
            logger.error("No active session")
            return
        }
        
        do {
            try session.send(data, toPeers: peers, with: .reliable)
        } catch {
            logger.error("Failed to send data: \(error.localizedDescription)")
        }
    }
    
    public func send(_ data: Data) {
        guard let session = session, !session.connectedPeers.isEmpty else {
            logger.error("No connected peers")
            return
        }
        
        send(data, to: session.connectedPeers)
    }
}

// MARK: - MCSessionDelegate
extension NetworkManager: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            logger.info("Peer connected: \(peerID.displayName)")
            onPeerConnected?(peerID)
        case .notConnected:
            logger.info("Peer disconnected: \(peerID.displayName)")
            onPeerDisconnected?(peerID)
        case .connecting:
            logger.info("Peer connecting: \(peerID.displayName)")
        @unknown default:
            logger.warning("Unknown peer state: \(state)")
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        logger.info("Received data from: \(peerID.displayName)")
        onDataReceived?(data, peerID)
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not used in this implementation
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not used in this implementation
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not used in this implementation
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension NetworkManager: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        logger.info("Received invitation from: \(peerID.displayName)")
        // Auto-accept invitations
        invitationHandler(true, session)
    }
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        logger.error("Failed to start advertising: \(error.localizedDescription)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension NetworkManager: MCNearbyServiceBrowserDelegate {
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        logger.info("Found peer: \(peerID.displayName)")
        
        // Auto-invite discovered peers
        browser.invitePeer(peerID, to: session!, withContext: nil, timeout: 30)
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        logger.info("Lost peer: \(peerID.displayName)")
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        logger.error("Failed to start browsing: \(error.localizedDescription)")
    }
} 
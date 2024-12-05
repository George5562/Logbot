import Foundation

/// Represents a data collection session
public struct Session: Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let devices: [String]
    
    public init(id: UUID = UUID(), timestamp: Date = Date(), devices: [String] = []) {
        self.id = id
        self.timestamp = timestamp
        self.devices = devices
    }
} 
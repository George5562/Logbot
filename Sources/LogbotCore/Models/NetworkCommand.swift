import Foundation

/// Commands that can be sent between devices
public enum NetworkCommand: Codable {
    case startSession(Session)
    case stopSession(UUID)
    case startCapture
    case stopCapture
    case deviceInfo(DeviceInfo)
    case error(String)
    
    // Helper struct for device information
    public struct DeviceInfo: Codable {
        public let id: UUID
        public let name: String
        public let type: DeviceType
        public let capabilities: [DeviceCapability]
        
        public init(id: UUID, name: String, type: DeviceType, capabilities: [DeviceCapability]) {
            self.id = id
            self.name = name
            self.type = type
            self.capabilities = capabilities
        }
    }
}

// MARK: - Data Conversion
extension NetworkCommand {
    public func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }
    
    public static func decode(from data: Data) throws -> NetworkCommand {
        try JSONDecoder().decode(NetworkCommand.self, from: data)
    }
} 
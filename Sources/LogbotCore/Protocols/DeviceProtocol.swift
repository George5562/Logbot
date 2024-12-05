import Foundation

/// Protocol defining the requirements for a capture device
public protocol DeviceProtocol {
    var id: UUID { get }
    var name: String { get }
    var type: DeviceType { get }
    var capabilities: [DeviceCapability] { get }
}

public enum DeviceType {
    case iPhone
    case iPad
    case watch
}

public enum DeviceCapability {
    case video
    case lidar
    case motion
} 
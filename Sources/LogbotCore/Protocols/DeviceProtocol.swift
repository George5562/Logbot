import Foundation

/// Protocol defining the requirements for a capture device
public protocol DeviceProtocol {
    var id: UUID { get }
    var name: String { get }
    var type: DeviceType { get }
    var capabilities: [DeviceCapability] { get }
}

public enum DeviceType: String {
    case iPhone = "iphone"
    case iPad = "ipad"
    case watch = "watch"
    case mac = "mac"
}

public enum DeviceCapability: String {
    case video = "video"
    case lidar = "lidar"
    case motion = "motion"
    case control = "control"
} 
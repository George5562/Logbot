import Foundation

/// Represents all possible errors that can occur in the Logbot system
public enum LogbotError: Error {
    // MARK: - Network Errors
    case connectionFailed(reason: String)
    case deviceDisconnected(deviceId: UUID)
    case commandFailed(command: NetworkCommand, reason: String)
    case dataCorrupted(context: String)
    case timeout(operation: String, duration: TimeInterval)
    
    // MARK: - Device Errors
    case hardwareAccessDenied(feature: String)
    case permissionRequired(permission: String)
    case resourceConstraint(resource: String, limit: String)
    case invalidDeviceState(expected: String, actual: String)
    
    // MARK: - Session Errors
    case sessionCreationFailed(reason: String)
    case invalidSession(sessionId: UUID)
    case sessionStateMismatch(expected: String, actual: String)
    case deviceNotReady(deviceId: UUID, reason: String)
    
    // MARK: - Data Collection Errors
    case storageFailed(path: String, reason: String)
    case fileCorrupted(path: String)
    case transferInterrupted(file: String, progress: Double)
    case synchronizationMismatch(details: String)
}

// MARK: - LocalizedError
extension LogbotError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        // Network Errors
        case .connectionFailed(let reason):
            return "Connection failed: \(reason)"
        case .deviceDisconnected(let deviceId):
            return "Device disconnected: \(deviceId)"
        case .commandFailed(let command, let reason):
            return "Command failed - \(command): \(reason)"
        case .dataCorrupted(let context):
            return "Data corrupted: \(context)"
        case .timeout(let operation, let duration):
            return "Operation timed out after \(duration)s: \(operation)"
            
        // Device Errors
        case .hardwareAccessDenied(let feature):
            return "Hardware access denied: \(feature)"
        case .permissionRequired(let permission):
            return "Permission required: \(permission)"
        case .resourceConstraint(let resource, let limit):
            return "Resource limit reached - \(resource): \(limit)"
        case .invalidDeviceState(let expected, let actual):
            return "Invalid device state - Expected: \(expected), Actual: \(actual)"
            
        // Session Errors
        case .sessionCreationFailed(let reason):
            return "Failed to create session: \(reason)"
        case .invalidSession(let sessionId):
            return "Invalid session: \(sessionId)"
        case .sessionStateMismatch(let expected, let actual):
            return "Session state mismatch - Expected: \(expected), Actual: \(actual)"
        case .deviceNotReady(let deviceId, let reason):
            return "Device not ready - \(deviceId): \(reason)"
            
        // Data Collection Errors
        case .storageFailed(let path, let reason):
            return "Storage failed at \(path): \(reason)"
        case .fileCorrupted(let path):
            return "File corrupted: \(path)"
        case .transferInterrupted(let file, let progress):
            return "Transfer interrupted at \(Int(progress * 100))%: \(file)"
        case .synchronizationMismatch(let details):
            return "Synchronization mismatch: \(details)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        // Network Errors
        case .connectionFailed:
            return "Check your network connection and try again"
        case .deviceDisconnected:
            return "Wait for the device to reconnect or restart the application"
        case .commandFailed:
            return "Try the operation again"
        case .dataCorrupted:
            return "The data may need to be recaptured"
        case .timeout:
            return "Check network conditions and try again"
            
        // Device Errors
        case .hardwareAccessDenied:
            return "Check device settings and permissions"
        case .permissionRequired:
            return "Grant the required permission in Settings"
        case .resourceConstraint:
            return "Free up system resources or reduce quality settings"
        case .invalidDeviceState:
            return "Restart the application to reset device state"
            
        // Session Errors
        case .sessionCreationFailed:
            return "Ensure all devices are connected and try again"
        case .invalidSession:
            return "Rejoin the session or start a new one"
        case .sessionStateMismatch:
            return "Synchronize with the control station"
        case .deviceNotReady:
            return "Wait for device initialization to complete"
            
        // Data Collection Errors
        case .storageFailed:
            return "Check available storage space"
        case .fileCorrupted:
            return "The file may need to be recaptured"
        case .transferInterrupted:
            return "The transfer will automatically resume when possible"
        case .synchronizationMismatch:
            return "Resynchronize devices and try again"
        }
    }
}

// MARK: - Error Context
extension LogbotError {
    public var isRecoverable: Bool {
        switch self {
        case .connectionFailed, .deviceDisconnected, .timeout,
             .commandFailed, .invalidDeviceState, .sessionStateMismatch:
            return true
        case .dataCorrupted, .fileCorrupted, .hardwareAccessDenied:
            return false
        default:
            return true
        }
    }
    
    public var shouldNotifyUser: Bool {
        switch self {
        case .connectionFailed, .deviceDisconnected, .hardwareAccessDenied,
             .permissionRequired, .sessionCreationFailed, .storageFailed:
            return true
        case .commandFailed, .timeout, .dataCorrupted:
            return false  // These might be handled automatically
        default:
            return true
        }
    }
    
    public var logLevel: LogLevel {
        switch self {
        case .connectionFailed, .deviceDisconnected, .hardwareAccessDenied:
            return .error
        case .commandFailed, .timeout, .resourceConstraint:
            return .warning
        case .dataCorrupted, .fileCorrupted, .storageFailed:
            return .critical
        default:
            return .notice
        }
    }
}

// MARK: - Log Levels
public enum LogLevel {
    case debug
    case notice
    case warning
    case error
    case critical
} 
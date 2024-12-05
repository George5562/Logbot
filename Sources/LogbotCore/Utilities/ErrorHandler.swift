import Foundation
import Logging

/// Manages error handling, recovery, and user notifications
public class ErrorHandler {
    public static let shared = ErrorHandler()
    
    private let logger = Logger(label: "com.logbot.error")
    private var recoveryHandlers: [String: () -> Void] = [:]
    
    @Published public private(set) var currentError: LogbotError?
    @Published public private(set) var isRecovering = false
    
    private init() {}
    
    // MARK: - Error Handling
    
    public func handle(_ error: LogbotError, from source: String) {
        // Log the error
        log(error, from: source)
        
        // Set current error if it should be shown to user
        if error.shouldNotifyUser {
            currentError = error
        }
        
        // Attempt recovery if possible
        if error.isRecoverable {
            attemptRecovery(from: error)
        }
    }
    
    // MARK: - Recovery
    
    public func registerRecoveryHandler(for errorType: String, handler: @escaping () -> Void) {
        recoveryHandlers[errorType] = handler
    }
    
    public func clearError() {
        currentError = nil
        isRecovering = false
    }
    
    private func attemptRecovery(from error: LogbotError) {
        isRecovering = true
        
        // Get the string representation of the error case
        let errorType = String(describing: error).components(separatedBy: "(").first ?? ""
        
        if let recoveryHandler = recoveryHandlers[errorType] {
            logger.info("Attempting recovery for: \(errorType)")
            recoveryHandler()
        } else {
            logger.warning("No recovery handler for: \(errorType)")
            isRecovering = false
        }
    }
    
    // MARK: - Logging
    
    private func log(_ error: LogbotError, from source: String) {
        let message = """
            Error in \(source)
            Description: \(error.errorDescription ?? "No description")
            Recovery: \(error.recoverySuggestion ?? "No recovery suggestion")
            """
        
        switch error.logLevel {
        case .debug:
            logger.debug("\(message)")
        case .notice:
            logger.notice("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .error:
            logger.error("\(message)")
        case .critical:
            logger.critical("\(message)")
        }
    }
}

// MARK: - Error Recovery Registration

extension ErrorHandler {
    public func registerDefaultRecoveryHandlers() {
        // Network recovery handlers
        registerRecoveryHandler(for: "connectionFailed") { [weak self] in
            // Attempt to reconnect
            self?.logger.info("Attempting to reconnect...")
            // Add reconnection logic
        }
        
        registerRecoveryHandler(for: "deviceDisconnected") { [weak self] in
            // Wait for device to reconnect
            self?.logger.info("Waiting for device reconnection...")
            // Add reconnection monitoring
        }
        
        registerRecoveryHandler(for: "timeout") { [weak self] in
            // Retry the operation
            self?.logger.info("Retrying timed out operation...")
            // Add retry logic
        }
        
        // Session recovery handlers
        registerRecoveryHandler(for: "sessionStateMismatch") { [weak self] in
            // Resynchronize session state
            self?.logger.info("Resynchronizing session state...")
            // Add resync logic
        }
        
        // Transfer recovery handlers
        registerRecoveryHandler(for: "transferInterrupted") { [weak self] in
            // Resume transfer
            self?.logger.info("Resuming interrupted transfer...")
            // Add resume logic
        }
    }
} 
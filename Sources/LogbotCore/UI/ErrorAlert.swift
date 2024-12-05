import SwiftUI

/// View modifier for displaying error alerts
public struct ErrorAlert: ViewModifier {
    @StateObject private var errorHandler = ErrorHandler.shared
    
    public func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: Binding(
                get: { errorHandler.currentError != nil },
                set: { if !$0 { errorHandler.clearError() } }
            )) {
                if let error = errorHandler.currentError {
                    Button("OK") {
                        errorHandler.clearError()
                    }
                    
                    if error.isRecoverable && !errorHandler.isRecovering {
                        Button("Try to Fix") {
                            // The error handler will attempt recovery
                            // when the error is set
                        }
                    }
                }
            } message: {
                if let error = errorHandler.currentError {
                    Text(error.errorDescription ?? "Unknown error")
                    if let recovery = error.recoverySuggestion {
                        Text(recovery)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
    }
}

// MARK: - View Extension
public extension View {
    func errorAlert() -> some View {
        modifier(ErrorAlert())
    }
}

// MARK: - Error Banner
public struct ErrorBanner: View {
    @StateObject private var errorHandler = ErrorHandler.shared
    
    public var body: some View {
        if let error = errorHandler.currentError {
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    
                    Text(error.errorDescription ?? "Unknown error")
                        .font(.callout)
                    
                    Spacer()
                    
                    if error.isRecoverable && !errorHandler.isRecovering {
                        Button("Fix") {
                            // The error handler will attempt recovery
                            // when the error is set
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    Button {
                        errorHandler.clearError()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if let recovery = error.recoverySuggestion {
                    Text(recovery)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(1)  // Ensure banner appears above other content
        }
    }
}

// MARK: - Preview
struct ErrorAlert_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Content")
                .errorAlert()
            
            Button("Show Error") {
                ErrorHandler.shared.handle(
                    .connectionFailed(reason: "Network unavailable"),
                    from: "Preview"
                )
            }
            
            ErrorBanner()
        }
    }
} 
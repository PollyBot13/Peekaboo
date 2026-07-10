import Foundation
import PeekabooBridge
import PeekabooCore
import PeekabooFoundation

// MARK: - Common Error Handling

private func emitError(
    message: String,
    code: ErrorCode,
    jsonOutput: Bool,
    logger: Logger,
    prefix: String = "❌"
) {
    if jsonOutput {
        let response = JSONResponse(
            success: false,
            error: ErrorInfo(
                message: message,
                code: code
            )
        )
        outputJSON(response, logger: logger)
    } else {
        print("\(prefix) \(message)")
    }
}

// ApplicationError has been replaced by PeekabooError
// Callers should use handleGenericError instead

func genericErrorInfo(for error: any Error) -> (message: String, code: ErrorCode, details: String?) {
    guard let bridgeError = error as? PeekabooBridgeErrorEnvelope else {
        return (error.localizedDescription, .UNKNOWN_ERROR, nil)
    }
    return (errorMessage(for: bridgeError), errorCode(for: bridgeError), errorDetails(for: bridgeError))
}

func handleGenericError(_ error: any Error, jsonOutput: Bool, logger: Logger) {
    let info = genericErrorInfo(for: error)
    if jsonOutput {
        outputError(message: info.message, code: info.code, details: info.details, logger: logger)
    } else {
        print("❌ \(info.message)")
    }
}

func handleValidationError(_ error: any Error, jsonOutput: Bool, logger: Logger) {
    emitError(
        message: error.localizedDescription,
        code: .VALIDATION_ERROR,
        jsonOutput: jsonOutput,
        logger: logger
    )
}

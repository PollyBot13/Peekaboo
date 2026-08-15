import CoreGraphics
import Foundation
import PeekabooFoundation

extension UIAutomationService {
    public func mouseDown(
        at point: CGPoint,
        button: PointerButton = .left,
        expectedWindowIdentity: WindowMutationIdentity,
        expectedWindowBounds: CGRect) async throws -> BackgroundPointerHoldToken
    {
        try await self.mouseDownWithOutcome(
            at: point,
            button: button,
            expectedWindowIdentity: expectedWindowIdentity,
            expectedWindowBounds: expectedWindowBounds).payload
    }

    public func mouseDownWithOutcome(
        at point: CGPoint,
        button: PointerButton = .left,
        expectedWindowIdentity: WindowMutationIdentity,
        expectedWindowBounds: CGRect) async throws -> UIAutomationActionResult<BackgroundPointerHoldToken>
    {
        try await self.operationLaneCoordinator.run(scope: .window(expectedWindowIdentity), access: .write) {
            try await self.backgroundInputHoldCoordinator.mouseDown(
                at: point,
                button: button,
                expectedWindowIdentity: expectedWindowIdentity,
                expectedWindowBounds: expectedWindowBounds)
        }
    }

    public func mouseUpWithOutcome(
        hold: BackgroundPointerHoldToken) async throws -> UIAutomationActionResult<Void>
    {
        try await self.operationLaneCoordinator.run(scope: .global, access: .write) {
            try self.backgroundInputHoldCoordinator.mouseUp(hold: hold)
        }
    }

    public func mouseUp(hold: BackgroundPointerHoldToken) async throws {
        _ = try await self.mouseUpWithOutcome(hold: hold)
    }

    /// Immediately releases any split pointer input owned by this service. This is idempotent and
    /// should be called when an embedding host loses its caller or lifecycle authority.
    public func releaseHeldInput() async {
        self.backgroundInputHoldCoordinator.releaseHeldInput()
    }

    /// Holds one exact-window background chord for a bounded duration and always posts key-up on
    /// cancellation or failure after key-down.
    public func holdKeyWithOutcome(
        keys: String,
        durationMilliseconds: Int,
        target: ExactWindowKeyboardTarget) async throws -> UIAutomationActionResult<Void>
    {
        guard (1...10000).contains(durationMilliseconds) else {
            throw PeekabooError.invalidInput("Background key hold duration must be between 1 and 10000 milliseconds")
        }
        return try await self.hotkeyWithOutcome(
            keys: keys,
            holdDuration: durationMilliseconds,
            target: target)
    }

    public func holdKey(
        keys: String,
        durationMilliseconds: Int,
        target: ExactWindowKeyboardTarget) async throws
    {
        _ = try await self.holdKeyWithOutcome(
            keys: keys,
            durationMilliseconds: durationMilliseconds,
            target: target)
    }

    public func getCursorPosition() -> CGPoint? {
        self.currentMouseLocation()
    }
}

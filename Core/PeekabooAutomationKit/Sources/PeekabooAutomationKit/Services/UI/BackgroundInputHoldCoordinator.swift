import AXorcist
import CoreGraphics
import Foundation
import PeekabooFoundation

/// Owns split routed pointer input until an explicit release or the bounded watchdog fires.
///
/// The watchdog task retains this coordinator, so deallocating the embedding automation service
/// cannot abandon a posted mouse-down while the process remains alive.
@MainActor
final class BackgroundInputHoldCoordinator {
    typealias Sleeper = @MainActor @Sendable (Duration) async throws -> Void

    private struct HeldPointer {
        let token: BackgroundPointerHoldToken
        let route: WindowRoutedPointerDriver.HeldButtonRoute
    }

    static let defaultIdleTimeout: Duration = .seconds(30)

    private let driver: WindowRoutedPointerDriver
    private let idleTimeout: Duration
    private let sleep: Sleeper
    private var heldPointer: HeldPointer?
    private var watchdog: Task<Void, Never>?

    init(
        driver: WindowRoutedPointerDriver = WindowRoutedPointerDriver(),
        idleTimeout: Duration = BackgroundInputHoldCoordinator.defaultIdleTimeout,
        sleep: @escaping Sleeper = { duration in try await Task.sleep(for: duration) })
    {
        self.driver = driver
        self.idleTimeout = idleTimeout
        self.sleep = sleep
    }

    func mouseDown(
        at point: CGPoint,
        button: PointerButton,
        expectedWindowIdentity: WindowMutationIdentity,
        expectedWindowBounds: CGRect) async throws -> UIAutomationActionResult<BackgroundPointerHoldToken>
    {
        guard self.heldPointer == nil else {
            throw PeekabooError.invalidInput("A background pointer button is already held by this automation service")
        }
        guard let windowID = CGWindowID(exactly: expectedWindowIdentity.windowID) else {
            throw PeekabooError.invalidInput("Background pointer target window ID is out of range")
        }

        let dispatch = try await self.driver.mouseDown(
            at: point,
            button: Self.mouseButton(button),
            targetProcessIdentifier: expectedWindowIdentity.ownerProcessIdentifier,
            targetWindowID: windowID,
            expectedWindowIdentity: expectedWindowIdentity,
            expectedWindowBounds: expectedWindowBounds)
        let token = BackgroundPointerHoldToken()
        self.heldPointer = HeldPointer(token: token, route: dispatch.route)
        self.armWatchdog(for: token)
        return UIAutomationActionResult(payload: token, outcome: dispatch.outcome)
    }

    func mouseUp(hold token: BackgroundPointerHoldToken) throws -> UIAutomationActionResult<Void> {
        guard let heldPointer = self.heldPointer else {
            throw PeekabooError.invalidInput("No background pointer button is held by this automation service")
        }
        guard heldPointer.token == token else {
            throw PeekabooError.invalidInput("Background pointer hold token does not own the held button")
        }

        do {
            let outcome = try self.driver.mouseUp(heldPointer.route)
            self.clearHeldPointer()
            return UIAutomationActionResult(payload: (), outcome: outcome)
        } catch {
            if self.driver.originalProcessGenerationIsCurrent(for: heldPointer.route) {
                self.armWatchdog(for: token)
            } else {
                self.clearHeldPointer()
            }
            throw error
        }
    }

    func releaseHeldInput() {
        guard let heldPointer = self.heldPointer else {
            self.clearHeldPointer()
            return
        }
        do {
            _ = try self.driver.mouseUp(heldPointer.route)
            self.clearHeldPointer()
        } catch {
            if self.driver.originalProcessGenerationIsCurrent(for: heldPointer.route) {
                self.armWatchdog(for: heldPointer.token)
            } else {
                self.clearHeldPointer()
            }
        }
    }

    private func armWatchdog(for token: BackgroundPointerHoldToken) {
        self.watchdog?.cancel()
        self.watchdog = Task { [self] in
            do {
                try await self.sleep(self.idleTimeout)
            } catch {
                return
            }
            guard self.heldPointer?.token == token else { return }
            self.releaseHeldInput()
        }
    }

    private func clearHeldPointer() {
        self.watchdog?.cancel()
        self.watchdog = nil
        self.heldPointer = nil
    }

    private static func mouseButton(_ button: PointerButton) -> MouseButton {
        switch button {
        case .left: .left
        case .right: .right
        case .middle: .middle
        }
    }

    #if DEBUG
    var heldTokenForTesting: BackgroundPointerHoldToken? {
        self.heldPointer?.token
    }

    var watchdogIsArmedForTesting: Bool {
        self.watchdog != nil
    }
    #endif
}

import AXorcist
import CoreGraphics
import Foundation
import PeekabooFoundation
import Testing
@testable import PeekabooAutomationKit

@Suite(.serialized)
struct BackgroundInputHoldCoordinatorTests {
    @Test
    @MainActor
    func `watchdog retains coordinator and releases when owner disappears`() async throws {
        var postedTypes: [CGEventType] = []
        var sleeperContinuation: CheckedContinuation<Void, Never>?
        let receipt = Self.receipt()
        let driver = WindowRoutedPointerDriver(
            hasPostEventAccess: { true },
            resolveRoute: { _, _, _ in receipt },
            routeIsCurrent: { _ in true },
            processGenerationIsCurrent: { _ in true },
            makeEvent: { specification, point in
                CGEvent(
                    mouseEventSource: nil,
                    mouseType: specification.type,
                    mouseCursorPosition: point,
                    mouseButton: specification.button)
            },
            stampWindowLocation: { _, _ in true },
            postSkyLight: { _, _ in true },
            postPublic: { event, _ in postedTypes.append(event.type) },
            resolveTransport: { _ in .publicCGEvent },
            sleep: { _ in })
        var coordinator: BackgroundInputHoldCoordinator? = BackgroundInputHoldCoordinator(
            driver: driver,
            idleTimeout: .seconds(1),
            sleep: { _ in
                await withCheckedContinuation { continuation in
                    sleeperContinuation = continuation
                }
            })
        weak let retainedCoordinator = coordinator

        _ = try await coordinator?.mouseDown(
            at: receipt.screenPoint,
            button: .left,
            expectedWindowIdentity: receipt.identity,
            expectedWindowBounds: receipt.bounds)
        while sleeperContinuation == nil {
            await Task.yield()
        }
        coordinator = nil
        #expect(retainedCoordinator != nil)

        sleeperContinuation?.resume()
        while retainedCoordinator != nil {
            await Task.yield()
        }

        #expect(postedTypes == [.mouseMoved, .leftMouseDown, .leftMouseUp])
    }

    @Test
    @MainActor
    func `only the owning token can release a held pointer`() async throws {
        var postedTypes: [CGEventType] = []
        let receipt = Self.receipt()
        let driver = WindowRoutedPointerDriver(
            hasPostEventAccess: { true },
            resolveRoute: { _, _, _ in receipt },
            routeIsCurrent: { _ in true },
            processGenerationIsCurrent: { _ in true },
            makeEvent: { specification, point in
                CGEvent(
                    mouseEventSource: nil,
                    mouseType: specification.type,
                    mouseCursorPosition: point,
                    mouseButton: specification.button)
            },
            stampWindowLocation: { _, _ in true },
            postSkyLight: { _, _ in true },
            postPublic: { event, _ in postedTypes.append(event.type) },
            resolveTransport: { _ in .publicCGEvent },
            sleep: { _ in })
        let coordinator = BackgroundInputHoldCoordinator(driver: driver)

        let down = try await coordinator.mouseDown(
            at: receipt.screenPoint,
            button: .left,
            expectedWindowIdentity: receipt.identity,
            expectedWindowBounds: receipt.bounds)
        #expect(throws: PeekabooError.self) {
            _ = try coordinator.mouseUp(hold: BackgroundPointerHoldToken())
        }
        #expect(coordinator.heldTokenForTesting == down.payload)

        _ = try coordinator.mouseUp(hold: down.payload)
        #expect(coordinator.heldTokenForTesting == nil)
        #expect(postedTypes == [.mouseMoved, .leftMouseDown, .leftMouseUp])
    }

    private static func receipt() -> WindowRoutedPointerDriver.RouteReceipt {
        WindowRoutedPointerDriver.RouteReceipt(
            identity: WindowMutationIdentity(
                windowID: 7,
                ownerProcessIdentifier: 42,
                ownerProcessStartIdentity: 9001),
            bounds: CGRect(x: 100, y: 200, width: 400, height: 300),
            screenPoint: CGPoint(x: 120, y: 230))
    }
}

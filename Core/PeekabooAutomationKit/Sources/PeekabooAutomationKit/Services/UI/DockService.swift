import AppKit
import Foundation
import os
import PeekabooFoundation

/// Dock-specific errors
public nonisolated enum DockError: StandardizedError {
    case dockNotFound
    case dockListNotFound
    case itemNotFound(String)
    case menuItemNotFound(String)
    case positionNotFound
    case launchFailed(String)
    case scriptError(String)

    public var code: StandardErrorCode {
        switch self {
        case .dockNotFound:
            .dockNotFound
        case .dockListNotFound:
            .dockListNotFound
        case .itemNotFound:
            .dockItemNotFound
        case .menuItemNotFound:
            .menuItemNotFound
        case .positionNotFound:
            .positionNotFound
        case .launchFailed:
            .interactionFailed
        case .scriptError:
            .scriptError
        }
    }

    public var userMessage: String {
        switch self {
        case .dockNotFound:
            "Dock not found"
        case .dockListNotFound:
            "Dock items list not found"
        case let .itemNotFound(name):
            "Dock item '\(name)' not found"
        case let .menuItemNotFound(name):
            "Dock menu item '\(name)' not found"
        case .positionNotFound:
            "Dock position not found"
        case let .launchFailed(message):
            message
        case let .scriptError(message):
            message
        }
    }

    public var context: [String: String] {
        switch self {
        case let .itemNotFound(name), let .menuItemNotFound(name):
            ["name": name]
        case let .launchFailed(message), let .scriptError(message):
            ["message": message]
        default:
            [:]
        }
    }
}

/// Default implementation of Dock interaction operations using AXorcist
@MainActor
public final class DockService: DockServiceProtocol {
    let feedbackClient: any AutomationFeedbackClient
    let logger = Logger(subsystem: "boo.peekaboo.core", category: "DockService")

    public init(feedbackClient: any AutomationFeedbackClient = NoopAutomationFeedbackClient()) {
        self.feedbackClient = feedbackClient
        Task { @MainActor in
            self.feedbackClient.connect()
        }
    }

    public func listDockItems(includeAll: Bool = false) async throws -> [DockItem] {
        try await self.listDockItemsImpl(includeAll: includeAll)
    }

    public func launchFromDock(appName: String) async throws {
        try await self.launchFromDockImpl(appName: appName)
    }

    public func addToDock(path: String, persistent: Bool = true) async throws {
        try await self.addToDockImpl(path: path, persistent: persistent)
    }

    public func removeFromDock(appName: String) async throws {
        try await self.removeFromDockImpl(appName: appName)
    }

    public func rightClickDockItem(appName: String, menuItem: String?) async throws {
        try await self.rightClickDockItemImpl(appName: appName, menuItem: menuItem)
    }

    public func hideDock() async throws {
        try await self.hideDockImpl()
    }

    public func showDock() async throws {
        try await self.showDockImpl()
    }

    public func isDockAutoHidden() async -> Bool {
        await self.isDockAutoHiddenImpl()
    }

    public func findDockItem(name: String) async throws -> DockItem {
        try await self.findDockItemImpl(name: name)
    }
}

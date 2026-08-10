import AppKit
import CoreGraphics
import PeekabooFoundation

enum VisualizerTargetWindowResolver {
    @MainActor
    static func frontmostWindow() -> VisualizerTargetWindow? {
        guard let application = NSWorkspace.shared.frontmostApplication,
              !application.isHidden,
              application.isActive
        else {
            return nil
        }

        return self.onScreenWindows()
            .first { $0.processIdentifier == application.processIdentifier }
    }

    /// Frontmost ordinary window belonging to `pid`. `onScreenWindows()` is
    /// front-to-back, so the first match is the app's frontmost window — the
    /// same rule the renderer's visibility evaluator enforces.
    @MainActor
    static func frontmostWindow(ofProcess pid: pid_t) -> VisualizerTargetWindow? {
        self.onScreenWindows().first { $0.processIdentifier == pid }
    }

    static func target(from context: WindowContext?) -> VisualizerTargetWindow? {
        guard let context,
              let processIdentifier = context.applicationProcessId,
              let rawWindowID = context.windowID,
              let windowID = UInt32(exactly: rawWindowID),
              let frame = context.windowBounds
        else {
            return nil
        }

        let capturedTarget = VisualizerTargetWindow(
            processIdentifier: processIdentifier,
            windowID: windowID,
            frame: frame)
        return self.onScreenWindows().first {
            $0.processIdentifier == processIdentifier && $0.windowID == windowID
        } ?? capturedTarget
    }

    private static func onScreenWindows() -> [VisualizerTargetWindow] {
        guard let windowInfo = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID) as? [[String: Any]]
        else {
            return []
        }

        return windowInfo.compactMap { info in
            guard let ownerPID = info[kCGWindowOwnerPID as String] as? NSNumber,
                  let number = info[kCGWindowNumber as String] as? NSNumber,
                  (info[kCGWindowLayer as String] as? NSNumber)?.intValue == 0,
                  (info[kCGWindowAlpha as String] as? NSNumber)?.doubleValue ?? 1 > 0,
                  let bounds = info[kCGWindowBounds as String] as? [String: Any],
                  let frame = CGRect(dictionaryRepresentation: bounds as CFDictionary),
                  frame.width > 1,
                  frame.height > 1
            else {
                return nil
            }

            return VisualizerTargetWindow(
                processIdentifier: ownerPID.int32Value,
                windowID: number.uint32Value,
                frame: frame)
        }
    }
}

extension UIAutomationService {
    func visualizerTargetWindow(snapshotId: String?) async -> VisualizerTargetWindow? {
        if let snapshotId,
           let result = try? await self.snapshotManager.getDetectionResult(snapshotId: snapshotId),
           let target = VisualizerTargetWindowResolver.target(from: result.metadata.windowContext)
        {
            return target
        }
        return VisualizerTargetWindowResolver.frontmostWindow()
    }

    /// Anchor for input feedback. Untargeted input follows the frontmost
    /// window; process-targeted input anchors to the target's own window
    /// (snapshot context first, else the pid's frontmost window) so the
    /// renderer's visibility evaluator can decide whether it may render.
    /// A targeted operation with no resolvable anchor shows nothing.
    func inputFeedbackAnchor(
        snapshotId: String?,
        targetProcessIdentifier: pid_t?,
        resolved visualizerTarget: VisualizerTargetWindow? = nil) async -> VisualizerTargetWindow?
    {
        guard let pid = targetProcessIdentifier else {
            if let visualizerTarget {
                return visualizerTarget
            }
            return await self.visualizerTargetWindow(snapshotId: snapshotId)
        }
        if let visualizerTarget, visualizerTarget.processIdentifier == pid {
            return visualizerTarget
        }
        if let snapshotId,
           let result = try? await self.snapshotManager.getDetectionResult(snapshotId: snapshotId),
           let target = VisualizerTargetWindowResolver.target(from: result.metadata.windowContext),
           target.processIdentifier == pid
        {
            return target
        }
        return await VisualizerTargetWindowResolver.frontmostWindow(ofProcess: pid)
    }
}

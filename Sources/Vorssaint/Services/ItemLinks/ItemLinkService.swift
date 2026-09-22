// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import ApplicationServices
import CoreGraphics
import Foundation

final class ItemLinkService {
    static let shared = ItemLinkService()

    private enum Target {
        case mail, notes
    }

    private static let mailBundleID = "com.apple.mail"
    private static let notesBundleID = "com.apple.Notes"
    private static let editableRoles: Set<String> = [
        "AXTextField", "AXTextArea", "AXComboBox", "AXSecureTextField",
    ]

    private let routeLock = NSLock()
    private var routeShortcut = GlobalShortcut.itemLinkDefault
    private let lifecycleLock = NSLock()
    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var tapRunLoop: CFRunLoop?
    private var tapThread: Thread?
    private var shouldStopTapThread = false
    private var pendingStartAfterStop = false
    private let workQueue = DispatchQueue(label: "Vorssaint.ItemLinks", qos: .userInitiated)

    private init() {
        SessionActivity.shared.onChange { [weak self] _ in self?.syncWithPreferences() }
    }

    func syncWithPreferences() {
        let shortcut = GlobalShortcut.saved(for: DefaultsKey.itemLinkShortcut,
                                            fallback: .itemLinkDefault)
        routeLock.withLock { routeShortcut = shortcut }
        let enabled = AppFeature.itemLinks.isAvailable
            && UserDefaults.standard.bool(forKey: DefaultsKey.itemLinksEnabled)
        if SessionActivitySupport.tapShouldRun(featureWanted: enabled,
                                               accessibilityGranted: AXIsProcessTrusted(),
                                               sessionIsActive: SessionActivity.shared.isActive) {
            installTap()
        } else {
            removeTap()
        }
    }

    func suspend() {
        removeTap()
    }

    private func installTap() {
        let thread = lifecycleLock.withLock { () -> Thread? in
            if tapThread != nil {
                if shouldStopTapThread { pendingStartAfterStop = true }
                return nil
            }
            shouldStopTapThread = false
            pendingStartAfterStop = false
            let thread = Thread { [weak self] in self?.runEventTap() }
            thread.name = "Vorssaint Item Links"
            thread.qualityOfService = .userInteractive
            tapThread = thread
            return thread
        }
        thread?.start()
    }

    private func removeTap() {
        let snapshot = lifecycleLock.withLock {
            () -> (runLoop: CFRunLoop?, tap: CFMachPort?, threadExists: Bool) in
            shouldStopTapThread = true
            pendingStartAfterStop = false
            return (tapRunLoop, tap, tapThread != nil)
        }
        if let tap = snapshot.tap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let runLoop = snapshot.runLoop {
            CFRunLoopPerformBlock(runLoop, CFRunLoopMode.commonModes.rawValue) { CFRunLoopStop(runLoop) }
            CFRunLoopWakeUp(runLoop)
        } else if !snapshot.threadExists {
            lifecycleLock.withLock {
                shouldStopTapThread = false
                tapThread = nil
            }
        }
    }

    private func runEventTap() {
        autoreleasepool {
            let runLoop = CFRunLoopGetCurrent()
            lifecycleLock.withLock { tapRunLoop = runLoop }
            guard !lifecycleLock.withLock({ shouldStopTapThread }) else {
                if clearEventTapThread() { installTap() }
                return
            }
            let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
            guard let tap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .tailAppendEventTap,
                options: .defaultTap,
                eventsOfInterest: mask,
                callback: { _, type, event, userInfo in
                    guard let userInfo else { return Unmanaged.passUnretained(event) }
                    return Unmanaged<ItemLinkService>.fromOpaque(userInfo)
                        .takeUnretainedValue().route(type: type, event: event)
                },
                userInfo: Unmanaged.passUnretained(self).toOpaque()
            ) else {
                _ = clearEventTapThread()
                return
            }
            let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            lifecycleLock.withLock {
                self.tap = tap
                runLoopSource = source
            }
            CFRunLoopAddSource(runLoop, source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            if lifecycleLock.withLock({ shouldStopTapThread }) {
                CGEvent.tapEnable(tap: tap, enable: false)
            } else {
                CFRunLoopRun()
            }
            CGEvent.tapEnable(tap: tap, enable: false)
            CFRunLoopRemoveSource(runLoop, source, .commonModes)
            CFMachPortInvalidate(tap)
            if clearEventTapThread() { installTap() }
        }
    }

    private func clearEventTapThread() -> Bool {
        lifecycleLock.withLock {
            let restart = pendingStartAfterStop
            tap = nil
            runLoopSource = nil
            tapRunLoop = nil
            tapThread = nil
            shouldStopTapThread = false
            pendingStartAfterStop = false
            return restart
        }
    }

    private func route(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            let currentTap = lifecycleLock.withLock { shouldStopTapThread ? nil : tap }
            if SessionActivity.shared.isActive, AXIsProcessTrusted(), let currentTap {
                CGEvent.tapEnable(tap: currentTap, enable: true)
            } else {
                DispatchQueue.main.async { [weak self] in self?.syncWithPreferences() }
            }
            return Unmanaged.passUnretained(event)
        }
        guard type == .keyDown else { return Unmanaged.passUnretained(event) }
        let shortcut = routeLock.withLock { routeShortcut }
        guard shortcut.matches(
            keyCode: event.getIntegerValueField(.keyboardEventKeycode),
            modifiers: GlobalShortcutModifiers(cgFlags: event.flags)
        ), AXIsProcessTrusted(), let app = NSWorkspace.shared.frontmostApplication,
           !Self.editableRoles.contains(focusedRole(for: app.processIdentifier) ?? "")
        else { return Unmanaged.passUnretained(event) }

        let target: Target
        switch app.bundleIdentifier {
        case Self.mailBundleID: target = .mail
        case Self.notesBundleID: target = .notes
        default: return Unmanaged.passUnretained(event)
        }
        workQueue.async { [weak self] in self?.copyLinks(for: target) }
        return nil
    }

    private func focusedRole(for pid: pid_t) -> String? {
        let app = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(app, 0.15)
        var focused: CFTypeRef?
        guard AXUIElementCopyAttributeValue(app, kAXFocusedUIElementAttribute as CFString,
                                            &focused) == .success,
              let focused, CFGetTypeID(focused) == AXUIElementGetTypeID() else { return nil }
        var role: CFTypeRef?
        guard AXUIElementCopyAttributeValue(focused as! AXUIElement,
                                            kAXRoleAttribute as CFString, &role) == .success,
              let role, CFGetTypeID(role) == CFStringGetTypeID() else { return nil }
        return role as? String
    }

    private func copyLinks(for target: Target) {
        let urls: [URL]
        switch target {
        case .mail: urls = MailLinkBridge.selectedLinks()
        case .notes: urls = NotesLinkBridge.selectedLinks()
        }
        guard let text = ItemLinkSupport.clipboardText(urls) else {
            showResult(success: false, count: 0)
            return
        }
        GeneralPasteboardAccess.shared.async {
            let board = NSPasteboard.general
            board.clearContents()
            let copied = board.setString(text, forType: .string)
            self.showResult(success: copied, count: urls.count)
        }
    }

    private func showResult(success: Bool, count: Int) {
        DispatchQueue.main.async {
            let strings = FeatureStrings.itemLinks(L10n.shared.language)
            let message = success ? String(format: strings.copiedFormat, count) : strings.failed
            QuickToolHUD.show(icon: success ? "link" : "exclamationmark.triangle", message: message)
        }
    }
}

private enum MailLinkBridge {
    static func selectedLinks() -> [URL] {
        guard AppleScriptRunner.consentToAutomate(bundleID: "com.apple.mail") else { return [] }
        let result = AppleScriptRunner.run("""
        tell application "Mail"
            set output to ""
            repeat with itemMessage in (get selection)
                set output to output & (message id of itemMessage) & linefeed
            end repeat
            return output
        end tell
        """)
        guard result.ok else { return [] }
        return result.output.split(whereSeparator: \.isNewline)
            .compactMap { ItemLinkSupport.mailURL(messageID: String($0)) }
    }
}

private enum NotesLinkBridge {
    private static let databaseURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Group Containers/group.com.apple.notes/NoteStore.sqlite")

    static func selectedLinks() -> [URL] {
        guard AppleScriptRunner.consentToAutomate(bundleID: "com.apple.Notes") else { return [] }
        let result = AppleScriptRunner.run("""
        tell application "Notes"
            set output to ""
            repeat with itemNote in (get selection)
                set output to output & (id of itemNote) & linefeed
            end repeat
            return output
        end tell
        """)
        guard result.ok else { return [] }
        let keys = result.output.split(whereSeparator: \.isNewline)
            .compactMap { ItemLinkSupport.notePrimaryKey(from: String($0)) }
        guard !keys.isEmpty else { return [] }
        return NoteLinkStore.identifiers(for: keys, databaseURL: databaseURL)
            .compactMap(ItemLinkSupport.noteURL(identifier:))
    }
}

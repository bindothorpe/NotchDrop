//
//  AppDelegate.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import AppKit
import Cocoa
import LaunchAtLogin
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var isFirstOpen = true
    var isLaunchedAtLogin = false
    var mainWindowController: NotchWindowController?
    var settingsWindowController: NSWindowController?
    var statusItem: NSStatusItem?

    var timer: Timer?

    func applicationDidFinishLaunching(_: Notification) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rebuildApplicationWindows),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        NSApp.setActivationPolicy(.accessory)

        isLaunchedAtLogin = LaunchAtLogin.wasLaunchedAtLogin

        _ = EventMonitors.shared
        let timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            self?.determineIfProcessIdentifierMatches()
            self?.makeKeyAndVisibleIfNeeded()
        }
        self.timer = timer
        
        // Initialize shortcuts
        _ = ShortcutManager.shared
        
        // Setup menu bar icon and menu
        setupMenuBar()

        rebuildApplicationWindows()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "rectangle.inset.toptrailing.filled", accessibilityDescription: "NotchDrop")
        }
        
        let menu = NSMenu()
        // Add settings menu item with the shortcut displayed
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(settingsItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func openSettings() {
        if settingsWindowController == nil {
            // Create the window
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.title = "NotchDrop Settings"
            
            // Create a SwiftUI hosting controller with your settings view
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            window.contentViewController = hostingController
            
            // Create a window controller to manage the window
            settingsWindowController = NSWindowController(window: window)
        }
        
        // Show the window and bring it to front
        settingsWindowController?.showWindow(nil)
        
        // Ensure the app is active so the window appears in front
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillTerminate(_: Notification) {
        try? FileManager.default.removeItem(at: temporaryDirectory)
        try? FileManager.default.removeItem(at: pidFile)
    }

    func findScreenFitsOurNeeds() -> NSScreen? {
        if let screen = NSScreen.buildin, screen.notchSize != .zero { return screen }
        return .main
    }

    @objc func rebuildApplicationWindows() {
        defer { isFirstOpen = false }
        if let mainWindowController {
            mainWindowController.destroy()
        }
        mainWindowController = nil
        guard let mainScreen = findScreenFitsOurNeeds() else { return }
        mainWindowController = .init(screen: mainScreen)
        if isFirstOpen, !isLaunchedAtLogin {
            mainWindowController?.openAfterCreate = true
        }
    }

    func determineIfProcessIdentifierMatches() {
        let pid = String(NSRunningApplication.current.processIdentifier)
        let content = (try? String(contentsOf: pidFile)) ?? ""
        guard pid.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            == content.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        else {
            NSApp.terminate(nil)
            return
        }
    }

    func makeKeyAndVisibleIfNeeded() {
        guard let controller = mainWindowController,
              let window = controller.window,
              let vm = controller.vm,
              vm.status == .opened
        else { return }
        window.makeKeyAndOrderFront(nil)
    }

    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        guard let controller = mainWindowController,
              let vm = controller.vm
        else { return true }
        vm.notchOpen(.click)
        return true
    }
}

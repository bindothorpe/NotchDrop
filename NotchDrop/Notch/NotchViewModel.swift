//
//  NotchViewModel.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import Cocoa
import Combine
import Foundation
import LaunchAtLogin
import SwiftUI


// Notch View Model
class NotchViewModel: NSObject, ObservableObject {
    var cancellables: Set<AnyCancellable> = []
    let inset: CGFloat
    
    // Size manager
    private(set) lazy var sizeManager = NotchSizeManager(viewModel: self)

    init(inset: CGFloat = -4) {
        self.inset = inset
        super.init()
        setupCancellables()
        setupSizeConfigurations() // Add this line to initialize the size manager
    }

    deinit {
        destroy()
    }

    let animation: Animation = .interactiveSpring(
        duration: 0.3,
        extraBounce: 0.15,
        blendDuration: 0.125
    )
    @Published var notchOpenedSize: CGSize = .init(width: 800, height: 160)
    let dropDetectorRange: CGFloat = 32

    enum Status: String, Codable, Hashable, Equatable {
        case closed
        case opened
        case popping
    }

    enum OpenReason: String, Codable, Hashable, Equatable {
        case click
        case drag
        case boot
        case unknown
    }

    enum ContentType: Int, Codable, Hashable, Equatable {
        case normal
        case menu
        case settings
    }

    var notchOpenedRect: CGRect {
        .init(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - notchOpenedSize.height,
            width: notchOpenedSize.width,
            height: notchOpenedSize.height
        )
    }

    var headlineOpenedRect: CGRect {
        .init(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - deviceNotchRect.height,
            width: notchOpenedSize.width,
            height: deviceNotchRect.height
        )
    }

    @Published private(set) var status: Status = .closed
    @Published var openReason: OpenReason = .unknown
    @Published var contentType: ContentType = .normal {
        didSet {
            // Update notch size when content type changes
            if oldValue != contentType && status == .opened {
                sizeManager.updateNotchSize(for: contentType)
            }
        }
    }

    @Published var spacing: CGFloat = 16
    @Published var cellSize: CGFloat = 108
    @Published var cornerRadius: CGFloat = 16
    @Published var deviceNotchRect: CGRect = .zero {
        didSet {
            // Update size when device notch rect changes
            if status == .opened {
                sizeManager.updateNotchSize(for: contentType)
            }
        }
    }
    @Published var screenRect: CGRect = .zero
    @Published var optionKeyPressed: Bool = false
    @Published var notchVisible: Bool = true

    @PublishedPersist(key: "selectedLanguage", defaultValue: .system)
    var selectedLanguage: Language

    @PublishedPersist(key: "hapticFeedback", defaultValue: true)
    var hapticFeedback: Bool

    let hapticSender = PassthroughSubject<Void, Never>()

    func notchOpen(_ reason: OpenReason) {
        openReason = reason
        status = .opened
        contentType = .normal
        // Update notch size when opening
        sizeManager.updateNotchSize(for: contentType)
        NSApp.activate(ignoringOtherApps: true)
    }

    func notchClose() {
        openReason = .unknown
        status = .closed
        contentType = .normal
    }

    func showSettings() {
        contentType = .settings
    }

    func notchPop() {
        openReason = .unknown
        status = .popping
    }
    
    // Method to update notch size (called by the size manager)
    func updateNotchSize(_ newSize: CGSize) {
        // Ensure minimum width and height
        let minWidth = max(deviceNotchRect.width * 2, 400)
        let minHeight = max(deviceNotchRect.height * 2, 120)
        
        // Apply size limits
        var finalSize = newSize
        finalSize.width = max(minWidth, finalSize.width)
        finalSize.height = max(minHeight, finalSize.height)
        
        // Don't exceed screen size minus some margin
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            finalSize.width = min(screenFrame.width * 0.9, finalSize.width)
            finalSize.height = min(screenFrame.height * 0.8, finalSize.height)
        }
        
        // Update the size
        notchOpenedSize = finalSize
    }
}

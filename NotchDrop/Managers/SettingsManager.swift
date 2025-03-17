//
//  SettingsManager.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 15/03/2025.
//

// SettingsManager.swift
import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    // Singleton instance for easy access
    static let shared = SettingsManager()
    
    // Use @Published for nested objects
    @Published var appearance: AppearanceSettings
    @Published var general: GeneralSettings
    @Published var behavior: BehaviorSettings
    
    // Storage for cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.appearance = AppearanceSettings()
        self.general = GeneralSettings()
        self.behavior = BehaviorSettings()
        
        // Set up observers to propagate changes upward
        setupObservers()
    }
    
    private func setupObservers() {
        // Forward changes from nested objects to this object
        appearance.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        general.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        behavior.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    // Nested class for appearance-related settings
    class AppearanceSettings: ObservableObject {
        @Published var notch: NotchSettings
        @Published var widget: WidgetSettings
        
        // Storage for cancellables
        private var cancellables = Set<AnyCancellable>()
        
        init() {
            self.notch = NotchSettings()
            self.widget = WidgetSettings()
            setupObservers()
        }
        
        private func setupObservers() {
            // Forward changes from nested objects to this object
            notch.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
            
            widget.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
        }
        
        // Notch settings class
        class NotchSettings: ObservableObject {
            @Published var cornerRadius: CornerRadiusSettings
            @Published var sizeAdjustment: SizeAdjustmentSettings
            @AppStorage("translucentNotchBackground") var isTranslucent = true {
                didSet { objectWillChange.send() }
            }
            @AppStorage("translucentNotchOpacity") var translucentOpacity = 0.3 {
                didSet { objectWillChange.send() }
            }
            @AppStorage("notchSpacing") var spacing: Double = 8.0 {
                didSet { objectWillChange.send() }
            }
            
            // Storage for cancellables
            private var cancellables = Set<AnyCancellable>()
            
            init() {
                self.cornerRadius = CornerRadiusSettings()
                self.sizeAdjustment = SizeAdjustmentSettings()
                setupObservers()
            }
            
            private func setupObservers() {
                // Forward changes from nested objects to this object
                cornerRadius.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }.store(in: &cancellables)
                
                sizeAdjustment.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }.store(in: &cancellables)
            }
            
            class SizeAdjustmentSettings: ObservableObject {
                @AppStorage("width") var width: Double = 0.0 {
                    didSet { objectWillChange.send() }
                }
                @AppStorage("height") var height: Double = 0.0 {
                    didSet { objectWillChange.send() }
                }
            }
            
            // Further nested settings for corner radius in different states
            class CornerRadiusSettings: ObservableObject {
                @Published var closed: ClosedRadiusSettings
                @Published var opened: OpenedRadiusSettings
                @Published var popping: PoppingRadiusSettings
                
                private var cancellables = Set<AnyCancellable>()
                
                init() {
                    self.closed = ClosedRadiusSettings()
                    self.opened = OpenedRadiusSettings()
                    self.popping = PoppingRadiusSettings()
                    setupObservers()
                }
                
                private func setupObservers() {
                    closed.objectWillChange.sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }.store(in: &cancellables)
                    
                    opened.objectWillChange.sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }.store(in: &cancellables)
                    
                    popping.objectWillChange.sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }.store(in: &cancellables)
                }
                
                class ClosedRadiusSettings: ObservableObject {
                    @AppStorage("notchCornerRadiusClosed") var main: Double = 8.0 {
                        didSet { objectWillChange.send() }
                    }
                    @AppStorage("notchCornerRadiusClosedWing") var wing: Double = 8.0 {
                        didSet { objectWillChange.send() }
                    }
                }
                
                class OpenedRadiusSettings: ObservableObject {
                    @AppStorage("notchCornerRadiusOpened") var main: Double = 32.0 {
                        didSet { objectWillChange.send() }
                    }
                    @AppStorage("notchCornerRadiusOpenedWing") var wing: Double = 32.0 {
                        didSet { objectWillChange.send() }
                    }
                }
                
                class PoppingRadiusSettings: ObservableObject {
                    @AppStorage("notchCornerRadiusPopping") var main: Double = 10.0 {
                        didSet { objectWillChange.send() }
                    }
                    @AppStorage("notchCornerRadiusPoppingWing") var wing: Double = 10.0 {
                        didSet { objectWillChange.send() }
                    }
                }
            }
        }
        
        // Widget settings class
        class WidgetSettings: ObservableObject {
            @Published var radius: RadiusSettings
            
            private var cancellables = Set<AnyCancellable>()
            
            init() {
                self.radius = RadiusSettings()
                setupObservers()
            }
            
            private func setupObservers() {
                radius.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }.store(in: &cancellables)
            }
            
            // Radius settings for widgets
            class RadiusSettings: ObservableObject {
                @AppStorage("widgetRadiusSmall") var small: Double = 4.0 {
                    didSet { objectWillChange.send() }
                }
                @AppStorage("widgetRadiusNormal") var normal: Double = 8.0 {
                    didSet { objectWillChange.send() }
                }
                @AppStorage("widgetRadiusLarge") var large: Double = 16.0 {
                    didSet { objectWillChange.send() }
                }
            }
        }
    }
    
    class GeneralSettings: ObservableObject {
        @AppStorage("launchAtLogin") var launchAtLogin = true {
            didSet { objectWillChange.send() }
        }
    }
    
    class BehaviorSettings: ObservableObject {
        @AppStorage("autoOpenForDrags") var autoOpenForDrags = true {
            didSet { objectWillChange.send() }
        }
        @AppStorage("closeAfterOperation") var closeAfterOperation = true {
            didSet { objectWillChange.send() }
        }
    }
}

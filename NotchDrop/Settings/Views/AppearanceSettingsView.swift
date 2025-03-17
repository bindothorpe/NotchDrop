//
//  AppearanceSettingsView.swift
//  NotchDrop
//
//  Created by Bindo Thorpe on 14/03/2025.
//


// AppearanceSettingsView.swift
import SwiftUI

struct AppearanceSettingsView: View {
    @StateObject private var settings = SettingsManager.shared
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    // Translucent background toggle
                    VStack(spacing: 12) {
                        SettingRow(label: "") {
                            Toggle("Translucent notch background", isOn: $settings.appearance.notch.isTranslucent)
                        }
                        if settings.appearance.notch.isTranslucent {
                            SettingRow(label: "") {
                                SliderWithValue(
                                    value: $settings.appearance.notch.translucentOpacity,
                                    in: 0...1,
                                    step: 0.1,
                                    label: "Opacity",
                                    decimalPlaces: 1)
                            }
                        }
                    }
                    
                    Divider().padding(.vertical, 8)
                    
                    DescriptiveSettingRow(label: "Fine tuning:", description: "NotchPro tries its best to guess your notch size, but sometimes it can be a bit off. Here you can fine tune it. It has to be exactly the same as your notch.")
                    
                    VStack(spacing: 12) {
                        SettingRow(label: "") {
                            SliderWithValue(
                                value: $settings.appearance.notch.sizeAdjustment.width,
                                in: -10...10,
                                step: 1,
                                label: "Width")
                        }
                        SettingRow(label: "") {
                            SliderWithValue(
                                value: $settings.appearance.notch.sizeAdjustment.height,
                                in: -10...10,
                                step: 1,
                                label: "Height")
                        }
                    }
                    
                    Divider().padding(.vertical, 8)
                    
                    // Main corner radius settings
                    VStack(spacing: 12) {
                        SettingRow(label: "Closed:") {
                            SliderWithValue(
                                value: $settings.appearance.notch.cornerRadius.closed.main,
                                in: 0...22,
                                label: "Corner radius")
                        }
                        
                        SettingRow(label: "") {
                            SliderWithValue(
                                value: $settings.appearance.notch.cornerRadius.closed.wing,
                                in: 0...22,
                                label: "Wing size")
                        }
                        
                        SettingRow(label: "Popping:") {
                            SliderWithValue(
                                value: $settings.appearance.notch.cornerRadius.popping.main,
                                in: 1...22,
                                label: "Corner radius"
                            )
                        }
                        
                        SettingRow(label: "") {
                            SliderWithValue(
                                value: $settings.appearance.notch.cornerRadius.popping.wing,
                                in: 1...22,
                                label: "Wing size"
                            )
                        }
                        
                        SettingRow(label: "Opened:") {
                            SliderWithValue(
                                value: $settings.appearance.notch.cornerRadius.opened.main,
                                in: 1...64,
                                label: "Corner radius"
                            )
                        }
                        
                        SettingRow(label: "") {
                            SliderWithValue(
                                value: $settings.appearance.notch.cornerRadius.opened.wing,
                                in: 1...64,
                                label: "Wing size"
                            )
                        }
                    }
                }
            }.insetGroupedStyle(header: VStack(alignment: .leading) {
                Text("Appearance Settings").font(.largeTitle)
                Text("Notch").font(.title).padding(.top)
            })
            
            Section {
                VStack(spacing: 16) {
                    // Main corner radius settings
                    VStack(spacing: 12) {
                        SettingRow(label: "Corner radius:") {
                            SliderWithValue(
                                value: $settings.appearance.widget.radius.small,
                                in: 0...32,
                                label: "Small")
                        }
                        
                        SettingRow(label: "") {
                            SliderWithValue(
                                value: $settings.appearance.widget.radius.normal,
                                in: 0...48,
                                label: "Normal")
                        }
                        
                        SettingRow(label: "") {
                            SliderWithValue(
                                value: $settings.appearance.widget.radius.large,
                                in: 1...64,
                                label: "Large"
                            )
                        }
                    }
                }
            }.insetGroupedStyle(header: VStack(alignment: .leading) {
                Text("Widget").font(.title).padding(.top)
            })
        }
    }
}

// A reusable component for setting rows with consistent alignment
struct SettingRow<Content: View>: View {
    let label: String
    let content: Content
    
    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 0) {
            GridRow(alignment: .top) {
                Text(label)
                    .frame(width: 150, alignment: .trailing)
                    .gridColumnAlignment(.trailing)
                    .gridCellAnchor(.top)
                
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .gridColumnAlignment(.leading)
                    .gridCellAnchor(.top)
            }
        }
    }
}

struct DescriptiveSettingRow: View {
    let label: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .frame(width: 150, alignment: .trailing)
                
                Text(description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(nil)  // Allow multiple lines
                    .fixedSize(horizontal: false, vertical: true)// Allow text to wrap
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, -8)
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

// A slider with an integrated value display
struct SliderWithValue: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double?
    let label: String?
    let width: CGFloat? // Optional fixed width for the value display
    let decimalPlaces: Int? // Optional parameter to control decimal places
    
    var body: some View {
        HStack(spacing: 12) {
            // Show label if provided
            if let label = label {
                Text(label)
            }
            
            // Choose the appropriate slider based on whether step is provided
            if let step = step {
                Slider(
                    value: $value,
                    in: range,
                    step: step
                )
                .frame(maxWidth: .infinity)
            } else {
                Slider(
                    value: $value,
                    in: range
                )
                .frame(maxWidth: .infinity)
            }
            
            // Value display with customizable width and decimal places
            Text(formattedValue())
                .monospacedDigit()
                .frame(width: width ?? 30)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    // Helper method to format the value based on specified decimal places
    private func formattedValue() -> String {
        if let decimalPlaces = decimalPlaces {
            return String(format: "%.\(decimalPlaces)f", value)
        } else {
            return "\(value)"
        }
    }
    
    // Initializers with various combinations of parameters
    init(
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double? = nil,
        label: String? = nil,
        valueWidth: CGFloat? = nil,
        decimalPlaces: Int? = 0
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
        self.width = valueWidth
        self.decimalPlaces = decimalPlaces
    }
}

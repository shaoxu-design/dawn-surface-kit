import Foundation
import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct DawnSurfaceTheme: Sendable {
    public var backgroundColor: Color
    public var cardBackgroundColor: Color
    public var primaryTextColor: Color
    public var secondaryTextColor: Color
    public var tertiaryTextColor: Color
    public var disabledTextColor: Color
    public var accentColor: Color
    public var destructiveColor: Color
    public var dividerColor: Color
    public var rowFont: Font
    public var tipFont: Font
    public var footerFont: Font
    public var iconFont: Font
    public var cardCornerRadius: CGFloat
    public var gridCardCornerRadius: CGFloat
    public var horizontalPadding: CGFloat
    public var verticalPadding: CGFloat
    public var verticalSpacing: CGFloat
    public var rowHorizontalPadding: CGFloat
    public var rowVerticalPadding: CGFloat
    public var gridSpacing: CGFloat
    public var bottomSpacerHeight: CGFloat
    public var disabledOpacity: Double
    public var selectedSingleIconName: String
    public var unselectedIconName: String
    public var selectedMultipleIconName: String
    public var infoIconName: String

    public static let `default` = DawnSurfaceTheme()

    public init(
        backgroundColor: Color = DawnSurfaceDynamicColor.color(light: "#F2F2F7", dark: "#1C1C1E"),
        cardBackgroundColor: Color = DawnSurfaceDynamicColor.color(light: "#FFFFFF", dark: "#2C2C2E"),
        primaryTextColor: Color = DawnSurfaceDynamicColor.color(light: "#000000", dark: "#FFFFFF"),
        secondaryTextColor: Color = DawnSurfaceDynamicColor.color(light: "#8E8E93", dark: "#8E8E93"),
        tertiaryTextColor: Color = DawnSurfaceDynamicColor.color(light: "#3C3C43", dark: "#EBEBF5").opacity(0.3),
        disabledTextColor: Color = DawnSurfaceDynamicColor.color(light: "#8E8E93", dark: "#8E8E93"),
        accentColor: Color = DawnSurfaceDynamicColor.color(light: "#10B981", dark: "#34D399"),
        destructiveColor: Color = DawnSurfaceDynamicColor.color(light: "#F43F5E", dark: "#FB7185"),
        dividerColor: Color = DawnSurfaceDynamicColor.color(light: "#D1D1D6", dark: "#3A3A3C"),
        rowFont: Font = .system(size: 16, weight: .regular),
        tipFont: Font = .system(size: 12, weight: .regular),
        footerFont: Font = .system(size: 16, weight: .regular),
        iconFont: Font = .system(size: 20, weight: .medium),
        cardCornerRadius: CGFloat = 20,
        gridCardCornerRadius: CGFloat = 12,
        horizontalPadding: CGFloat = 16,
        verticalPadding: CGFloat = 16,
        verticalSpacing: CGFloat = 16,
        rowHorizontalPadding: CGFloat = 16,
        rowVerticalPadding: CGFloat = 16,
        gridSpacing: CGFloat = 12,
        bottomSpacerHeight: CGFloat = 20,
        disabledOpacity: Double = 0.4,
        selectedSingleIconName: String = "circle.inset.filled",
        unselectedIconName: String = "circle",
        selectedMultipleIconName: String = "checkmark",
        infoIconName: String = "info.circle"
    ) {
        self.backgroundColor = backgroundColor
        self.cardBackgroundColor = cardBackgroundColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.tertiaryTextColor = tertiaryTextColor
        self.disabledTextColor = disabledTextColor
        self.accentColor = accentColor
        self.destructiveColor = destructiveColor
        self.dividerColor = dividerColor
        self.rowFont = rowFont
        self.tipFont = tipFont
        self.footerFont = footerFont
        self.iconFont = iconFont
        self.cardCornerRadius = cardCornerRadius
        self.gridCardCornerRadius = gridCardCornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.verticalSpacing = verticalSpacing
        self.rowHorizontalPadding = rowHorizontalPadding
        self.rowVerticalPadding = rowVerticalPadding
        self.gridSpacing = gridSpacing
        self.bottomSpacerHeight = bottomSpacerHeight
        self.disabledOpacity = disabledOpacity
        self.selectedSingleIconName = selectedSingleIconName
        self.unselectedIconName = unselectedIconName
        self.selectedMultipleIconName = selectedMultipleIconName
        self.infoIconName = infoIconName
    }
}

private struct DawnSurfaceThemeKey: EnvironmentKey {
    static let defaultValue = DawnSurfaceTheme.default
}

public extension EnvironmentValues {
    var dawnSurfaceTheme: DawnSurfaceTheme {
        get { self[DawnSurfaceThemeKey.self] }
        set { self[DawnSurfaceThemeKey.self] = newValue }
    }
}

public extension View {
    func dawnSurfaceTheme(_ theme: DawnSurfaceTheme) -> some View {
        self.environment(\.dawnSurfaceTheme, theme)
    }
}

@usableFromInline
enum DawnSurfaceDynamicColor {
    @usableFromInline
    static func color(light lightHex: String, dark darkHex: String) -> Color {
        #if os(iOS)
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(Color(dawnSurfaceHex: darkHex))
            default:
                return UIColor(Color(dawnSurfaceHex: lightHex))
            }
        })
        #elseif os(macOS)
        Color(NSColor(name: nil) { appearance in
            if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
                return NSColor(Color(dawnSurfaceHex: darkHex))
            } else {
                return NSColor(Color(dawnSurfaceHex: lightHex))
            }
        })
        #else
        Color(dawnSurfaceHex: lightHex)
        #endif
    }
}

extension Color {
    @usableFromInline
    init(dawnSurfaceHex hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8) & 0xFF) / 255
        let blue = Double(int & 0xFF) / 255

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}

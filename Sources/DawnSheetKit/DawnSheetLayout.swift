import SwiftUI

struct DawnSheetCard<Content: View>: View {
    let content: Content

    @Environment(\.dawnSheetTheme) private var theme

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            self.content
        }
        .background(self.theme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: self.theme.cardCornerRadius, style: .continuous))
        .padding(.horizontal, self.theme.horizontalPadding)
    }
}

struct DawnSheetDivider: View {
    @Environment(\.dawnSheetTheme) private var theme

    var body: some View {
        Divider()
            .background(self.theme.dividerColor)
            .padding(.horizontal, self.theme.rowHorizontalPadding)
    }
}

extension View {
    @ViewBuilder
    func dawnInlineNavigationTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func dawnWheelPickerStyle() -> some View {
        #if os(iOS)
        self.pickerStyle(.wheel)
        #else
        self
        #endif
    }

    @ViewBuilder
    func dawnPresentationBackgroundInteraction() -> some View {
        #if os(iOS)
        self.presentationBackgroundInteraction(.automatic)
        #else
        self
        #endif
    }
}

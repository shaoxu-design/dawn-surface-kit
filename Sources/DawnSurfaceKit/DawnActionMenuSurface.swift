import SwiftUI

public struct DawnActionMenuSurface: View {
    public let title: String
    public let actions: [Action]
    public let onCancel: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dawnSurfaceTheme) private var theme
    @Environment(\.dawnSurfaceTexts) private var texts

    public init(
        title: String,
        actions: [Action],
        onCancel: (() -> Void)? = nil
    ) {
        self.title = title
        self.actions = actions
        self.onCancel = onCancel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: self.theme.verticalSpacing) {
                    DawnSurfaceCard {
                        ForEach(Array(self.actions.enumerated()), id: \.offset) { index, action in
                            self.actionRow(action)

                            if index < self.actions.count - 1 {
                                DawnSurfaceDivider()
                                    .padding(.leading, self.theme.rowHorizontalPadding)
                            }
                        }
                    }
                }
                .padding(.vertical, self.theme.verticalPadding)
            }
            .background(self.theme.backgroundColor.ignoresSafeArea())
            .navigationTitle(self.title)
            .dawnInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(self.texts.cancel) {
                        self.onCancel?()
                        self.dismiss()
                    }
                    .foregroundStyle(self.theme.secondaryTextColor)
                }
            }
        }
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
        .dawnPresentationBackgroundInteraction()
    }

    private func actionRow(_ action: Action) -> some View {
        Button {
            action.handler()
            if action.dismissesSheet {
                self.dismiss()
            }
        } label: {
            HStack {
                Text(action.title)
                    .font(self.theme.rowFont)
                    .foregroundStyle(action.tintColor ?? self.theme.primaryTextColor)

                Spacer()
            }
            .padding(.horizontal, self.theme.rowHorizontalPadding)
            .padding(.vertical, self.theme.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

public extension DawnActionMenuSurface {
    struct Action {
        public let title: String
        public var tintColor: Color?
        public var dismissesSheet: Bool
        public let handler: () -> Void

        public init(
            title: String,
            tintColor: Color? = nil,
            dismissesSheet: Bool = true,
            handler: @escaping () -> Void
        ) {
            self.title = title
            self.tintColor = tintColor
            self.dismissesSheet = dismissesSheet
            self.handler = handler
        }

        public static func destructive(
            title: String,
            dismissesSheet: Bool = true,
            handler: @escaping () -> Void
        ) -> Action {
            Action(
                title: title,
                tintColor: DawnSurfaceTheme.default.destructiveColor,
                dismissesSheet: dismissesSheet,
                handler: handler
            )
        }
    }
}

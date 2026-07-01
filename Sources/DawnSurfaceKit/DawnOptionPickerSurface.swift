import SwiftUI

public struct DawnOptionPickerSurface<Option: Hashable, Footer: View>: View {
    public let title: String
    public let options: [Option]
    public let displayText: (Option) -> String
    public let isSelected: (Option) -> Bool
    public let onTap: (Option) -> Void
    public let multiSelect: Bool
    public let managementAction: (() -> Void)?
    public let resetAction: (() -> Void)?
    public let disableOption: (Option) -> Bool
    public let footer: () -> Footer

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dawnSurfaceTheme) private var theme
    @Environment(\.dawnSurfaceTexts) private var texts

    public init(
        title: String,
        options: [Option],
        displayText: @escaping (Option) -> String,
        isSelected: @escaping (Option) -> Bool,
        onTap: @escaping (Option) -> Void,
        multiSelect: Bool = false,
        managementAction: (() -> Void)? = nil,
        resetAction: (() -> Void)? = nil,
        disableOption: @escaping (Option) -> Bool = { _ in false },
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.title = title
        self.options = options
        self.displayText = displayText
        self.isSelected = isSelected
        self.onTap = onTap
        self.multiSelect = multiSelect
        self.managementAction = managementAction
        self.resetAction = resetAction
        self.disableOption = disableOption
        self.footer = footer
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: self.theme.verticalSpacing) {
                    DawnSurfaceCard {
                        ForEach(Array(self.options.enumerated()), id: \.element) { index, option in
                            self.optionRow(option)

                            if index < self.options.count - 1 {
                                DawnSurfaceDivider()
                            }
                        }
                    }

                    self.footer()
                }
                .padding(.vertical, self.theme.verticalPadding)
            }
            .background(self.theme.backgroundColor.ignoresSafeArea())
            .navigationTitle(self.title)
            .dawnInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(self.texts.cancel) {
                        self.dismiss()
                    }
                    .foregroundStyle(self.theme.secondaryTextColor)
                }

                if self.multiSelect {
                    ToolbarItemGroup(placement: .confirmationAction) {
                        self.secondaryToolbarAction()

                        Button(self.texts.done) {
                            self.dismiss()
                        }
                        .foregroundStyle(self.theme.accentColor)
                    }
                } else if let reset = self.resetAction {
                    ToolbarItem(placement: .primaryAction) {
                        Button(self.texts.reset) {
                            reset()
                        }
                        .foregroundStyle(self.theme.accentColor)
                    }
                } else if let manage = self.managementAction {
                    ToolbarItem(placement: .primaryAction) {
                        Button(self.texts.manage) {
                            manage()
                            self.dismiss()
                        }
                        .foregroundStyle(self.theme.accentColor)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private func secondaryToolbarAction() -> some View {
        if let reset = self.resetAction {
            Button(self.texts.reset) {
                reset()
            }
            .foregroundStyle(self.theme.secondaryTextColor)
        } else if let manage = self.managementAction {
            Button(self.texts.manage) {
                manage()
                self.dismiss()
            }
            .foregroundStyle(self.theme.secondaryTextColor)
        }
    }

    private func optionRow(_ option: Option) -> some View {
        let disabled = self.disableOption(option)
        return Button {
            guard !disabled else { return }
            self.onTap(option)
            if !self.multiSelect {
                self.dismiss()
            }
        } label: {
            HStack(spacing: 12) {
                Text(self.displayText(option))
                    .font(self.theme.rowFont)
                    .foregroundStyle(self.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                self.selectionIndicator(selected: self.isSelected(option))
            }
            .padding(.horizontal, self.theme.rowHorizontalPadding)
            .padding(.vertical, self.theme.rowVerticalPadding)
            .background(self.theme.cardBackgroundColor)
            .opacity(disabled ? self.theme.disabledOpacity : 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func selectionIndicator(selected: Bool) -> some View {
        if self.multiSelect {
            if selected {
                Image(systemName: self.theme.selectedMultipleIconName)
                    .font(self.theme.iconFont)
                    .foregroundStyle(self.theme.accentColor)
            }
        } else {
            Image(systemName: selected ? self.theme.selectedSingleIconName : self.theme.unselectedIconName)
                .font(self.theme.iconFont)
                .foregroundStyle(selected ? self.theme.accentColor : self.theme.disabledTextColor)
        }
    }
}

public extension DawnOptionPickerSurface where Footer == EmptyView {
    init(
        title: String,
        options: [Option],
        displayText: @escaping (Option) -> String,
        isSelected: @escaping (Option) -> Bool,
        onTap: @escaping (Option) -> Void,
        multiSelect: Bool = false,
        managementAction: (() -> Void)? = nil,
        resetAction: (() -> Void)? = nil,
        disableOption: @escaping (Option) -> Bool = { _ in false }
    ) {
        self.init(
            title: title,
            options: options,
            displayText: displayText,
            isSelected: isSelected,
            onTap: onTap,
            multiSelect: multiSelect,
            managementAction: managementAction,
            resetAction: resetAction,
            disableOption: disableOption,
            footer: { EmptyView() }
        )
    }
}

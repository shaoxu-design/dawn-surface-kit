import SwiftUI

public struct DawnOptionPickerGroup<Option: Hashable> {
    public let title: String?
    public let options: [Option]

    public init(
        title: String? = nil,
        options: [Option]
    ) {
        self.title = title
        self.options = options
    }
}

public enum DawnOptionPickerPresentationMode: Sendable {
    case sheet
    case embedded
}

public struct DawnOptionPickerSurface<Option: Hashable, Footer: View>: View {
    public let title: String
    public let options: [Option]
    public let groups: [DawnOptionPickerGroup<Option>]
    public let displayText: (Option) -> String
    public let isSelected: (Option) -> Bool
    public let onTap: (Option) -> Void
    public let multiSelect: Bool
    public let managementAction: (() -> Void)?
    public let resetAction: (() -> Void)?
    public let disableOption: (Option) -> Bool
    public let presentationMode: DawnOptionPickerPresentationMode
    public let dismissesOnSelection: Bool
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
        presentationMode: DawnOptionPickerPresentationMode = .sheet,
        dismissesOnSelection: Bool = true,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.init(
            title: title,
            groups: [DawnOptionPickerGroup(options: options)],
            displayText: displayText,
            isSelected: isSelected,
            onTap: onTap,
            multiSelect: multiSelect,
            managementAction: managementAction,
            resetAction: resetAction,
            disableOption: disableOption,
            presentationMode: presentationMode,
            dismissesOnSelection: dismissesOnSelection,
            footer: footer
        )
    }

    public init(
        title: String,
        groups: [DawnOptionPickerGroup<Option>],
        displayText: @escaping (Option) -> String,
        isSelected: @escaping (Option) -> Bool,
        onTap: @escaping (Option) -> Void,
        multiSelect: Bool = false,
        managementAction: (() -> Void)? = nil,
        resetAction: (() -> Void)? = nil,
        disableOption: @escaping (Option) -> Bool = { _ in false },
        presentationMode: DawnOptionPickerPresentationMode = .sheet,
        dismissesOnSelection: Bool = true,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.title = title
        self.options = groups.flatMap(\.options)
        self.groups = groups
        self.displayText = displayText
        self.isSelected = isSelected
        self.onTap = onTap
        self.multiSelect = multiSelect
        self.managementAction = managementAction
        self.resetAction = resetAction
        self.disableOption = disableOption
        self.presentationMode = presentationMode
        self.dismissesOnSelection = dismissesOnSelection
        self.footer = footer
    }

    @ViewBuilder
    public var body: some View {
        switch self.presentationMode {
        case .sheet:
            NavigationStack {
                self.pickerContent
                    .navigationTitle(self.title)
                    .dawnInlineNavigationTitle()
                    .toolbar { self.pickerToolbar }
            }
            .presentationDetents([.medium, .large])

        case .embedded:
            self.pickerContent
        }
    }

    private var pickerContent: some View {
        ScrollView {
            VStack(spacing: self.theme.verticalSpacing) {
                ForEach(Array(self.groups.enumerated()), id: \.offset) { _, group in
                    self.optionGroup(group)
                }

                self.footer()
            }
            .padding(.vertical, self.theme.verticalPadding)
        }
        .background(self.theme.backgroundColor.ignoresSafeArea())
    }

    @ToolbarContentBuilder
    private var pickerToolbar: some ToolbarContent {
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

    @ViewBuilder
    private func optionGroup(_ group: DawnOptionPickerGroup<Option>) -> some View {
        if !group.options.isEmpty {
            VStack(alignment: .leading, spacing: self.theme.gridSpacing) {
                if let title = group.title, !title.isEmpty {
                    Text(title)
                        .font(self.theme.tipFont)
                        .foregroundStyle(self.theme.secondaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, self.theme.horizontalPadding + self.theme.rowHorizontalPadding)
                }

                DawnSurfaceCard {
                    ForEach(Array(group.options.enumerated()), id: \.element) { index, option in
                        self.optionRow(option)

                        if index < group.options.count - 1 {
                            DawnSurfaceDivider()
                        }
                    }
                }
            }
        }
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
            if !self.multiSelect, self.dismissesOnSelection {
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
        disableOption: @escaping (Option) -> Bool = { _ in false },
        presentationMode: DawnOptionPickerPresentationMode = .sheet,
        dismissesOnSelection: Bool = true
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
            presentationMode: presentationMode,
            dismissesOnSelection: dismissesOnSelection,
            footer: { EmptyView() }
        )
    }

    init(
        title: String,
        groups: [DawnOptionPickerGroup<Option>],
        displayText: @escaping (Option) -> String,
        isSelected: @escaping (Option) -> Bool,
        onTap: @escaping (Option) -> Void,
        multiSelect: Bool = false,
        managementAction: (() -> Void)? = nil,
        resetAction: (() -> Void)? = nil,
        disableOption: @escaping (Option) -> Bool = { _ in false },
        presentationMode: DawnOptionPickerPresentationMode = .sheet,
        dismissesOnSelection: Bool = true
    ) {
        self.init(
            title: title,
            groups: groups,
            displayText: displayText,
            isSelected: isSelected,
            onTap: onTap,
            multiSelect: multiSelect,
            managementAction: managementAction,
            resetAction: resetAction,
            disableOption: disableOption,
            presentationMode: presentationMode,
            dismissesOnSelection: dismissesOnSelection,
            footer: { EmptyView() }
        )
    }
}

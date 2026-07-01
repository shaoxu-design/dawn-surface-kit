import SwiftUI

public struct DawnGridSelectionSheet<Option: Hashable>: View {
    public let title: String
    public let options: [Option]
    public let displayText: (Option) -> String
    public let isSelected: (Option) -> Bool
    public let onTap: (Option) -> Void
    public var tip: String?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dawnSheetTheme) private var theme
    @Environment(\.dawnSheetTexts) private var texts

    public init(
        title: String,
        options: [Option],
        displayText: @escaping (Option) -> String,
        isSelected: @escaping (Option) -> Bool,
        onTap: @escaping (Option) -> Void,
        tip: String? = nil
    ) {
        self.title = title
        self.options = options
        self.displayText = displayText
        self.isSelected = isSelected
        self.onTap = onTap
        self.tip = tip
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: self.columns, spacing: self.theme.gridSpacing) {
                    ForEach(self.options, id: \.self) { option in
                        self.optionCard(option)
                    }
                }
                .padding(.horizontal, self.theme.horizontalPadding)
                .padding(.top, self.theme.verticalPadding)

                if let tip {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: self.theme.infoIconName)
                        Text(tip)
                    }
                    .font(self.theme.tipFont)
                    .foregroundStyle(self.theme.tertiaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, self.theme.horizontalPadding + 4)
                    .padding(.top, self.theme.gridSpacing)
                }

                Color.clear
                    .frame(height: self.theme.bottomSpacerHeight)
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
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .dawnPresentationBackgroundInteraction()
    }

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: self.theme.gridSpacing),
            GridItem(.flexible(), spacing: self.theme.gridSpacing),
        ]
    }

    private func optionCard(_ option: Option) -> some View {
        let selected = self.isSelected(option)
        return Button {
            self.onTap(option)
            self.dismiss()
        } label: {
            HStack(spacing: 8) {
                Text(self.displayText(option))
                    .font(self.theme.rowFont)
                    .foregroundStyle(self.theme.primaryTextColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: selected ? self.theme.selectedSingleIconName : self.theme.unselectedIconName)
                    .font(self.theme.iconFont)
                    .foregroundStyle(selected ? self.theme.accentColor : self.theme.disabledTextColor)
            }
            .padding(.horizontal, self.theme.rowHorizontalPadding - 4)
            .padding(.vertical, self.theme.rowVerticalPadding)
            .background(self.theme.cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: self.theme.gridCardCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

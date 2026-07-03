import SwiftUI

public enum DawnManagementPresentationMode: Sendable {
    case sheet
    case embedded
}

public struct DawnManagementSurface<
    Item: Identifiable,
    RowContent: View,
    EmptyContent: View,
    PrincipalContent: View,
    LoadingContent: View
>: View {
    public let title: String
    public var presentationMode: DawnManagementPresentationMode
    public var items: [Item]
    public var rowHeight: CGFloat
    public var isLoading: Bool
    public var addButtonTitle: String?
    public var addButtonSystemImage: String
    public var autoScrollToInsertedItem: Bool
    public let onDismiss: (() -> Void)?
    public let onAddTapped: (() -> Void)?
    public let onMove: ((IndexSet, Int) -> Void)?
    public let rowContent: (Item) -> RowContent
    public let emptyContent: () -> EmptyContent
    public let principalContent: () -> PrincipalContent
    public let loadingContent: () -> LoadingContent

    @Environment(\.dawnSurfaceTheme) private var theme
    @Environment(\.dawnSurfaceTexts) private var texts
    @Environment(\.colorScheme) private var colorScheme

    public init(
        title: String,
        presentationMode: DawnManagementPresentationMode = .sheet,
        items: [Item],
        rowHeight: CGFloat = 56,
        isLoading: Bool = false,
        addButtonTitle: String? = nil,
        addButtonSystemImage: String = "plus",
        autoScrollToInsertedItem: Bool = true,
        onDismiss: (() -> Void)? = nil,
        onAddTapped: (() -> Void)? = nil,
        onMove: ((IndexSet, Int) -> Void)? = nil,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder emptyContent: @escaping () -> EmptyContent,
        @ViewBuilder principalContent: @escaping () -> PrincipalContent,
        @ViewBuilder loadingContent: @escaping () -> LoadingContent
    ) {
        self.title = title
        self.presentationMode = presentationMode
        self.items = items
        self.rowHeight = rowHeight
        self.isLoading = isLoading
        self.addButtonTitle = addButtonTitle
        self.addButtonSystemImage = addButtonSystemImage
        self.autoScrollToInsertedItem = autoScrollToInsertedItem
        self.onDismiss = onDismiss
        self.onAddTapped = onAddTapped
        self.onMove = onMove
        self.rowContent = rowContent
        self.emptyContent = emptyContent
        self.principalContent = principalContent
        self.loadingContent = loadingContent
    }

    public var body: some View {
        switch self.presentationMode {
        case .sheet:
            NavigationStack {
                self.managementContent
                    .navigationTitle(self.title)
                    .dawnInlineNavigationTitle()
                    .toolbar { self.sheetToolbar }
            }

        case .embedded:
            self.managementContent
                .navigationTitle(self.title)
                .dawnInlineNavigationTitle()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        self.principalContent()
                    }
                }
        }
    }

    private var managementContent: some View {
        GeometryReader { geometry in
            ZStack {
                self.theme.backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    self.listCard(availableHeight: geometry.size.height)
                }
                .padding(.top, self.theme.verticalPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                if self.isLoading {
                    self.loadingOverlay
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            self.addButtonInset
        }
    }

    @ToolbarContentBuilder
    private var sheetToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(self.texts.cancel) {
                self.onDismiss?()
            }
            .foregroundStyle(self.theme.secondaryTextColor)
        }

        ToolbarItem(placement: .principal) {
            self.principalContent()
        }

        ToolbarItem(placement: .confirmationAction) {
            Button(self.texts.done) {
                self.onDismiss?()
            }
            .foregroundStyle(self.theme.accentColor)
        }
    }

    @ViewBuilder
    private func listCard(availableHeight: CGFloat) -> some View {
        let cardShape = RoundedRectangle(cornerRadius: self.theme.cardCornerRadius, style: .continuous)

        if self.items.isEmpty {
            VStack {
                self.emptyContent()
                    .padding(.vertical, self.theme.verticalPadding * 2)
                    .frame(maxWidth: .infinity)
            }
            .background(self.theme.cardBackgroundColor)
            .clipShape(cardShape)
            .overlay(
                cardShape
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 12, x: 0, y: 6)
            .padding(.horizontal, self.theme.horizontalPadding)
        } else {
            ScrollViewReader { scrollProxy in
                List {
                    ForEach(Array(self.items.enumerated()), id: \.element.id) { index, item in
                        self.rowContent(item)
                            .id(item.id)
                            .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowBackground(self.theme.cardBackgroundColor)
                            .listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
                            .listRowSeparator(index == self.items.count - 1 ? .hidden : .visible, edges: .bottom)
                    }
                    .onMove { source, destination in
                        self.onMove?(source, destination)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                .contentMargins(.vertical, 0, for: .scrollContent)
                .background(self.theme.cardBackgroundColor)
                .frame(height: self.cardHeight(for: self.items.count, availableHeight: availableHeight))
                .clipShape(cardShape)
                .overlay(
                    cardShape
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 12, x: 0, y: 6)
                .dawnManagementEditMode(isActive: self.onMove != nil)
                .padding(.horizontal, self.theme.horizontalPadding)
                .onChange(of: self.items.map(\.id), initial: false) { oldIDs, newIDs in
                    guard self.autoScrollToInsertedItem,
                          newIDs.count == oldIDs.count + 1,
                          Array(newIDs.dropLast()) == oldIDs,
                          let latestID = newIDs.last else {
                        return
                    }

                    Task { @MainActor in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            scrollProxy.scrollTo(latestID, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }

    private func cardHeight(for rowCount: Int, availableHeight: CGFloat) -> CGFloat {
        let contentHeight = CGFloat(max(rowCount, 1)) * self.rowHeight
        let reservedHeight = self.theme.verticalPadding + DawnManagementLayout.floatingButtonReservedSpace
        let maxVisibleHeight = max(self.rowHeight, availableHeight - reservedHeight)

        return min(contentHeight, maxVisibleHeight)
    }

    @ViewBuilder
    private var addButtonInset: some View {
        if let addButtonTitle, let onAddTapped {
            Button(action: onAddTapped) {
                self.addButtonLabel(title: addButtonTitle)
            }
            .buttonStyle(.plain)
            .shadow(
                color: self.addButtonShadowColor,
                radius: self.addButtonShadowRadius,
                x: 0,
                y: self.addButtonShadowYOffset
            )
            .frame(maxWidth: .infinity)
            .padding(.horizontal, self.theme.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private func addButtonLabel(title: String) -> some View {
        let content = HStack(spacing: 8) {
            Image(systemName: self.addButtonSystemImage)
                .font(.system(size: 16, weight: .bold))

            Text(title)
                .font(self.theme.footerFont)
                .fontWeight(.medium)
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal, 24)
        .frame(height: DawnManagementLayout.addButtonHeight)

        #if os(iOS)
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(self.theme.accentColor).interactive(), in: Capsule())
        } else {
            content
                .background(self.theme.accentColor)
                .clipShape(Capsule())
        }
        #else
        content
            .background(self.theme.accentColor)
            .clipShape(Capsule())
        #endif
    }

    private var addButtonShadowColor: Color {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            return self.colorScheme == .dark
                ? Color.black.opacity(0.16)
                : Color.black.opacity(0.08)
        }
        #endif

        return Color.black.opacity(0.12)
    }

    private var addButtonShadowRadius: CGFloat {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            return 8
        }
        #endif

        return 12
    }

    private var addButtonShadowYOffset: CGFloat {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            return 2
        }
        #endif

        return 6
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
                .background(.thinMaterial)

            self.loadingContent()
                .padding(self.theme.verticalPadding * 1.5)
                .background(self.theme.cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: self.theme.cardCornerRadius, style: .continuous))
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        }
    }
}

public struct DawnManagementRow<MenuIcon: View>: View {
    public let title: String
    public var detail: String?
    public let menuIcon: () -> MenuIcon
    public let onMenuTapped: () -> Void

    @Environment(\.dawnSurfaceTheme) private var theme

    public init(
        title: String,
        detail: String? = nil,
        @ViewBuilder menuIcon: @escaping () -> MenuIcon,
        onMenuTapped: @escaping () -> Void
    ) {
        self.title = title
        self.detail = detail
        self.menuIcon = menuIcon
        self.onMenuTapped = onMenuTapped
    }

    public var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(self.title)
                    .font(self.theme.rowFont)
                    .foregroundStyle(self.theme.primaryTextColor)

                if let detail {
                    Text(detail)
                        .font(self.theme.tipFont)
                        .foregroundStyle(self.theme.secondaryTextColor)
                }
            }

            Spacer()

            Button(action: self.onMenuTapped) {
                self.menuIcon()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, self.theme.rowVerticalPadding)
    }
}

public extension DawnManagementRow where MenuIcon == Image {
    init(
        title: String,
        detail: String? = nil,
        menuSystemImage: String = "ellipsis",
        onMenuTapped: @escaping () -> Void
    ) {
        self.init(
            title: title,
            detail: detail,
            menuIcon: {
                Image(systemName: menuSystemImage)
            },
            onMenuTapped: onMenuTapped
        )
    }
}

private enum DawnManagementLayout {
    static let addButtonHeight: CGFloat = 48
    static let floatingButtonReservedSpace: CGFloat = addButtonHeight + 16
}

import SwiftUI

public struct DawnManagementEditConfiguration: Equatable, Sendable {
    public var createTitle: String
    public var editTitle: String
    public var inputPlaceholder: String
    public var createButtonTitle: String
    public var editButtonTitle: String
    public var menuEditTitle: String
    public var menuDeleteTitle: String

    public init(
        createTitle: String = "创建",
        editTitle: String = "编辑",
        inputPlaceholder: String = "请输入名称",
        createButtonTitle: String = "创建",
        editButtonTitle: String = "确定",
        menuEditTitle: String = "编辑",
        menuDeleteTitle: String = "删除"
    ) {
        self.createTitle = createTitle
        self.editTitle = editTitle
        self.inputPlaceholder = inputPlaceholder
        self.createButtonTitle = createButtonTitle
        self.editButtonTitle = editButtonTitle
        self.menuEditTitle = menuEditTitle
        self.menuDeleteTitle = menuDeleteTitle
    }
}

public struct DawnEditableManagementSurface<
    Item: Identifiable,
    RowContent: View,
    EmptyContent: View,
    PrincipalContent: View,
    LoadingContent: View
>: View {
    public let title: String
    public var presentationMode: DawnManagementPresentationMode
    public var items: [Item]
    public var itemTitle: (Item) -> String
    public var editText: (Item) -> String
    public var rowHeight: CGFloat
    public var isLoading: Bool
    public var addButtonTitle: String?
    public var addButtonSystemImage: String
    public var autoScrollToInsertedItem: Bool
    public var editConfiguration: DawnManagementEditConfiguration
    public let onDismiss: (() -> Void)?
    public let onCreate: (String) -> Void
    public let onEdit: (Item, String) -> Void
    public let onDelete: (Item) -> Void
    public let onMove: ((IndexSet, Int) -> Void)?
    public let rowContent: (Item, @escaping () -> Void) -> RowContent
    public let emptyContent: () -> EmptyContent
    public let principalContent: () -> PrincipalContent
    public let loadingContent: () -> LoadingContent

    @Environment(\.dawnSurfaceTexts) private var texts
    @State private var actionMenuItem: Item?
    @State private var pendingMenuAction: MenuAction?
    @State private var inputMode: InputMode?
    @State private var inputText = ""

    public init(
        title: String,
        presentationMode: DawnManagementPresentationMode = .sheet,
        items: [Item],
        itemTitle: @escaping (Item) -> String,
        editText: ((Item) -> String)? = nil,
        rowHeight: CGFloat = 56,
        isLoading: Bool = false,
        addButtonTitle: String? = nil,
        addButtonSystemImage: String = "plus",
        autoScrollToInsertedItem: Bool = true,
        editConfiguration: DawnManagementEditConfiguration = DawnManagementEditConfiguration(),
        onDismiss: (() -> Void)? = nil,
        onCreate: @escaping (String) -> Void,
        onEdit: @escaping (Item, String) -> Void,
        onDelete: @escaping (Item) -> Void,
        onMove: ((IndexSet, Int) -> Void)? = nil,
        @ViewBuilder rowContent: @escaping (Item, @escaping () -> Void) -> RowContent,
        @ViewBuilder emptyContent: @escaping () -> EmptyContent,
        @ViewBuilder principalContent: @escaping () -> PrincipalContent,
        @ViewBuilder loadingContent: @escaping () -> LoadingContent
    ) {
        self.title = title
        self.presentationMode = presentationMode
        self.items = items
        self.itemTitle = itemTitle
        self.editText = editText ?? itemTitle
        self.rowHeight = rowHeight
        self.isLoading = isLoading
        self.addButtonTitle = addButtonTitle
        self.addButtonSystemImage = addButtonSystemImage
        self.autoScrollToInsertedItem = autoScrollToInsertedItem
        self.editConfiguration = editConfiguration
        self.onDismiss = onDismiss
        self.onCreate = onCreate
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onMove = onMove
        self.rowContent = rowContent
        self.emptyContent = emptyContent
        self.principalContent = principalContent
        self.loadingContent = loadingContent
    }

    public var body: some View {
        DawnManagementSurface(
            title: self.title,
            presentationMode: self.presentationMode,
            items: self.items,
            rowHeight: self.rowHeight,
            isLoading: self.isLoading,
            addButtonTitle: self.addButtonTitle,
            addButtonSystemImage: self.addButtonSystemImage,
            autoScrollToInsertedItem: self.autoScrollToInsertedItem,
            onDismiss: self.onDismiss,
            onAddTapped: self.presentCreateInput,
            onMove: self.onMove
        ) { item in
            self.rowContent(item) {
                self.actionMenuItem = item
            }
        } emptyContent: {
            self.emptyContent()
        } principalContent: {
            self.principalContent()
        } loadingContent: {
            self.loadingContent()
        }
        .sheet(item: self.$actionMenuItem, onDismiss: self.handleActionMenuDismissed) { item in
            DawnActionMenuSurface(
                title: self.itemTitle(item),
                actions: [
                    .init(
                        title: self.editConfiguration.menuEditTitle,
                        dismissesSheet: false,
                        handler: {
                            self.pendingMenuAction = .edit(item)
                            self.actionMenuItem = nil
                        }
                    ),
                    .init(
                        title: self.editConfiguration.menuDeleteTitle,
                        tintColor: DawnSurfaceTheme.default.destructiveColor,
                        dismissesSheet: false,
                        handler: {
                            self.pendingMenuAction = .delete(item)
                            self.actionMenuItem = nil
                        }
                    ),
                ]
            )
        }
        .alert(
            self.inputTitle,
            isPresented: Binding(
                get: { self.inputMode != nil },
                set: { isPresented in
                    if !isPresented {
                        self.resetInput()
                    }
                }
            )
        ) {
            TextField(self.editConfiguration.inputPlaceholder, text: self.$inputText)

            Button(self.inputConfirmationTitle) {
                self.submitInput()
            }

            Button(self.texts.cancel, role: .cancel) {
                self.resetInput()
            }
        }
    }

    private var inputTitle: String {
        switch self.inputMode {
        case .create, nil:
            self.editConfiguration.createTitle
        case .edit:
            self.editConfiguration.editTitle
        }
    }

    private var inputConfirmationTitle: String {
        switch self.inputMode {
        case .create, nil:
            self.editConfiguration.createButtonTitle
        case .edit:
            self.editConfiguration.editButtonTitle
        }
    }

    private func presentCreateInput() {
        self.inputText = ""
        self.inputMode = .create
    }

    private func handleActionMenuDismissed() {
        guard let pendingMenuAction else { return }
        self.pendingMenuAction = nil

        switch pendingMenuAction {
        case let .edit(item):
            self.inputText = self.editText(item)
            self.inputMode = .edit(item)
        case let .delete(item):
            self.onDelete(item)
        }
    }

    private func submitInput() {
        guard let inputMode else { return }
        let submittedText = self.inputText
        self.resetInput()

        switch inputMode {
        case .create:
            self.onCreate(submittedText)
        case let .edit(item):
            self.onEdit(item, submittedText)
        }
    }

    private func resetInput() {
        self.inputMode = nil
        self.inputText = ""
    }
}

public extension DawnEditableManagementSurface where RowContent == DawnManagementRow<Image> {
    init(
        title: String,
        presentationMode: DawnManagementPresentationMode = .sheet,
        items: [Item],
        itemTitle: @escaping (Item) -> String,
        itemDetail: @escaping (Item) -> String? = { _ in nil },
        editText: ((Item) -> String)? = nil,
        rowHeight: CGFloat = 56,
        isLoading: Bool = false,
        addButtonTitle: String? = nil,
        addButtonSystemImage: String = "plus",
        autoScrollToInsertedItem: Bool = true,
        editConfiguration: DawnManagementEditConfiguration = DawnManagementEditConfiguration(),
        onDismiss: (() -> Void)? = nil,
        onCreate: @escaping (String) -> Void,
        onEdit: @escaping (Item, String) -> Void,
        onDelete: @escaping (Item) -> Void,
        onMove: ((IndexSet, Int) -> Void)? = nil,
        @ViewBuilder emptyContent: @escaping () -> EmptyContent,
        @ViewBuilder principalContent: @escaping () -> PrincipalContent,
        @ViewBuilder loadingContent: @escaping () -> LoadingContent
    ) {
        self.init(
            title: title,
            presentationMode: presentationMode,
            items: items,
            itemTitle: itemTitle,
            editText: editText,
            rowHeight: rowHeight,
            isLoading: isLoading,
            addButtonTitle: addButtonTitle,
            addButtonSystemImage: addButtonSystemImage,
            autoScrollToInsertedItem: autoScrollToInsertedItem,
            editConfiguration: editConfiguration,
            onDismiss: onDismiss,
            onCreate: onCreate,
            onEdit: onEdit,
            onDelete: onDelete,
            onMove: onMove
        ) { item, showMenu in
            DawnManagementRow(
                title: itemTitle(item),
                detail: itemDetail(item),
                onMenuTapped: showMenu
            )
        } emptyContent: {
            emptyContent()
        } principalContent: {
            principalContent()
        } loadingContent: {
            loadingContent()
        }
    }
}

private extension DawnEditableManagementSurface {
    enum MenuAction {
        case edit(Item)
        case delete(Item)
    }

    enum InputMode {
        case create
        case edit(Item)
    }
}

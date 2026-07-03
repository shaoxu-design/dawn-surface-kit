import ComposableArchitecture
import DawnSurfaceKit
import SwiftUI

public struct DawnEditableManagementStoreSurface<
    State: ObservableState,
    Action,
    Item: Identifiable,
    RowContent: View,
    EmptyContent: View,
    PrincipalContent: View,
    LoadingContent: View
>: View {
    public let store: Store<State, Action>
    public var presentationMode: DawnManagementPresentationMode
    public let title: (State) -> String
    public let items: (State) -> [Item]
    public let itemTitle: (Item) -> String
    public let editText: (Item) -> String
    public let rowHeight: CGFloat
    public let isLoading: (State) -> Bool
    public let addButtonTitle: (State) -> String?
    public let addButtonSystemImage: String
    public let autoScrollToInsertedItem: Bool
    public let editConfiguration: (State) -> DawnManagementEditConfiguration
    public let onAppear: Action?
    public let onDisappear: Action?
    public let onDismiss: Action?
    public let onCreate: (String) -> Action
    public let onEdit: (Item, String) -> Action
    public let onDelete: (Item) -> Action
    public let onMove: ((IndexSet, Int) -> Action)?
    public let rowContent: (Item, Store<State, Action>, @escaping () -> Void) -> RowContent
    public let emptyContent: (Store<State, Action>) -> EmptyContent
    public let principalContent: (Store<State, Action>) -> PrincipalContent
    public let loadingContent: (Store<State, Action>) -> LoadingContent

    public init(
        store: Store<State, Action>,
        presentationMode: DawnManagementPresentationMode = .sheet,
        title: @escaping (State) -> String,
        items: @escaping (State) -> [Item],
        itemTitle: @escaping (Item) -> String,
        editText: ((Item) -> String)? = nil,
        rowHeight: CGFloat = 56,
        isLoading: @escaping (State) -> Bool = { _ in false },
        addButtonTitle: @escaping (State) -> String? = { _ in nil },
        addButtonSystemImage: String = "plus",
        autoScrollToInsertedItem: Bool = true,
        editConfiguration: @escaping (State) -> DawnManagementEditConfiguration = { _ in DawnManagementEditConfiguration() },
        onAppear: Action? = nil,
        onDisappear: Action? = nil,
        onDismiss: Action? = nil,
        onCreate: @escaping (String) -> Action,
        onEdit: @escaping (Item, String) -> Action,
        onDelete: @escaping (Item) -> Action,
        onMove: ((IndexSet, Int) -> Action)? = nil,
        @ViewBuilder rowContent: @escaping (Item, Store<State, Action>, @escaping () -> Void) -> RowContent,
        @ViewBuilder emptyContent: @escaping (Store<State, Action>) -> EmptyContent,
        @ViewBuilder principalContent: @escaping (Store<State, Action>) -> PrincipalContent,
        @ViewBuilder loadingContent: @escaping (Store<State, Action>) -> LoadingContent
    ) {
        self.store = store
        self.presentationMode = presentationMode
        self.title = title
        self.items = items
        self.itemTitle = itemTitle
        self.editText = editText ?? itemTitle
        self.rowHeight = rowHeight
        self.isLoading = isLoading
        self.addButtonTitle = addButtonTitle
        self.addButtonSystemImage = addButtonSystemImage
        self.autoScrollToInsertedItem = autoScrollToInsertedItem
        self.editConfiguration = editConfiguration
        self.onAppear = onAppear
        self.onDisappear = onDisappear
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
        DawnEditableManagementSurface(
            title: self.title(self.store.state),
            presentationMode: self.presentationMode,
            items: self.items(self.store.state),
            itemTitle: self.itemTitle,
            editText: self.editText,
            rowHeight: self.rowHeight,
            isLoading: self.isLoading(self.store.state),
            addButtonTitle: self.addButtonTitle(self.store.state),
            addButtonSystemImage: self.addButtonSystemImage,
            autoScrollToInsertedItem: self.autoScrollToInsertedItem,
            editConfiguration: self.editConfiguration(self.store.state),
            onDismiss: {
                if let onDismiss {
                    self.store.send(onDismiss)
                }
            },
            onCreate: { name in
                self.store.send(self.onCreate(name))
            },
            onEdit: { item, name in
                self.store.send(self.onEdit(item, name))
            },
            onDelete: { item in
                self.store.send(self.onDelete(item))
            },
            onMove: self.onMove.map { actionFactory in
                { source, destination in
                    self.store.send(actionFactory(source, destination))
                }
            }
        ) { item, showMenu in
            self.rowContent(item, self.store, showMenu)
        } emptyContent: {
            self.emptyContent(self.store)
        } principalContent: {
            self.principalContent(self.store)
        } loadingContent: {
            self.loadingContent(self.store)
        }
        .onAppear {
            if let onAppear {
                self.store.send(onAppear)
            }
        }
        .onDisappear {
            if let onDisappear {
                self.store.send(onDisappear)
            }
        }
    }
}

public extension DawnEditableManagementStoreSurface where RowContent == DawnManagementRow<Image> {
    init(
        store: Store<State, Action>,
        presentationMode: DawnManagementPresentationMode = .sheet,
        title: @escaping (State) -> String,
        items: @escaping (State) -> [Item],
        itemTitle: @escaping (Item) -> String,
        itemDetail: @escaping (Item) -> String? = { _ in nil },
        editText: ((Item) -> String)? = nil,
        rowHeight: CGFloat = 56,
        isLoading: @escaping (State) -> Bool = { _ in false },
        addButtonTitle: @escaping (State) -> String? = { _ in nil },
        addButtonSystemImage: String = "plus",
        autoScrollToInsertedItem: Bool = true,
        editConfiguration: @escaping (State) -> DawnManagementEditConfiguration = { _ in DawnManagementEditConfiguration() },
        onAppear: Action? = nil,
        onDisappear: Action? = nil,
        onDismiss: Action? = nil,
        onCreate: @escaping (String) -> Action,
        onEdit: @escaping (Item, String) -> Action,
        onDelete: @escaping (Item) -> Action,
        onMove: ((IndexSet, Int) -> Action)? = nil,
        @ViewBuilder emptyContent: @escaping (Store<State, Action>) -> EmptyContent,
        @ViewBuilder principalContent: @escaping (Store<State, Action>) -> PrincipalContent,
        @ViewBuilder loadingContent: @escaping (Store<State, Action>) -> LoadingContent
    ) {
        self.init(
            store: store,
            presentationMode: presentationMode,
            title: title,
            items: items,
            itemTitle: itemTitle,
            editText: editText,
            rowHeight: rowHeight,
            isLoading: isLoading,
            addButtonTitle: addButtonTitle,
            addButtonSystemImage: addButtonSystemImage,
            autoScrollToInsertedItem: autoScrollToInsertedItem,
            editConfiguration: editConfiguration,
            onAppear: onAppear,
            onDisappear: onDisappear,
            onDismiss: onDismiss,
            onCreate: onCreate,
            onEdit: onEdit,
            onDelete: onDelete,
            onMove: onMove
        ) { item, _, showMenu in
            DawnManagementRow(
                title: itemTitle(item),
                detail: itemDetail(item),
                onMenuTapped: showMenu
            )
        } emptyContent: { store in
            emptyContent(store)
        } principalContent: { store in
            principalContent(store)
        } loadingContent: { store in
            loadingContent(store)
        }
    }
}

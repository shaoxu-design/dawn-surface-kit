import ComposableArchitecture
import DawnSurfaceKit
import SwiftUI

public struct DawnManagementStoreSurface<
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
    public let rowHeight: CGFloat
    public let isLoading: (State) -> Bool
    public let addButtonTitle: (State) -> String?
    public let addButtonSystemImage: String
    public let autoScrollToInsertedItem: Bool
    public let onAppear: Action?
    public let onDisappear: Action?
    public let onDismiss: Action?
    public let onAddTapped: Action?
    public let onMove: ((IndexSet, Int) -> Action)?
    public let rowContent: (Item, Store<State, Action>) -> RowContent
    public let emptyContent: (Store<State, Action>) -> EmptyContent
    public let principalContent: (Store<State, Action>) -> PrincipalContent
    public let loadingContent: (Store<State, Action>) -> LoadingContent

    public init(
        store: Store<State, Action>,
        presentationMode: DawnManagementPresentationMode = .sheet,
        title: @escaping (State) -> String,
        items: @escaping (State) -> [Item],
        rowHeight: CGFloat = 56,
        isLoading: @escaping (State) -> Bool = { _ in false },
        addButtonTitle: @escaping (State) -> String? = { _ in nil },
        addButtonSystemImage: String = "plus",
        autoScrollToInsertedItem: Bool = true,
        onAppear: Action? = nil,
        onDisappear: Action? = nil,
        onDismiss: Action? = nil,
        onAddTapped: Action? = nil,
        onMove: ((IndexSet, Int) -> Action)? = nil,
        @ViewBuilder rowContent: @escaping (Item, Store<State, Action>) -> RowContent,
        @ViewBuilder emptyContent: @escaping (Store<State, Action>) -> EmptyContent,
        @ViewBuilder principalContent: @escaping (Store<State, Action>) -> PrincipalContent,
        @ViewBuilder loadingContent: @escaping (Store<State, Action>) -> LoadingContent
    ) {
        self.store = store
        self.presentationMode = presentationMode
        self.title = title
        self.items = items
        self.rowHeight = rowHeight
        self.isLoading = isLoading
        self.addButtonTitle = addButtonTitle
        self.addButtonSystemImage = addButtonSystemImage
        self.autoScrollToInsertedItem = autoScrollToInsertedItem
        self.onAppear = onAppear
        self.onDisappear = onDisappear
        self.onDismiss = onDismiss
        self.onAddTapped = onAddTapped
        self.onMove = onMove
        self.rowContent = rowContent
        self.emptyContent = emptyContent
        self.principalContent = principalContent
        self.loadingContent = loadingContent
    }

    public var body: some View {
        DawnManagementSurface(
            title: self.title(self.store.state),
            presentationMode: self.presentationMode,
            items: self.items(self.store.state),
            rowHeight: self.rowHeight,
            isLoading: self.isLoading(self.store.state),
            addButtonTitle: self.addButtonTitle(self.store.state),
            addButtonSystemImage: self.addButtonSystemImage,
            autoScrollToInsertedItem: self.autoScrollToInsertedItem,
            onDismiss: {
                if let onDismiss {
                    self.store.send(onDismiss)
                }
            },
            onAddTapped: self.onAddTapped.map { action in
                { self.store.send(action) }
            },
            onMove: self.onMove.map { actionFactory in
                { source, destination in
                    self.store.send(actionFactory(source, destination))
                }
            }
        ) { item in
            self.rowContent(item, self.store)
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

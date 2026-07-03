@testable import DawnSurfaceTCA
import ComposableArchitecture
import DawnSurfaceKit
import SwiftUI
import Testing

@Suite(.serialized)
struct DawnManagementStoreSurfaceTests {
    struct Item: Identifiable, Equatable {
        let id: String
        let title: String
    }

    @Reducer
    struct HarnessFeature {
        @ObservableState
        struct State: Equatable {
            var items = [
                Item(id: "purchase", title: "购买渠道"),
                Item(id: "sell", title: "售出渠道"),
            ]
            var isLoading = false
        }

        enum Action: Equatable {
            case onAppear
            case dismissButtonTapped
            case addButtonTapped
            case move(IndexSet, Int)
            case menuTapped(String)
            case createSubmitted(String)
            case editSubmitted(String, String)
            case deleteTapped(String)
        }

        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .move(let source, let destination):
                    state.items.move(fromOffsets: source, toOffset: destination)
                    return .none

                case .onAppear,
                     .dismissButtonTapped,
                     .addButtonTapped,
                     .menuTapped,
                     .createSubmitted,
                     .editSubmitted,
                     .deleteTapped:
                    return .none
                }
            }
        }
    }

    @Test("store surface adapter compiles with action mapping")
    @MainActor
    func storeSurfaceAdapterCompilesWithActionMapping() {
        let store = Store(initialState: HarnessFeature.State()) {
            HarnessFeature()
        }

        let surface = DawnManagementStoreSurface(
            store: store,
            presentationMode: .sheet,
            title: { _ in "渠道管理" },
            items: \.items,
            isLoading: \.isLoading,
            addButtonTitle: { _ in "创建渠道" },
            onAppear: .onAppear,
            onDismiss: .dismissButtonTapped,
            onAddTapped: .addButtonTapped,
            onMove: { source, destination in .move(source, destination) }
        ) { item, store in
            DawnManagementRow(
                title: item.title,
                onMenuTapped: { store.send(.menuTapped(item.id)) }
            )
        } emptyContent: { _ in
            Text("暂无渠道")
        } principalContent: { _ in
            EmptyView()
        } loadingContent: { _ in
            ProgressView()
        }

        _ = surface
    }

    @Test("editable store surface adapter compiles with create edit delete action mapping")
    @MainActor
    func editableStoreSurfaceAdapterCompilesWithCreateEditDeleteActionMapping() {
        let store = Store(initialState: HarnessFeature.State()) {
            HarnessFeature()
        }

        let surface = DawnEditableManagementStoreSurface(
            store: store,
            presentationMode: .sheet,
            title: { _ in "渠道管理" },
            items: \.items,
            itemTitle: \.title,
            isLoading: \.isLoading,
            addButtonTitle: { _ in "创建渠道" },
            editConfiguration: { _ in
                DawnManagementEditConfiguration(
                    createTitle: "创建渠道",
                    editTitle: "编辑渠道",
                    inputPlaceholder: "例如：Discord",
                    createButtonTitle: "创建",
                    editButtonTitle: "确定",
                    menuEditTitle: "编辑",
                    menuDeleteTitle: "删除"
                )
            },
            onAppear: .onAppear,
            onDismiss: .dismissButtonTapped,
            onCreate: { .createSubmitted($0) },
            onEdit: { item, name in .editSubmitted(item.id, name) },
            onDelete: { item in .deleteTapped(item.id) },
            onMove: { source, destination in .move(source, destination) }
        ) { item, store, showMenu in
            DawnManagementRow(
                title: item.title,
                onMenuTapped: {
                    store.send(.menuTapped(item.id))
                    showMenu()
                }
            )
        } emptyContent: { _ in
            Text("暂无渠道")
        } principalContent: { _ in
            EmptyView()
        } loadingContent: { _ in
            ProgressView()
        }

        _ = surface
    }
}

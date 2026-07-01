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
        }

        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .move(let source, let destination):
                    state.items.move(fromOffsets: source, toOffset: destination)
                    return .none

                case .onAppear, .dismissButtonTapped, .addButtonTapped, .menuTapped:
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
}

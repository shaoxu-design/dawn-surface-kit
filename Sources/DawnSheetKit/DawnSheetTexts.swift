import SwiftUI

public struct DawnSheetTexts: Equatable, Sendable {
    public var cancel: String
    public var done: String
    public var reset: String
    public var manage: String

    public static let `default` = DawnSheetTexts()

    public init(
        cancel: String = "取消",
        done: String = "完成",
        reset: String = "重置",
        manage: String = "管理"
    ) {
        self.cancel = cancel
        self.done = done
        self.reset = reset
        self.manage = manage
    }
}

private struct DawnSheetTextsKey: EnvironmentKey {
    static let defaultValue = DawnSheetTexts.default
}

public extension EnvironmentValues {
    var dawnSheetTexts: DawnSheetTexts {
        get { self[DawnSheetTextsKey.self] }
        set { self[DawnSheetTextsKey.self] = newValue }
    }
}

public extension View {
    func dawnSheetTexts(_ texts: DawnSheetTexts) -> some View {
        self.environment(\.dawnSheetTexts, texts)
    }
}

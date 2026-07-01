import SwiftUI

public struct DawnSurfaceTexts: Equatable, Sendable {
    public var cancel: String
    public var done: String
    public var reset: String
    public var manage: String

    public static let `default` = DawnSurfaceTexts()

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

private struct DawnSurfaceTextsKey: EnvironmentKey {
    static let defaultValue = DawnSurfaceTexts.default
}

public extension EnvironmentValues {
    var dawnSurfaceTexts: DawnSurfaceTexts {
        get { self[DawnSurfaceTextsKey.self] }
        set { self[DawnSurfaceTextsKey.self] = newValue }
    }
}

public extension View {
    func dawnSurfaceTexts(_ texts: DawnSurfaceTexts) -> some View {
        self.environment(\.dawnSurfaceTexts, texts)
    }
}

import SwiftUI

extension Pose {
    var top: CGFloat {
        let pixel = Style.unit / 2
        let head = 52.5 + lift
        var top: CGFloat = 0
        for item in items where abs(item.x) <= 130 && item.opacity >= 0.3 {
            top = max(top, item.up + item.art.size.height * pixel * item.scale / 2)
        }
        if flag { top = max(top, head + 6.8 * Style.unit) }
        if bulb != nil { top = max(top, head + 6.8 * Style.unit) }
        return top
    }
}

extension Action {
    var headroom: CGFloat { Self.headrooms[self] ?? 0 }

    private static let headrooms: [Action: CGFloat] = Dictionary(uniqueKeysWithValues: allCases.map { ($0, measure($0)) })

    private static func measure(_ action: Action) -> CGFloat {
        guard action.duration.isFinite, action.duration <= 30 else { return 0 }
        if action == .contextFull { return 100 }
        let fps = 20.0
        let tops = (0...Int(action.duration * fps)).map { frame in
            let t = Double(frame) / fps
            return Pose(action: action, t: t, clock: 1000 + t).top
        }.sorted()
        let top = tops[Int(Double(tops.count - 1) * 0.7)]
        return top > 0 ? min(260, top + 8) : 0
    }
}

import Foundation

enum Workout {
    static let duration = 7.9

    private static func tilted(_ lift: CGFloat) -> Pose.Ring { Pose.Ring(x: 6.3, y: -1 - lift, w: 8, h: 1.6, angle: -0.25) }
    private static let pocket = Pose.Ring(x: 1.2, y: 4.4, w: 0.4, h: 0.4, opacity: 0)
    private static let grab = Pose.Ring(x: 0.45, y: 5.65, w: 0.75, h: 0.55)
    private static let grabUp = Pose.Ring(x: 0.4, y: 0.35, w: 0.65, h: 0.55)
    private static let raised = Pose.Ring(x: 2.5, y: -2.7, w: 1.3, h: 2.2)
    private static let line = Pose.Ring(x: 6, y: 0.74, w: 10, h: 0)
    private static let head = Pose.Ring(x: 6, y: 0.74, w: 8, h: 0)
    private static let hand = Pose.Ring(x: -0.3, y: 4.4, w: 1.2, h: 1.8)
    private static let hanging = Pose.Ring(x: 0.4, y: 6.7, w: 1.0, h: 1.5)
    private static let away = Pose.Ring(x: 1.2, y: 4.6, w: 0.3, h: 0.3, opacity: 0)
    private static let track: [(TimeInterval, Pose.Ring)] = [
        (0.15, pocket), (0.4, grab), (0.62, grabUp), (0.9, raised), (1.25, tilted(0.7)), (1.55, tilted(0)), (1.75, line), (1.95, head),
        (6.15, head), (6.3, line), (6.4, tilted(0)), (6.8, tilted(0.9)), (7.0, raised), (7.3, hand), (7.6, hanging), (7.85, away),
    ]

    static func band(_ t: TimeInterval) -> Pose.Ring? {
        guard let next = track.firstIndex(where: { $0.0 >= t }), next > 0 else { return nil }
        let (start, a) = track[next - 1]
        let (end, b) = track[next]
        let p = Pose.ease(CGFloat((t - start) / (end - start)))
        func mix(_ x: CGFloat, _ y: CGFloat) -> CGFloat { x + (y - x) * p }
        return Pose.Ring(x: mix(a.x, b.x), y: mix(a.y, b.y), w: mix(a.w, b.w), h: mix(a.h, b.h), angle: mix(a.angle, b.angle), opacity: mix(a.opacity, b.opacity))
    }
}

extension Pose {
    mutating func workout(t: TimeInterval) {
        func lift(_ side: Bool) {
            band = .head
            bells = .sides
            left = side ? .side : .up
            right = side ? .up : .side
            look = side ? 0.3 : -0.3
        }
        func squat(holding: Bool) {
            left = holding ? .hidden : .side
            right = holding ? .hidden : .side
            sy = 0.84
            sx = 1.06
            legLength = 0.8
            eyes = .happy
        }
        switch t {
        case ..<0.25:
            left = .tucked
            look = -0.5
        case ..<0.45:
            left = .diagDown
            band = .grab
            look = -0.5
            bob = 0.15
            sy = 0.97
        case ..<0.7:
            left = .diagUp
            band = .grabUp
            look = -0.4
        case ..<1.0:
            left = .up
            band = .raised
            sy = 1.03
        case ..<1.4:
            left = .diagUp
            right = .diagUp
            band = .tilted(0.7)
            sy = 1.03
        case ..<1.6:
            left = .diagUp
            right = .diagUp
            band = .tilted(0.7 * CGFloat(1 - (t - 1.4) / 0.2))
        case ..<1.8:
            left = .diagUp
            right = .diagUp
            band = .line
            sy = 0.94
            sx = 1.03
        case ..<2.3:
            left = .diagUp
            right = .diagUp
            band = .head
            eyes = .happy
            bob = Int(t / 0.12) % 2 == 0 ? -0.15 : 0
        case ..<2.6:
            band = .head
            bells = .sides
            squat(holding: true)
        case ..<5.6:
            if (4.1..<4.4).contains(t) {
                band = .head
                bells = .sides
                squat(holding: true)
            } else if (t - 2.6).truncatingRemainder(dividingBy: 0.6) < 0.12 && t > 2.7 {
                bells = .sides
                left = .diagUp
                right = .diagUp
            } else {
                lift(Int((t - 2.6) / 0.6) % 2 == 0)
            }
        case ..<5.9:
            band = .head
            bells = .floor
            squat(holding: false)
        case ..<6.2:
            left = .diagUp
            right = .diagUp
            band = .head
        case ..<6.4:
            left = .diagUp
            right = .diagUp
            band = .line
            sy = 1.02
        case ..<6.8:
            left = .diagUp
            right = .diagUp
            band = .tilted(0.9 * CGFloat((t - 6.4) / 0.4))
            sy = 1.03
        case ..<7.1:
            left = .up
            band = .raised
        case ..<7.4:
            band = .hand
            look = -0.4
        case ..<7.7:
            left = .diagDown
            band = .hanging
            look = -0.5
            bob = 0.12
        default:
            left = .tucked
        }
        band = Workout.band(t).map { .ring($0) } ?? .none
    }
}

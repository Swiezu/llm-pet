import Foundation

enum Workout {
    static let duration = 7.9
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
    }
}

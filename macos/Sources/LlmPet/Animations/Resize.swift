import Foundation

extension Pose {
    mutating func resize(growing: Bool, clock: TimeInterval) {
        let shake: CGFloat = Int(clock / 0.05) % 2 == 0 ? 0.5 : -0.5
        if growing {
            eyes = .focused
            left = .up
            right = .up
            aura = 0.8
            sy = 1.05
            sx = 0.97
            dx = shake
        } else {
            eyes = .closed
            left = .tucked
            right = .tucked
            sweat = true
            sy = 0.9
            sx = 1.06
            dx = shake * 0.6
        }
    }
}

import SwiftUI

extension Pose {
    func point(_ ux: CGFloat, _ uy: CGFloat) -> CGPoint {
        let u = Style.unit
        let size = CGSize(width: Style.canvas.width * u, height: Style.canvas.height * u)
        return CGPoint(x: (Style.origin.x + ux) * u - size.width / 2 + dx, y: size.height - (Style.origin.y + uy + bob) * u - 0.5 * u + lift)
    }

    mutating func place(_ art: PixelArt, _ x: CGFloat, _ up: CGFloat, opacity: Double = 1, scale: CGFloat = 1, behind: Bool = false) {
        items.append(Item(art: art, x: x, up: up, opacity: opacity, scale: scale, behind: behind))
    }

    mutating func place(_ art: PixelArt, at point: CGPoint, opacity: Double = 1, scale: CGFloat = 1, behind: Bool = false) {
        place(art, point.x, point.y, opacity: opacity, scale: scale, behind: behind)
    }

    mutating func dot(_ color: Character, _ x: CGFloat, _ up: CGFloat, size: Int = 1, opacity: Double = 1) {
        place(PixelArt(rows: Array(repeating: String(repeating: color, count: size), count: size)), x, up, opacity: opacity)
    }

    static func bar(_ fill: CGFloat, cells: Int = 10, blink: Bool = false) -> PixelArt {
        let lit = Int((fill * CGFloat(cells)).rounded())
        let color: Character = blink ? "i" : fill >= 0.8 ? "q" : fill >= 0.5 ? "y" : "e"
        let inner = (0..<cells).map { $0 < lit ? String(color) : "x" }.joined()
        let edge = String(repeating: "k", count: cells + 2)
        return PixelArt(rows: [edge, "k" + inner + "k", "k" + inner + "k", edge])
    }

    static func ease(_ p: CGFloat) -> CGFloat {
        let p = min(1, max(0, p))
        return p * p * (3 - 2 * p)
    }
}

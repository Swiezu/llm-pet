import SwiftUI

struct Pose {
    enum Eyes { case open, blink, happy, closed, wide, dizzy, focused, led }
    enum Arm: Equatable { case side, up, flail, hidden, diagUp, diagDown, tucked, reach(CGFloat), chin }
    enum Band { case none, grab, grabUp, hand, hanging, raised, tilted(CGFloat), line, head }
    enum Bells { case none, sides, floor }
    enum Letter { case raised, envelope, opening(CGFloat), reading }
    enum Paper { case sheet, folded(Int), plane, raised }
    enum Cup { case back, front }

    struct Keyboard {
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        var typing = false
    }

    struct Flying {
        enum Kind { case envelope, plane }
        var kind: Kind
        var x: CGFloat
        var up: CGFloat
        var frame = 0
        var opacity = 1.0
        var trail: [CGPoint] = []
    }

    struct Item {
        var art: PixelArt
        var x: CGFloat
        var up: CGFloat
        var opacity = 1.0
        var scale: CGFloat = 1
        var behind = false
    }

    struct Beam {
        var thickness: CGFloat
        var length: CGFloat
        var flash: CGFloat?
        var power: CGFloat = 1
    }

    var lift: CGFloat = 0
    var dx: CGFloat = 0
    var hidden = false
    var mask: CGFloat?
    var keyboard: Keyboard?
    var dust: CGFloat?
    var tilt: Double = 0
    var tiltAnchor = UnitPoint.bottom
    var carried = false
    var sx: CGFloat = 1
    var sy: CGFloat = 1
    var legs: [CGFloat] = [0, 0, 0, 0]
    var legLength: CGFloat = 1.2
    var bob: CGFloat = 0
    var eyes = Eyes.open
    var look: CGFloat = 0
    var lookY: CGFloat = 0
    var left = Arm.side
    var right = Arm.side
    var flag = false
    var band = Band.none
    var bells = Bells.none
    var narrow = false
    var flip = false
    var stars = false
    var notes = false
    var steam = false
    var exclaim = false
    var thought = 0
    var aura: CGFloat = 0
    var pebble: CGFloat?
    var bulb: CGFloat?
    var heart: CGFloat?
    var letter: Letter?
    var paper: Paper?
    var flying: Flying?
    var cup: Cup?
    var charge: CGFloat?
    var beam: Beam?
    var rubble: CGFloat?
    var flames: CGFloat = 0
    var hair: CGFloat = 0
    var sparks = false
    var ssj = false
    var sweat = false
    var items: [Item] = []
    var shockwave: CGFloat?
}

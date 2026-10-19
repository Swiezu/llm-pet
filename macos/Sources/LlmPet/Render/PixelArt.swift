import SwiftUI

struct PixelArt {
    let rows: [String]

    var size: CGSize { CGSize(width: rows.map(\.count).max() ?? 0, height: rows.count) }

    func draw(_ context: GraphicsContext, x: CGFloat, y: CGFloat, pixel: CGFloat, opacity: Double = 1) {
        for (row, line) in rows.enumerated() {
            for (column, key) in line.enumerated() {
                guard let color = Self.palette[key] else { continue }
                context.fill(Path(CGRect(x: x + CGFloat(column) * pixel, y: y + CGFloat(row) * pixel, width: pixel, height: pixel)), with: .color(color.opacity(opacity)))
            }
        }
    }

    func draw(_ context: GraphicsContext, center: CGPoint, pixel: CGFloat, opacity: Double = 1) {
        let snap = { (value: CGFloat) in (value / pixel).rounded() * pixel }
        draw(context, x: snap(center.x - size.width * pixel / 2), y: snap(center.y - size.height * pixel / 2), pixel: pixel, opacity: opacity)
    }

    private static let palette: [Character: Color] = [
        "k": .black.opacity(0.8),
        "w": Style.paper,
        "s": Style.paperLine,
        "c": Style.coral,
        "d": Style.shade,
        "l": Style.light,
        "y": Style.bulb,
        "o": Style.bulbGlow,
        "g": Style.keyboardRim,
        "r": Style.heart,
        "m": Style.manilla,
        "i": Style.ivory,
        "b": Style.kraft,
        "n": Style.coffee,
        "x": Style.slate,
        "e": Style.ok,
        "q": Style.alarm,
        "u": Style.cardboard,
        "v": Style.cardboardDark,
        "a": Style.water,
        "t": Style.led,
        "h": Style.metal,
        "j": Style.metalDark,
        "f": Style.flame,
        "p": Style.smoke,
    ]
}

enum Art {
    static let envelope = PixelArt(rows: [
        "kkkkkkkkkk",
        "kwswwwwswk",
        "kwwswwswwk",
        "kwwwsswwwk",
        "kwwwccwwwk",
        "kwwwwwwwwk",
        "kkkkkkkkkk",
    ])
    static let envelopeTilted = PixelArt(rows: [
        "....kkkkkk",
        "kkkkwwwswk",
        "kwswwwswwk",
        "kwwsswcwwk",
        "kwwwwwwwkk",
        "kwwwwkkkk.",
        "kkkkk.....",
    ])
    static let envelopeOpen = [
        PixelArt(rows: [
            "....kk....",
            "..kkwwkk..",
            "kkwwwwwwkk",
            "kwwwccwwwk",
            "kwwwwwwwwk",
            "kwwwwwwwwk",
            "kkkkkkkkkk",
        ]),
        PixelArt(rows: [
            "..kkkkkk..",
            "..kwsswk..",
            "kkkwwwwkkk",
            "kwwkccwwwk",
            "kwwwwwwwwk",
            "kwwwwwwwwk",
            "kkkkkkkkkk",
        ]),
    ]
    static let page = PixelArt(rows: [
        "kkkkkkkk",
        "kwsssswk",
        "kwwwwwwk",
        "kwssswwk",
        "kwwwwwwk",
        "kwsswrwk",
        "kkkkkkkk",
    ])
    static let sheet = PixelArt(rows: [
        "kkkkkkkkkk",
        "kwwwwwwwwk",
        "kwwwwwwwwk",
        "kwwwwwwwwk",
        "kwwwwwwwwk",
        "kkkkkkkkkk",
    ])
    static let folds = [
        PixelArt(rows: [
            "kkkkkkkkkk",
            "kwwwswwwwk",
            "kwwwswwwwk",
            "kwwwswwwwk",
            "kwwwswwwwk",
            "kkkkkkkkkk",
        ]),
        PixelArt(rows: [
            "..kkkkkkkk",
            ".kwwwwwwwk",
            "kwswwwwwwk",
            "kwwswwwwwk",
            "kwwwswwwwk",
            "kkkkkkkkkk",
        ]),
        PixelArt(rows: [
            "....kkkkkk",
            "..kkwwwwwk",
            "kkwwwswwwk",
            ".kkwwwwswk",
            "...kkkkkkk",
        ]),
    ]
    static let plane = [
        PixelArt(rows: [
            ".........kk",
            ".....kkkkwk",
            "kkkkkwwwwwk",
            ".kswwwwwkk.",
            "...kssk....",
        ]),
        PixelArt(rows: [
            "..........k",
            "........kkk",
            "....kkkkwwk",
            "kkkkwwwwwk.",
            ".kswwwwkk..",
            "..kssk.....",
        ]),
        PixelArt(rows: [
            "kk.........",
            ".kkkk......",
            "..kwwwkkkk.",
            "...kwwwwwwk",
            "....kssswkk",
            "......kk...",
        ]),
    ]
    static let bulb = PixelArt(rows: [
        "..yyy..",
        ".yyoyy.",
        "yyoooyy",
        "yyoooyy",
        ".yyoyy.",
        "..ggg..",
        "..ggg..",
    ])
    static let heart = PixelArt(rows: [
        ".rr.rr.",
        "rrrrrrr",
        "rrrrrrr",
        ".rrrrr.",
        "..rrr..",
        "...r...",
    ])
    static let star = PixelArt(rows: [
        ".y.",
        "yyy",
        ".y.",
    ])
    static let note = PixelArt(rows: [
        "..kk",
        "..kk",
        "..k.",
        "kkk.",
        "kk..",
    ])
    static let exclaim = PixelArt(rows: [
        "cc",
        "cc",
        "cc",
        "cc",
        "..",
        "cc",
    ])
    static let spark = [
        PixelArt(rows: [
            "....c....",
            ".c..c..c.",
            "..c.c.c..",
            "...clc...",
            "cccclcccc",
            "...clc...",
            "..c.c.c..",
            ".c..c..c.",
            "....c....",
        ]),
        PixelArt(rows: [
            "..c...c..",
            "...c.c...",
            "c..ccc..c",
            ".cclllcc.",
            "...clc...",
            ".cclllcc.",
            "c..ccc..c",
            "...c.c...",
            "..c...c..",
        ]),
    ]
}

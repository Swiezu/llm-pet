extension Art {
    static let mug = PixelArt(rows: [
        "kkkkkk..",
        "kxxxxk..",
        "kiiiikkk",
        "kcccck.k",
        "kiiiikkk",
        "kiiiik..",
        ".kkkk...",
    ])
    static let mugFull = PixelArt(rows: [
        "kkkkkk..",
        "knnnnk..",
        "kiiiikkk",
        "kcccck.k",
        "kiiiikkk",
        "kiiiik..",
        ".kkkk...",
    ])
    static let mugTilted = PixelArt(rows: [
        "...kkkk..",
        ".kknnik..",
        "kiiiiikkk",
        "kcccck..k",
        "kiiiikkkk",
        ".kiiik...",
        "..kkk....",
    ])
    static let kettle = PixelArt(rows: [
        "....kkkk..",
        "....kjjk..",
        "..kkkkkkkk",
        "kkkhhhhhhk",
        ".kkhhhhhhkkk",
        "..khhhhhhk.k",
        "..khhhhhhkkk",
        "..kjjjjjjk",
        "..kkkkkkkk",
    ])
    static let remote = PixelArt(rows: [
        "kkkk",
        "kqqk",
        "kqqk",
        "kjjk",
        "kjjk",
        "kkkk",
    ])
    static let rocket = PixelArt(rows: [
        "....kk....",
        "...kqqk...",
        "..kqqqqk..",
        "..kiiiik..",
        ".kiiiiiik.",
        ".kiikkiik.",
        ".kiktakik.",
        ".kiikkiik.",
        ".kiiiiiik.",
        ".kiccccik.",
        ".kiiiiiik.",
        "kkiiiiiikk",
        "kqkiiiikqk",
        "kqqkiikqqk",
        "kqqkjjkqqk",
        "kkk.jj.kkk",
    ])
    static let flames = [
        PixelArt(rows: [".fyyf.", "fyiiyf", ".fyyf.", "..ff..", "..f..."]),
        PixelArt(rows: [".fyyf.", "fyiiyf", "fyyyyf", ".ffff.", "...f.."]),
    ]
    static let flameBig = [
        PixelArt(rows: [".fyyyf.", "fyiiiyf", "fyiiiyf", ".fyyyf.", ".ffyff.", "..fff..", "..f.f..", "...f..."]),
        PixelArt(rows: [".fyyyf.", "fyiiiyf", "fyyiyyf", "ffyyyff", ".ffyff.", "..fff..", ".f.f...", "..f...."]),
    ]
    static let puff = PixelArt(rows: [".hh.", "hpph", "hpph", ".hh."])
    static let puffBig = PixelArt(rows: ["..hhh..", ".hppph.", "hpppiph", "hppppph", ".hppph.", "..hhh.."])
    static let digits: [Int: PixelArt] = [
        3: PixelArt(rows: ["kkkkk.", "kcccck", "kkkkck", ".kccck", "kkkkck", "kcccck", "kkkkk."]),
        2: PixelArt(rows: [".kkkk.", "kcccck", "kkkkck", ".kcck.", "kckkk.", "kcccck", "kkkkkk"]),
        1: PixelArt(rows: ["..kk..", ".kcck.", "kccck.", ".kcck.", ".kcck.", "kcccck", "kkkkkk"]),
    ]
    static let check = PixelArt(rows: [
        "......kk",
        ".....kek",
        "kk..keek",
        "kekkeek.",
        "keeeek..",
        ".keek...",
        "..kk....",
    ])
    static let token = ["m", "b", "i", "l"].map { PixelArt(rows: [String(repeating: $0, count: 4), String(repeating: $0, count: 4), "dddd"]) }
    static let zip = PixelArt(rows: [
        "kkkkkkk",
        "kmmjmmk",
        "kmmhmmk",
        "kbbjbbk",
        "kbbhbbk",
        "kbbjbbk",
        "kkkkkkk",
    ])
    static let antenna = PixelArt(rows: [
        "..t..",
        ".ttt.",
        "..t..",
        "..k..",
        "..k..",
        "..k..",
        "kkkkk",
    ])
    static let antennaOff = PixelArt(rows: [
        "..k..",
        ".kjk.",
        "..k..",
        "..k..",
        "..k..",
        "..k..",
        "kkkkk",
    ])
    static let binary = [
        PixelArt(rows: ["ttt", "t.t", "t.t", "t.t", "ttt"]),
        PixelArt(rows: [".t.", "tt.", ".t.", ".t.", "ttt"]),
    ]
    static let boxOpen = PixelArt(rows: [
        "k..........k",
        "kk........kk",
        "kuk......kuk",
        "kkkkkkkkkkkk",
        "kxxxxxxxxxxk",
        "kvuuuuuuuuvk",
        "kvuuuuuuuuvk",
        "kvuuuuuuuuvk",
        "kvuuuuuuuuvk",
        "kkkkkkkkkkkk",
    ])
    static let boxClosed = PixelArt(rows: [
        "kkkkkkkkkkkk",
        "kuuuuuuuuuuk",
        "kuuuuuuuuuuk",
        "kkkkkkkkkkkk",
        "kvuuuuuuuuvk",
        "kvuuuuuuuuvk",
        "kvuuuuuuuuvk",
        "kvuuuuuuuuvk",
        "kvuuuuuuuuvk",
        "kkkkkkkkkkkk",
    ])
    static let boxTaped = PixelArt(rows: [
        "kkkkkccckkkk",
        "kuuuuccuuuuk",
        "kuuuuccuuuuk",
        "kkkkkcckkkkk",
        "kvuuuccuuuvk",
        "kvuuuuuuuuvk",
        "kvuuuuuuuuvk",
        "kvuuuuuuuuvk",
        "kvuuuuuuuuvk",
        "kkkkkkkkkkkk",
    ])
    static let code = PixelArt(rows: [
        "kkkkkk",
        "kiiiik",
        "kciick",
        "kicick",
        "kciick",
        "kkkkkk",
    ])
    static let ship = PixelArt(rows: [
        ".......k......",
        ".......kk.....",
        ".......kik....",
        ".......kiik...",
        ".......kiiik..",
        ".......kiiiik.",
        ".......kkkkkkk",
        "kkkkkkkkkkkkkk",
        ".kcccccccccck.",
        "..kccccccccck.",
        "...kkkkkkkkk..",
    ])
    static let wave = [
        PixelArt(rows: ["..aa....aa....aa..", "aaaaaaaaaaaaaaaaaa"]),
        PixelArt(rows: ["....aa....aa....aa", "aaaaaaaaaaaaaaaaaa"]),
    ]
    static let sparkle = [
        PixelArt(rows: ["..i..", "..i..", "iiyii", "..i..", "..i.."]),
        PixelArt(rows: ["i...i", ".i.i.", "..y..", ".i.i.", "i...i"]),
    ]
}

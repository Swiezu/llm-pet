import AppKit
import SwiftUI

@MainActor
enum FrameDump {
    static func run(to directory: URL, frames: Int = 18) {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for action in Action.allCases where action.duration.isFinite {
            let times = (0..<frames).map { action.duration * Double($0) / Double(frames - 1) }
            let sheet = LazyVGrid(columns: Array(repeating: GridItem(.fixed(Pet.size.width * 0.6), spacing: 4), count: 6), spacing: 4) {
                ForEach(times, id: \.self) { t in
                    ZStack(alignment: .topLeading) {
                        PetFrame(pose: Pose(action: action, t: t, clock: 1000 + t), action: action, t: t, clock: 1000 + t, facing: 1, grounded: true)
                            .scaleEffect(0.6)
                            .frame(width: Pet.size.width * 0.6, height: Pet.size.height * 0.6)
                        Text(String(format: "%.2f s", t)).font(.caption.monospaced()).padding(4)
                    }
                    .background(Color(white: 0.86))
                }
            }
            .padding(4)
            .background(.white)
            let renderer = ImageRenderer(content: sheet)
            renderer.scale = 2
            guard let image = renderer.nsImage, let tiff = image.tiffRepresentation, let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:]) else { continue }
            try? png.write(to: directory.appending(path: "\(action.rawValue).png"))
        }
    }
}

import AppKit
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

@MainActor
enum DocsRender {
    static let background = Color(red: 0.93, green: 0.91, blue: 0.87)

    static func run(to directory: URL, fps: Double = 15) {
        let gifs = directory.appending(path: "animations")
        try? FileManager.default.createDirectory(at: gifs, withIntermediateDirectories: true)
        logo(to: directory.appending(path: "logo.png"))
        for action in Action.allCases where action.duration.isFinite {
            let count = Int(min(action.duration, 8) * fps) + 1
            let frames = (0..<count).compactMap { index -> CGImage? in
                let t = Double(index) / fps
                return image(PetFrame(pose: Pose(action: action, t: t, clock: 1000 + t), action: action, t: t, clock: 1000 + t, facing: 1, grounded: true).background(background), scale: 1)
            }
            gif(frames, delay: 1 / fps, to: gifs.appending(path: "\(action.rawValue).gif"))
        }
        resize(to: gifs.appending(path: "resize.gif"), fps: fps)
    }

    private static func resize(to url: URL, fps: Double) {
        let steps: [(start: Double, from: CGFloat, to: CGFloat)] = [(0, 1, 1.4), (1.3, 1.4, 0.7), (2.6, 0.7, 1)]
        let frames = (0..<Int(3.9 * fps)).compactMap { index -> CGImage? in
            let t = Double(index) / fps
            let step = steps.last { $0.start <= t } ?? steps[0]
            let local = t - step.start
            let scale = step.to + (step.from - step.to) * CGFloat(exp(-5.5 * local) * cos(11.8 * local))
            var pose = Pose()
            if local < 0.75 { pose.resize(growing: step.to > step.from, clock: 1000 + t) }
            let frame = PetFrame(pose: pose, action: .idle, t: t, clock: 1000 + t, facing: 1, grounded: true)
                .scaleEffect(scale, anchor: .bottom)
                .frame(width: Pet.size.width, height: Pet.size.height)
                .clipped()
                .background(background)
            return image(frame, scale: 1)
        }
        gif(frames, delay: 1 / fps, to: url)
    }

    private static func logo(to url: URL) {
        var pose = Pose()
        pose.eyes = .happy
        pose.right = .up
        let sprite = SpriteView(pose: pose, t: 0, clock: 0)
            .frame(width: Style.canvas.width * Style.unit, height: Style.canvas.height * Style.unit)
        guard let image = image(sprite, scale: 4).flatMap(trimmed), let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return }
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }

    private static func trimmed(_ image: CGImage) -> CGImage? {
        let width = image.width
        let height = image.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return image }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        var box = (minX: width, minY: height, maxX: 0, maxY: 0)
        for y in 0..<height {
            for x in 0..<width where pixels[(y * width + x) * 4 + 3] > 0 {
                box = (min(box.minX, x), min(box.minY, y), max(box.maxX, x), max(box.maxY, y))
            }
        }
        guard box.maxX >= box.minX else { return image }
        let pad = 8
        let rect = CGRect(x: max(0, box.minX - pad), y: max(0, box.minY - pad), width: min(width, box.maxX - box.minX + 1 + 2 * pad), height: min(height, box.maxY - box.minY + 1 + 2 * pad))
        return image.cropping(to: rect)
    }

    private static func image(_ view: some View, scale: CGFloat) -> CGImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        return renderer.cgImage
    }

    private static func gif(_ frames: [CGImage], delay: Double, to url: URL) {
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, frames.count, nil) else { return }
        CGImageDestinationSetProperties(destination, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary)
        let properties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: delay, kCGImagePropertyGIFUnclampedDelayTime: delay]] as CFDictionary
        for frame in frames { CGImageDestinationAddImage(destination, frame, properties) }
        CGImageDestinationFinalize(destination)
    }
}

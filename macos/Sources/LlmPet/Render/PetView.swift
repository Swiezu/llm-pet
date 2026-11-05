import LlmPetRender
import SwiftUI

struct PetView: View {
    let pet: Pet
    @State private var beat = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: AppSettings.shared.vsync ? nil : 1.0 / Double(AppSettings.shared.fps), paused: pet.calm)) { _ in
            let now = Date.now
            let _ = beat
            PetFrame(
                pose: Pose(pet: pet, now: now),
                action: pet.action,
                t: pet.elapsed(now),
                clock: pet.time(now),
                facing: pet.facing,
                grounded: !pet.held && !pet.falling
            )
            .scaleEffect(pet.scale, anchor: .bottom)
            .frame(width: pet.frameSize.width, height: pet.frameSize.height, alignment: .bottom)
            .drawingGroup()
        }
        .task(id: pet.calm) {
            while pet.calm, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(pet.untilIdleChange(.now)))
                beat += 1
            }
        }
        .onTapGesture { pet.poke() }
        .contextMenu { PetMenu() }
        .gesture(DragGesture(minimumDistance: 3).onChanged { _ in pet.hold() }.onEnded { _ in pet.release() })
        .help(tr("Click for a trick, drag to move, right-click for the menu", "Klik = sztuczka, przeciągnij = przenieś, prawy klik = menu"))
    }
}

struct GhostView: View {
    let action: Action
    let start: Date
    let clock: TimeInterval
    let speed: Double
    let facing: CGFloat
    let scale: CGFloat

    var body: some View {
        TimelineView(.animation) { _ in
            let t = Date.now.timeIntervalSince(start) * speed
            PetFrame(pose: Pose(action: action, t: t, clock: clock + t), action: action, t: t, clock: clock + t, facing: facing, grounded: true)
                .scaleEffect(scale, anchor: .bottom)
                .frame(width: PetFrame.size.width * scale, height: PetFrame.size.height * scale, alignment: .bottom)
                .drawingGroup()
        }
    }
}

extension Pose {
    @MainActor
    init(pet: Pet, now: Date) {
        let clock = pet.time(now)
        if !AppSettings.shared.animationsEnabled {
            self.init()
        } else if pet.held || pet.falling {
            self.init()
            carry(held: pet.held, clock: clock)
        } else if let landed = pet.landStart, now.timeIntervalSince(landed) < 0.3 {
            self.init()
            land(now.timeIntervalSince(landed))
        } else if now < pet.resizeUntil {
            self.init()
            resize(growing: pet.growing, clock: clock)
        } else {
            self.init(action: pet.action, t: pet.elapsed(now), clock: clock, walked: pet.walked)
        }
    }
}

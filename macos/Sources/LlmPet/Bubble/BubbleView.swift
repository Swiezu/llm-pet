import SwiftUI

struct BubbleView: View {
    let bubble: Bubble

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if bubble.below { tail(pointingUp: true) }
            ZStack(alignment: .topLeading) {
                Text(bubble.text ?? "").opacity(0)
                Text(String((bubble.text ?? "").prefix(bubble.count)))
            }
            .font(Font(Bubble.font))
            .foregroundStyle(bubble.foreground)
            .lineLimit(Bubble.lines)
            .truncationMode(.tail)
            .frame(width: bubble.width, alignment: .leading)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(bubble.background, in: RoundedRectangle(cornerRadius: 4))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(.black.opacity(0.8), lineWidth: 2))
            if !bubble.below { tail(pointingUp: false) }
        }
        .padding(6)
        .scaleEffect(bubble.shown ? 1 : 0.5, anchor: bubble.below ? .top : .bottom)
        .opacity(bubble.shown ? 1 : 0)
        .animation(bubble.shown ? .spring(response: 0.32, dampingFraction: 0.62) : .easeIn(duration: 0.2), value: bubble.shown)
    }

    private func tail(pointingUp: Bool) -> some View {
        VStack(spacing: 0) {
            if pointingUp { Rectangle().frame(width: 4, height: 5) }
            Rectangle().frame(width: 8, height: 6)
            if !pointingUp { Rectangle().frame(width: 4, height: 5) }
        }
        .foregroundStyle(.black.opacity(0.8))
        .padding(.leading, max(8, bubble.tail - 6))
    }
}

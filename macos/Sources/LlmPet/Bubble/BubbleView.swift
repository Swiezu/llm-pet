import SwiftUI

struct BubbleView: View {
    let bubble: Bubble

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if bubble.below && bubble.pointing { tail(pointingUp: true) }
            VStack(alignment: .trailing, spacing: 5) {
                HStack(alignment: .top, spacing: 6) {
                    ZStack(alignment: .topLeading) {
                        Text(bubble.text ?? "").opacity(0)
                        Text(String((bubble.text ?? "").prefix(bubble.count)))
                    }
                    .font(Font(bubble.font))
                    .lineLimit(Bubble.lines)
                    .truncationMode(.tail)
                    .frame(width: bubble.width, alignment: .leading)
                    corner
                }
                if bubble.link != nil {
                    Button { bubble.open() } label: {
                        Text(bubble.linkTitle)
                            .font(Font(bubble.linkFont))
                            .underline()
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(maxWidth: bubble.width, alignment: .trailing)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help(bubble.link?.isFileURL == true ? bubble.link?.path ?? "" : bubble.link?.absoluteString ?? "")
                }
            }
            .foregroundStyle(bubble.foreground)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(bubble.background, in: RoundedRectangle(cornerRadius: 4))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(.black.opacity(0.8), lineWidth: 2))
            .overlay(alignment: bubble.below ? .bottomLeading : .topLeading) {
                if bubble.waiting > 0 { badge }
            }
            if !bubble.below && bubble.pointing { tail(pointingUp: false) }
        }
        .padding(8)
        .scaleEffect(bubble.shown ? 1 : 0.5, anchor: bubble.below ? .top : .bottom)
        .opacity(bubble.shown ? 1 : 0)
        .animation(bubble.shown ? .spring(response: 0.32, dampingFraction: 0.62) : .easeIn(duration: 0.2), value: bubble.shown)
    }

    private var badge: some View {
        Text("+\(bubble.waiting)")
            .font(.system(size: 10, weight: .heavy, design: .monospaced))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(.black.opacity(0.85), in: Capsule())
            .offset(x: -7, y: bubble.below ? 8 : -8)
            .help(tr("\(bubble.waiting) more waiting", "Czeka jeszcze: \(bubble.waiting)"))
    }

    @ViewBuilder
    private var corner: some View {
        if bubble.forever {
            Button { bubble.dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 9 * bubble.zoom, weight: .heavy))
                    .frame(width: 14 * bubble.zoom, height: 14 * bubble.zoom)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(tr("Close", "Zamknij"))
        } else {
            ZStack {
                Circle().stroke(bubble.foreground.opacity(0.2), lineWidth: 2)
                Circle()
                    .trim(from: 0, to: 1 - bubble.progress)
                    .stroke(bubble.foreground, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 10 * bubble.zoom, height: 10 * bubble.zoom)
            .padding(2 * bubble.zoom)
        }
    }

    private func tail(pointingUp: Bool) -> some View {
        VStack(spacing: 0) {
            if pointingUp { Rectangle().frame(width: 4, height: 5) }
            Rectangle().frame(width: 8, height: 6)
            if !pointingUp { Rectangle().frame(width: 4, height: 5) }
        }
        .foregroundStyle(.black.opacity(0.8))
        .padding(.leading, max(8, bubble.tail - 8))
    }
}

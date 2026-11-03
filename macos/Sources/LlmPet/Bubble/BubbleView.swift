import SwiftUI

struct BubbleCanvas: View {
    let bubble: Bubble

    var body: some View {
        BubbleView(bubble: bubble)
            .fixedSize()
            .offset(x: bubble.inset.x, y: bubble.inset.y)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct BubbleView: View {
    let bubble: Bubble

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if bubble.below && bubble.pointing { tail(pointingUp: true) }
            VStack(alignment: .trailing, spacing: 5) {
                HStack(alignment: .top, spacing: 6) {
                    message
                    corner
                }
                if bubble.truncated || bubble.link != nil {
                    HStack(spacing: 12) {
                        if bubble.truncated {
                            Button { bubble.toggleExpanded() } label: {
                                HStack(spacing: 4) {
                                    Text(bubble.expandTitle)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: bubble.linkFont.pointSize * 0.8, weight: .heavy))
                                        .rotationEffect(.degrees(180 * bubble.openness))
                                }
                                .font(Font(bubble.linkFont))
                                .lineLimit(1)
                                .fixedSize()
                                .padding(5)
                                .contentShape(Rectangle())
                                .padding(-5)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer(minLength: 0)
                        if bubble.link != nil {
                            Button { bubble.open() } label: {
                                Text(bubble.linkTitle)
                                    .font(Font(bubble.linkFont))
                                    .underline()
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .help(bubble.link?.isFileURL == true ? bubble.link?.path ?? "" : bubble.link?.absoluteString ?? "")
                        }
                    }
                    .frame(width: bubble.width + 6 + 14 * bubble.zoom)
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

    @ViewBuilder
    private var message: some View {
        if bubble.truncated {
            ZStack(alignment: .topLeading) {
                Text(String(bubble.short.prefix(bubble.shortCount)))
                    .lineLimit(bubble.lines)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: bubble.folded.width, alignment: .leading)
                    .opacity(1 - bubble.openness)
                if bubble.openness > 0 {
                    unfolded.opacity(bubble.openness)
                }
            }
            .font(Font(bubble.font))
            .frame(width: bubble.width, height: bubble.textHeight, alignment: .topLeading)
            .clipped()
        } else {
            ZStack(alignment: .topLeading) {
                Text(bubble.text ?? "").opacity(0)
                Text(String((bubble.text ?? "").prefix(bubble.count)))
            }
            .font(Font(bubble.font))
            .lineLimit(bubble.lines)
            .truncationMode(.tail)
            .frame(width: bubble.width, alignment: .leading)
        }
    }

    @ViewBuilder
    private var unfolded: some View {
        let text = Text(String(bubble.full.prefix(bubble.fullCount)))
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: bubble.unfolded.width, alignment: .leading)
        if let height = bubble.scroll {
            ScrollView { text }
                .frame(width: bubble.unfolded.width, height: height)
        } else {
            text
        }
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

    private var corner: some View {
        Button { bubble.dismiss() } label: {
            ZStack {
                if !bubble.forever {
                    ZStack {
                        Circle().stroke(bubble.foreground.opacity(0.2), lineWidth: 1.5)
                        Circle()
                            .trim(from: 0, to: 1 - bubble.progress)
                            .stroke(bubble.foreground, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                    }
                    .padding(0.75)
                    .scaleEffect(1 + bubble.openness * 0.3)
                    .opacity(1 - bubble.openness)
                }
                Image(systemName: "xmark")
                    .font(.system(size: 9 * bubble.zoom, weight: .heavy))
                    .scaleEffect(bubble.forever ? 1 : 0.55 + 0.45 * bubble.openness)
            }
            .frame(width: 14 * bubble.zoom, height: 14 * bubble.zoom)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(tr("Close", "Zamknij"))
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

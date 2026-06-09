import SwiftUI

struct ModClockFace: View {
    let modulus: Int
    let arrowPosition: Int
    let highlightedPosition: Int?
    let correctPosition: Int?
    let theme: DungeonTheme
    let onTap: (Int) -> Void

    let faceRadius: CGFloat = 130
    let nodeRadius: CGFloat = 20

    var cx: CGFloat { faceRadius + nodeRadius + 4 }
    var cy: CGFloat { faceRadius + nodeRadius + 4 }

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(theme.accent.opacity(0.25), lineWidth: 2)
                .frame(width: faceRadius * 2, height: faceRadius * 2)
                .position(x: cx, y: cy)

            // Number nodes
            ForEach(0..<modulus, id: \.self) { i in
                clockNode(for: i)
            }

            // Arrow
            arrowPath

            // Centre dot
            Circle()
                .fill(theme.accent)
                .frame(width: 10, height: 10)
                .position(x: cx, y: cy)
        }
        .frame(
            width: faceRadius * 2 + nodeRadius * 2 + 8,
            height: faceRadius * 2 + nodeRadius * 2 + 8
        )
    }

    // Place each number around a circle, like positions on a clock face
    func clockNode(for i: Int) -> some View {
        let angle = angleFor(i)
        // cos gives the x position, sin gives the y position
        let nx = cx + faceRadius * cos(angle)
        let ny = cy + faceRadius * sin(angle)

        return ClockNode(
            label: "\(i)",
            isArrow: arrowPosition == i,
            isHighlighted: highlightedPosition == i,
            isCorrect: correctPosition == i,
            nodeRadius: nodeRadius,
            theme: theme
        ) {
            onTap(i)
        }
        .position(x: nx, y: ny)
    }

    var arrowPath: some View {
        let angle = angleFor(arrowPosition)
        let endX = cx + (faceRadius - nodeRadius - 4) * cos(angle)
        let endY = cy + (faceRadius - nodeRadius - 4) * sin(angle)

        return Path { path in
            path.move(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: endX, y: endY))
        }
        .stroke(theme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
    }

    func angleFor(_ position: Int) -> Double {
        Double(position) / Double(modulus) * 2 * Double.pi - Double.pi / 2
    }
}

struct ClockNode: View {
    let label: String
    let isArrow: Bool
    let isHighlighted: Bool
    let isCorrect: Bool
    let nodeRadius: CGFloat
    let theme: DungeonTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(fillColor)
                Circle().stroke(borderColor, lineWidth: isArrow ? 2.5 : 1)
                Text(label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: nodeRadius * 2, height: nodeRadius * 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Position \(label)")
        .accessibilityHint(isCorrect ? "Correct answer" : isHighlighted ? "Wrong guess" : "Tap to select")
    }

    var fillColor: Color {
        if isCorrect     { return theme.success.opacity(0.85) }
        if isHighlighted { return theme.error.opacity(0.7) }
        if isArrow       { return theme.accent.opacity(0.6) }
        return theme.tile.opacity(0.8)
    }

    var borderColor: Color {
        isArrow ? theme.accent : theme.accent.opacity(0.3)
    }
}

#Preview {
    ModClockFace(
        modulus: 7,
        arrowPosition: 3,
        highlightedPosition: nil,
        correctPosition: nil,
        theme: .stone,
        onTap: { _ in }
    )
    .padding()
    .background(DungeonTheme.stone.background)
}

import SwiftUI

struct BridgeBuilderView: View {
    let problem: MathEngine.BridgeBuilderProblem
    let theme: DungeonTheme
    var onComplete: (Int) -> Void

    @State var a: Int = 0
    @State var b: Int = 0
    @State var stepsTaken: Int = 0
    @State var isComplete: Bool = false
    @State var stepLog: [String] = []

    var optimalSteps: Int { problem.steps.count }

    var maxValue: Int { max(problem.a, problem.b) }
    var gcd: Int { problem.solution }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 12)

                Spacer(minLength: 20)

                logBarsSection
                    .padding(.horizontal, 24)

                Spacer(minLength: 16)

                stepLogView
                    .padding(.horizontal, 24)

                Spacer(minLength: 12)

                statusRow
                    .padding(.horizontal)

                Spacer(minLength: 24)
            }
        }
        .onAppear { a = problem.a; b = problem.b }
    }

    var header: some View {
        VStack(spacing: 4) {
            Text("Bridge Builder")
                .font(.headline)
                .foregroundColor(theme.subtleText)
            Text("Find GCD(\(problem.a), \(problem.b))")
                .font(.title.bold())
                .foregroundColor(theme.text)
            Text("Drag the shorter log onto the longer one")
                .font(.subheadline)
                .foregroundColor(theme.subtleText)
        }
    }

    var logBarsSection: some View {
        GeometryReader { geo in
            let maxWidth = geo.size.width
            VStack(spacing: 24) {
                // Log A: draggable when A is the shorter log → drag DOWN (+1)
                LogBar(
                    label: "Log A",
                    value: a,
                    maxValue: maxValue,
                    maxWidth: maxWidth,
                    isLonger: a > b,
                    isDraggable: a < b && !isComplete,
                    dragDirection: 1.0,
                    isComplete: isComplete,
                    theme: theme,
                    onDrag: performCut
                )

                // Log B: draggable when B is the shorter log → drag UP (-1)
                LogBar(
                    label: "Log B",
                    value: b,
                    maxValue: maxValue,
                    maxWidth: maxWidth,
                    isLonger: b > a,
                    isDraggable: b < a && !isComplete,
                    dragDirection: -1.0,
                    isComplete: isComplete,
                    theme: theme,
                    onDrag: performCut
                )
            }
        }
        .frame(height: 132)
    }

    var statusRow: some View {
        HStack(spacing: 20) {
            statPill(label: "Steps", value: "\(stepsTaken)")
            statPill(label: "Optimal", value: "\(optimalSteps)")
            if isComplete {
                statPill(label: "GCD", value: "\(gcd)")
                    .foregroundColor(theme.success)
            }
        }
    }

    func statPill(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(theme.subtleText)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.accent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    var stepLogView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !stepLog.isEmpty {
                ForEach(0..<stepLog.count, id: \.self) { i in
                    let entry = stepLog[i]
                    Text(entry)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(theme.text.opacity(0.75))
                }
            } else {
                Text("Drag the shorter log to begin the Euclidean algorithm")
                    .font(.caption)
                    .foregroundColor(theme.subtleText.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(theme.secondaryBackground.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.easeInOut(duration: 0.3), value: stepLog.count)
    }

    func performCut() {
        if isComplete { return }
        HapticManager.rigid()

        let step = stepsTaken + 1
        if a >= b {
            let quot = a / b
            let rem = a % b
            let result = rem == 0 ? b : rem
            stepLog.append("Step \(step): \(a) ÷ \(b) = \(quot) r \(result)")
        } else {
            let quot = b / a
            let rem = b % a
            let result = rem == 0 ? a : rem
            stepLog.append("Step \(step): \(b) ÷ \(a) = \(quot) r \(result)")
        }

        withAnimation(.easeInOut(duration: 0.45)) {
            if a >= b {
                let rem = a % b
                a = rem == 0 ? b : rem
            } else {
                let rem = b % a
                b = rem == 0 ? a : rem
            }
            stepsTaken += 1
        }
        if a == b {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { handleComplete() }
        }
    }

    func handleComplete() {
        isComplete = true
        HapticManager.success()
        let extraSteps = max(0, stepsTaken - optimalSteps)
        let earned = max(1, 3 - extraSteps)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            onComplete(earned)
        }
    }
}

struct LogBar: View {
    let label: String
    let value: Int
    let maxValue: Int
    let maxWidth: CGFloat
    let isLonger: Bool
    let isDraggable: Bool
    let dragDirection: CGFloat   // +1 = drag down (A toward B), -1 = drag up (B toward A)
    let isComplete: Bool
    let theme: DungeonTheme
    var onDrag: () -> Void

    @State var dragOffset: CGFloat = 0
    let dragThreshold: CGFloat = 64

    var barWidth: CGFloat {
        if maxValue <= 0 { return 0 }
        return maxWidth * CGFloat(value) / CGFloat(maxValue)
    }

    // only allow dragging in the correct direction, block the other way
    var constrainedOffset: CGFloat {
        if dragDirection > 0 {
            return max(0, min(dragThreshold * 1.25, dragOffset))
        } else {
            return min(0, max(-dragThreshold * 1.25, dragOffset))
        }
    }

    // 0…1 progress toward threshold
    var dragProgress: CGFloat {
        min(1, abs(constrainedOffset) / dragThreshold)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label row
            HStack {
                Text(label)
                    .font(.caption.bold())
                    .foregroundColor(theme.subtleText)
                Spacer()
                if isDraggable {
                    HStack(spacing: 3) {
                        Image(systemName: dragDirection > 0 ? "arrow.down" : "arrow.up")
                            .font(.system(size: 9, weight: .bold))
                        Text("DRAG")
                            .font(.system(size: 9, weight: .black))
                    }
                    .foregroundColor(theme.accent)
                    .opacity(0.6 + dragProgress * 0.4)
                }
            }

            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.secondaryBackground)
                    .frame(width: maxWidth, height: 44)

                // ring on the longer bar showing it's ready when you drag the other bar far enough
                if !isDraggable && !isComplete && dragProgress > 0 {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.success.opacity(dragProgress * 0.8), lineWidth: 2)
                        .frame(width: maxWidth, height: 44)
                }

                // Log fill
                RoundedRectangle(cornerRadius: 8)
                    .fill(barFill)
                    .frame(width: max(0, barWidth), height: 44)
                    .overlay(
                        HStack {
                            Text("\(value)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                            Spacer()
                            if isDraggable {
                                Image(systemName: "hand.draw.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.85))
                                    .padding(.trailing, 10)
                                    .scaleEffect(1 + dragProgress * 0.15)
                            }
                        }
                    )
                    .animation(.easeInOut(duration: 0.45), value: barWidth)

                // glow on the bar you're dragging when you've gone far enough to release
                if isDraggable && dragProgress >= 1 {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.success, lineWidth: 2.5)
                        .frame(width: max(0, barWidth), height: 44)
                        .transition(.opacity)
                }
            }
            .shadow(
                color: isDraggable && dragOffset != 0 ? theme.accent.opacity(0.35 * dragProgress) : .clear,
                radius: 10,
                x: 0,
                y: dragDirection * 4 * dragProgress
            )
            .scaleEffect(isDraggable ? 1.0 + dragProgress * 0.015 : 1.0, anchor: .leading)
        }
        .offset(y: constrainedOffset)
        .gesture(
            DragGesture(minimumDistance: 8)
                .onChanged { value in
                    if !isDraggable { return }
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    if !isDraggable {
                        dragOffset = 0
                        return
                    }
                    let netDrag = value.translation.height * dragDirection
                    withAnimation(.easeInOut(duration: 0.35)) {
                        dragOffset = 0
                    }
                    if netDrag > dragThreshold {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            onDrag()
                        }
                    }
                }
        )
        .accessibilityLabel("\(label): \(value)")
        .accessibilityHint(isDraggable
            ? "Drag \(dragDirection > 0 ? "down" : "up") onto the longer log"
            : (isComplete ? "Complete" : "Target — the longer log"))
        .accessibilityAction(named: "Cut log") { if isDraggable { onDrag() } }
    }

    var barFill: Color {
        if isComplete { return theme.success.opacity(0.7) }
        if isLonger   { return theme.accent.opacity(0.75) }
        return theme.accent.opacity(0.45)
    }
}

#Preview {
    BridgeBuilderView(
        problem: MathEngine.generateBridgeBuilder(floor: 1),
        theme: .stone,
        onComplete: { stars in print("Stars: \(stars)") }
    )
}

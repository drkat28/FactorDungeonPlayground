import SwiftUI

struct CollatzExplorerView: View {
    let startingNumber: Int
    let theme: DungeonTheme

    @State var visibleCount: Int = 0
    @State var animationTimer: Timer? = nil
    @State var canvasWidth: CGFloat = 300
    @State var hasInitialized: Bool = false

    var sequence: [Int] { MathEngine.collatzSequence(startingNumber) }

    // Layout constants
    let nodeSize:  CGFloat = 36
    let stepWidth: CGFloat = 52

    var body: some View {
        GeometryReader { geo in
            let canvasH = min(260, max(120, geo.size.height * 0.38))
            ZStack(alignment: .topLeading) {
                theme.background.ignoresSafeArea()
                Image("collatz_vault_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.25)

                ScrollView {
                    VStack(spacing: 20) {
                        titleRow
                            .padding(.horizontal)
                            .padding(.top, 4)

                        explanationCard
                            .padding(.horizontal)

                        pathCanvas(canvasH: canvasH)
                            .frame(height: canvasH)
                            .background(GeometryReader { g in
                                Color.clear
                                    .onAppear {
                                        let measured = g.size.width
                                        // if the measured width looks way too big, use the screen width instead
                                        // If we get something huge, use geo width instead
                                        if measured > 1000 {
                                            canvasWidth = geo.size.width - 32
                                        } else {
                                            canvasWidth = measured
                                        }
                                        hasInitialized = true
                                    }
                                    .onChange(of: g.size.width) { oldWidth, newWidth in
                                        if newWidth > 1000 {
                                            canvasWidth = geo.size.width - 32
                                        } else {
                                            canvasWidth = newWidth
                                        }
                                    }
                            })
                            .padding(.horizontal)

                        statsRow
                            .padding(.horizontal)

                        Spacer(minLength: 8)
                    }
                    .frame(maxWidth: geo.size.width)
                    .padding(.bottom, 100) // room for buttons
                }

                // Bottom button bar pinned to bottom
                VStack {
                    Spacer()
                    buttonRow
                        .padding(.horizontal, 32)
                        .padding(.bottom, 24)
                        .background(
                            theme.background
                                .opacity(0.95)
                                .ignoresSafeArea()
                        )
                }
                .frame(maxWidth: geo.size.width, alignment: .leading)
            }
        }
        .navigationTitle("Collatz Explorer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { startAnimation() }
        .onDisappear { animationTimer?.invalidate() }
    }

    var titleRow: some View {
        VStack(spacing: 4) {
            Text("Starting from \(startingNumber)")
                .font(.title2.bold())
                .foregroundColor(theme.text)
            Text("\(sequence.count - 1) steps to reach 1")
                .font(.subheadline)
                .foregroundColor(theme.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var explanationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("How It Works", systemImage: "gearshape.fill")
                .font(.caption.bold())
                .foregroundColor(theme.accent)

            VStack(spacing: 8) {
                ruleRow(condition: "If n is even", result: "n ÷ 2", color: theme.accent)
                ruleRow(condition: "If n is odd",  result: "3n + 1", color: theme.error)
            }

            Divider().background(theme.accent.opacity(0.2))

            Text("Every sequence is believed to eventually reach 1 — but nobody has proved it. Lothar Collatz proposed this conjecture in 1937. It remains one of the most famous unsolved problems in mathematics.")
                .font(.caption)
                .foregroundColor(theme.subtleText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(theme.accent.opacity(0.2), lineWidth: 1)
        )
    }

    func ruleRow(condition: String, result: String, color: Color) -> some View {
        HStack(spacing: 0) {
            Text(condition)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(theme.subtleText)
            Text(" → ")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(theme.subtleText.opacity(0.5))
            Text(result)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Spacer()
            Circle()
                .fill(color.opacity(0.4))
                .frame(width: 10, height: 10)
        }
    }

    func pathCanvas(canvasH: CGFloat) -> some View {
        let pad: CGFloat = 4
        let cMidY      = canvasH - nodeSize / 2 - pad
        let cAmplitude = canvasH - nodeSize - pad * 2
        let visible    = Array(sequence.prefix(visibleCount))

        // space steps evenly — stretch wider if the sequence is short
        let steps = CGFloat(max(1, sequence.count - 1))
        let effectiveStepWidth = max(stepWidth, (canvasWidth - nodeSize * 2) / steps)
        let totalWidth = steps * effectiveStepWidth + nodeSize

        return ScrollView(.horizontal, showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                // draw lines between nodes — use the full sequence so the y-scale doesn't shift
                if visible.count > 1 {
                    Path { path in
                        for i in 0..<(visible.count - 1) {
                            let x0 = CGFloat(i) * effectiveStepWidth + nodeSize / 2
                            let y0 = nodeY(i, in: sequence, midY: cMidY, amplitude: cAmplitude) + nodeSize / 2
                            let x1 = CGFloat(i + 1) * effectiveStepWidth + nodeSize / 2
                            let y1 = nodeY(i + 1, in: sequence, midY: cMidY, amplitude: cAmplitude) + nodeSize / 2
                            if i == 0 { path.move(to: CGPoint(x: x0, y: y0)) }
                            path.addLine(to: CGPoint(x: x1, y: y1))
                        }
                    }
                    .stroke(
                        theme.accent.opacity(0.5),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                    )
                }

                // Nodes
                ForEach(0..<visible.count, id: \.self) { i in
                    let value = visible[i]
                    ExplorerNode(
                        value: value,
                        isEven: value % 2 == 0,
                        isLast: i == visible.count - 1 && visibleCount >= sequence.count,
                        nodeSize: nodeSize,
                        theme: theme
                    )
                    .position(
                        x: CGFloat(i) * effectiveStepWidth + nodeSize / 2,
                        y: nodeY(i, in: sequence, midY: cMidY, amplitude: cAmplitude) + nodeSize / 2
                    )
                    .transition(.opacity)
                }
            }
            .frame(width: totalWidth + nodeSize, height: canvasH)
            .animation(.easeInOut(duration: 0.25), value: visibleCount)
        }
    }

    var statsRow: some View {
        let columns = [GridItem(.flexible(), spacing: 12),
                       GridItem(.flexible(), spacing: 12),
                       GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            statPill("Start",  value: "\(startingNumber)")
            statPill("Steps",  value: "\(sequence.count - 1)")
            statPill("Peak",   value: "\(sequence.max() ?? 0)")
        }
    }

    func statPill(_ label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(theme.subtleText)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(theme.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    var buttonRow: some View {
        Button(action: restartAnimation) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.counterclockwise")
                Text("Replay")
            }
            .font(.body.bold())
            .foregroundColor(theme.accent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    func nodeY(_ index: Int, in seq: [Int], midY: CGFloat, amplitude: CGFloat) -> CGFloat {
        if let maxVal = seq.max(), maxVal > 1 {
            let normalised = CGFloat(seq[index] - 1) / CGFloat(maxVal - 1)
            return midY - normalised * amplitude - nodeSize / 2
        } else {
            return midY - nodeSize / 2
        }
    }

    func startAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        visibleCount = 1
        if sequence.count <= 1 { return }
        let interval: TimeInterval = sequence.count > 40 ? 0.06 : 0.12
        let t = Timer(timeInterval: interval, repeats: true) { timer in
            if visibleCount < sequence.count {
                visibleCount += 1
                HapticManager.light()
            } else {
                timer.invalidate()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        animationTimer = t
    }

    func restartAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        visibleCount = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            startAnimation()
        }
    }
}

struct ExplorerNode: View {
    let value: Int
    let isEven: Bool
    let isLast: Bool
    let nodeSize: CGFloat
    let theme: DungeonTheme

    var body: some View {
        ZStack {
            Circle().fill(nodeColor)
            Circle().stroke(theme.accent.opacity(0.4), lineWidth: 1)
            Text(value <= 999 ? "\(value)" : "…")
                .font(.system(size: value > 99 ? 9 : 11, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(width: nodeSize, height: nodeSize)
    }

    var nodeColor: Color {
        if isLast  { return theme.success.opacity(0.85) }
        if isEven  { return theme.accent.opacity(0.55) }
        return theme.error.opacity(0.55)
    }
}

#Preview {
    NavigationStack {
        CollatzExplorerView(
            startingNumber: 27,
            theme: .stone
        )
    }
}

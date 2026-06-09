import SwiftUI

struct FloodGateView: View {
    let problem: MathEngine.FloodGateProblem
    let theme: DungeonTheme
    var onComplete: (Int) -> Void

    @State var currentTick: Int = 0
    @State var isRunning: Bool = false
    @State var tapResult: TapResult = .waiting
    @State var lastTapTick: Int = -99
    @State var attempts: Int = 0
    @State var startTime: Date? = nil
    @State var timeRemaining: Int = 30

    @State var timer: Timer? = nil
    let maxTicks = 80
    let timeLimit = 30

    var pipeAOpen: Bool { currentTick > 0 && currentTick % problem.intervalA == 0 }
    var pipeBOpen: Bool { currentTick > 0 && currentTick % problem.intervalB == 0 }
    var bothOpen:  Bool { pipeAOpen && pipeBOpen }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 12)

                Spacer(minLength: 16)

                pipesSection
                    .padding(.horizontal, 32)

                Spacer(minLength: 16)

                tickDisplay
                    .padding(.horizontal)

                Spacer(minLength: 20)

                tapSection
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
                if !isRunning { return }
                advanceTick()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    var header: some View {
        VStack(spacing: 4) {
            Text("Flood Gate")
                .font(.headline)
                .foregroundColor(theme.subtleText)
            Text("Tap when BOTH pipes open")
                .font(.title2.bold())
                .foregroundColor(theme.text)
            HStack(spacing: 12) {
                cycleLabel("Pipe A", interval: problem.intervalA)
                Text("·").foregroundColor(theme.subtleText)
                cycleLabel("Pipe B", interval: problem.intervalB)
            }
        }
    }

    func cycleLabel(_ name: String, interval: Int) -> some View {
        HStack(spacing: 4) {
            Text(name).font(.caption).foregroundColor(theme.subtleText)
            Text("every \(interval)").font(.caption.bold()).foregroundColor(theme.accent)
        }
    }

    var pipesSection: some View {
        HStack(spacing: 40) {
            PipeView(
                label: "Pipe A",
                interval: problem.intervalA,
                currentTick: currentTick,
                isOpen: pipeAOpen,
                theme: theme
            )
            PipeView(
                label: "Pipe B",
                interval: problem.intervalB,
                currentTick: currentTick,
                isOpen: pipeBOpen,
                theme: theme
            )
        }
    }

    var tickDisplay: some View {
        VStack(spacing: 6) {
            HStack(spacing: 16) {
                Text("Tick")
                    .font(.headline)
                    .foregroundColor(theme.subtleText)
                Text("\(currentTick)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(bothOpen ? theme.success : theme.text)
                    .animation(.easeInOut(duration: 0.15), value: bothOpen)

                if isRunning {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.caption)
                        Text("\(timeRemaining)s")
                            .font(.caption.bold())
                            .monospacedDigit()
                    }
                    .foregroundColor(timeRemaining <= 5 ? theme.error : theme.subtleText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(theme.secondaryBackground)
                    .clipShape(Capsule())
                    .animation(.easeInOut(duration: 0.2), value: timeRemaining)
                }
            }

            if bothOpen {
                Text("BOTH OPEN NOW!")
                    .font(.headline.bold())
                    .foregroundColor(theme.success)
                    .transition(.opacity)
            }

            resultLabel
        }
        .animation(.easeInOut(duration: 0.3), value: bothOpen)
        .animation(.easeInOut(duration: 0.3), value: tapResult)
    }

    var resultLabel: some View {
        Group {
            switch tapResult {
            case .correct(let stars):
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .foregroundColor(i < stars ? .yellow : theme.secondaryBackground)
                    }
                    Text("Perfect timing!")
                        .font(.subheadline.bold())
                        .foregroundColor(theme.success)
                }
            case .tooEarly:
                Text("Too early — both gates weren't open yet")
                    .font(.subheadline)
                    .foregroundColor(theme.error)
            case .timeout:
                Text("Time's up! The answer was tick \(problem.solution)")
                    .font(.subheadline)
                    .foregroundColor(theme.error)
            case .waiting:
                Text(isRunning ? "Watch the pattern, then tap!" : "Press Start to begin")
                    .font(.subheadline)
                    .foregroundColor(theme.subtleText)
            }
        }
    }

    var tapSection: some View {
        VStack(spacing: 12) {
            if !isRunning && tapResult == .waiting {
                Button {
                    startTime = Date()
                    timeRemaining = timeLimit
                    isRunning = true
                } label: {
                    Text("Start")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.accent.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            } else {
                Button {
                    handleTap()
                } label: {
                    Text(bothOpen ? "TAP NOW! ✓" : "Tap Both Open")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(bothOpen ? theme.success.opacity(0.85) : theme.accent.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .animation(.easeInOut(duration: 0.15), value: bothOpen)
                }
                .disabled(tapResult == .correct(stars: 0) || tapResult == .timeout)
                .accessibilityLabel(bothOpen ? "Tap now, both pipes are open" : "Tap when both pipes open")
                .accessibilityHint(bothOpen ? "Both gates are open — tap to win" : "Wait for both pipes to open simultaneously")
            }
        }
    }

    func advanceTick() {
        if currentTick >= maxTicks {
            isRunning = false
            return
        }
        currentTick += 1
        if let start = startTime {
            let elapsed = Int(Date().timeIntervalSince(start))
            timeRemaining = max(0, timeLimit - elapsed)
            if timeRemaining == 0 && tapResult == .waiting {
                isRunning = false
                handleTimeout()
            }
        }
    }

    func handleTimeout() {
        HapticManager.error()
        tapResult = .timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onComplete(1)
        }
    }

    func handleTap() {
        if tapResult != .waiting { return }
        attempts += 1
        lastTapTick = currentTick

        if bothOpen {
            let stars = max(1, 3 - (attempts - 1))
            HapticManager.success()
            tapResult = .correct(stars: stars)
            isRunning = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                onComplete(stars)
            }
        } else {
            HapticManager.error()
            tapResult = .tooEarly
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                tapResult = .waiting
            }
        }
    }
}

struct PipeView: View {
    let label: String
    let interval: Int
    let currentTick: Int
    let isOpen: Bool
    let theme: DungeonTheme

    // Progress within current cycle (0.0 → 1.0)
    var cycleProgress: CGFloat {
        if interval <= 0 || currentTick <= 0 { return 0 }
        return CGFloat(currentTick % interval) / CGFloat(interval)
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(theme.subtleText)

            // Pipe body
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondaryBackground)
                    .frame(width: 64, height: 110)

                RoundedRectangle(cornerRadius: 12)
                    .fill(isOpen ? theme.success.opacity(0.7) : theme.tile.opacity(0.5))
                    .frame(width: 64, height: 110)
                    .animation(.easeInOut(duration: 0.2), value: isOpen)

                // Gate indicator
                Rectangle()
                    .fill(isOpen ? theme.success : theme.error.opacity(0.7))
                    .frame(width: 64, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: isOpen)

                Image(systemName: isOpen ? "drop.fill" : "drop")
                    .font(.system(size: 24))
                    .foregroundColor(isOpen ? .white : theme.subtleText)
                    .animation(.easeInOut(duration: 0.2), value: isOpen)
            }

            // Cycle progress ring
            ZStack {
                Circle()
                    .stroke(theme.secondaryBackground, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: cycleProgress)
                    .stroke(theme.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.65), value: cycleProgress)
                Text("/ \(interval)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(theme.subtleText)
            }
            .frame(width: 36, height: 36)

            Text(isOpen ? "OPEN" : "closed")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(isOpen ? theme.success : theme.subtleText)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), cycles every \(interval) ticks")
        .accessibilityValue(isOpen ? "Open" : "Closed")
    }
}

enum TapResult: Equatable {
    case waiting
    case tooEarly
    case timeout
    case correct(stars: Int)
}

#Preview {
    FloodGateView(
        problem: MathEngine.generateFloodGate(floor: 1),
        theme: .stone,
        onComplete: { stars in print("Stars: \(stars)") }
    )
}

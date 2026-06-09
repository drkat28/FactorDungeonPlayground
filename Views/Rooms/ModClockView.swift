import SwiftUI

struct ModClockView: View {
    let problem: MathEngine.ModClockProblem
    let theme: DungeonTheme
    var onComplete: (Int) -> Void

    @State var arrowPosition: Int = 0
    @State var tappedPosition: Int? = nil
    @State var mistakes: Int = 0
    @State var isRevealed: Bool = false
    @State var isComplete: Bool = false
    @State var animationStep: Int = 0   // which operation we're animating

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 12)

                Spacer(minLength: 12)

                ModClockFace(
                    modulus: problem.modulus,
                    arrowPosition: arrowPosition,
                    highlightedPosition: isRevealed ? nil : tappedPosition,
                    correctPosition: isRevealed ? problem.solution : nil,
                    theme: theme,
                    onTap: handleTap
                )

                Spacer(minLength: 16)

                operationDisplay
                    .padding(.horizontal, 40)

                Spacer(minLength: 20)
            }
        }
        .onAppear { arrowPosition = problem.start }
    }

    var header: some View {
        VStack(spacing: 4) {
            Text("Mod Clock")
                .font(.headline)
                .foregroundColor(theme.subtleText)
            Text("mod \(problem.modulus) clock")
                .font(.title.bold())
                .foregroundColor(theme.text)
            Text("Tap where the arrow lands")
                .font(.subheadline)
                .foregroundColor(theme.subtleText)
        }
    }

    var operationDisplay: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                label("Start", value: "\(problem.start)")

                ForEach(0..<problem.operations.count, id: \.self) { i in
                    let op = problem.operations[i]
                    Image(systemName: "arrow.right")
                        .foregroundColor(theme.subtleText.opacity(0.6))
                    label(op.symbol == "+" ? "Add" : "Multiply",
                          value: "\(op.symbol)\(op.value)")
                }

                Image(systemName: "arrow.right")
                    .foregroundColor(theme.subtleText.opacity(0.6))

                label("Answer", value: isRevealed ? "\(problem.solution)" : "?")
            }
            .padding()
            .background(theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if mistakes > 0 && !isRevealed {
                Text("\(mistakes) wrong \(mistakes == 1 ? "tap" : "taps")")
                    .font(.caption)
                    .foregroundColor(theme.error)
            }
        }
    }

    func label(_ title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(theme.subtleText)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(theme.accent)
        }
    }

    func handleTap(_ position: Int) {
        if isComplete { return }

        if position == problem.solution {
            // Correct! Animate arrow to solution then complete.
            HapticManager.success()
            withAnimation(.easeInOut(duration: 0.5)) {
                arrowPosition = problem.solution
                isRevealed = true
            }
            let earned = max(1, 3 - mistakes)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                isComplete = true
                onComplete(earned)
            }
        } else {
            mistakes += 1
            HapticManager.error()
            tappedPosition = position
            // Clear wrong tap highlight after a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                tappedPosition = nil
            }
        }
    }
}

#Preview {
    ModClockView(
        problem: MathEngine.generateModClock(floor: 1),
        theme: .stone,
        onComplete: { stars in print("Stars: \(stars)") }
    )
}

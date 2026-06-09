import SwiftUI

struct CipherLockView: View {
    let problem: MathEngine.CipherLockProblem
    let theme: DungeonTheme
    var onComplete: (Int) -> Void

    @State var candidate: Int = 1
    @State var mistakes: Int = 0
    @State var isComplete: Bool = false
    @State var shakeOffset: CGFloat = 0
    @State var flashCorrect: Bool = false
    @State var showHint: Bool = false
    @State var showMathHint: Bool = false

    var searchMax: Int {
        // the LCM tells us when the cycle repeats — use that as the max search number
        var result = 1
        for cond in problem.conditions {
            result = MathEngine.lcm(result, cond.modulus)
        }
        return result + 1
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 12)

                Spacer(minLength: 20)

                conditionsPanel
                    .padding(.horizontal, 24)

                Spacer(minLength: 24)

                if showMathHint {
                    mathHintPanel
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                candidatePicker
                    .padding(.horizontal, 40)
                    .offset(x: shakeOffset)

                Spacer(minLength: 12)

                HStack(spacing: 12) {
                    hintButton
                    mathButton
                }
                .padding(.horizontal, 40)

                Spacer(minLength: 20)

                submitButton
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
            }
        }
    }

    var header: some View {
        VStack(spacing: 4) {
            Text("Cipher Lock")
                .font(.headline)
                .foregroundColor(theme.subtleText)
            Text("Find the secret number")
                .font(.title.bold())
                .foregroundColor(theme.text)
            Text("All conditions must be satisfied")
                .font(.subheadline)
                .foregroundColor(theme.subtleText)
        }
    }

    var conditionsPanel: some View {
        VStack(spacing: 0) {
            ForEach(0..<problem.conditions.count, id: \.self) { i in
                let cond = problem.conditions[i]
                ConditionRow(
                    candidate: candidate,
                    remainder: cond.remainder,
                    modulus: cond.modulus,
                    isSatisfied: candidate % cond.modulus == cond.remainder,
                    theme: theme
                )
                if i < problem.conditions.count - 1 {
                    Divider()
                        .background(theme.accent.opacity(0.1))
                        .padding(.leading, 56)
                }
            }
        }
        .background(theme.secondaryBackground.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    var candidatePicker: some View {
        VStack(spacing: 12) {
            Text("Your guess")
                .font(.caption)
                .foregroundColor(theme.subtleText)

            HStack(spacing: 24) {
                Button { adjust(-10) } label: { stepLabel("−10") }
                    .accessibilityLabel("Decrease by 10")
                Button { adjust(-1)  } label: { stepLabel("−1")  }
                    .accessibilityLabel("Decrease by 1")

                Text("\(candidate)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(flashCorrect ? theme.success : theme.text)
                    .frame(minWidth: 90)
                    .animation(.easeInOut(duration: 0.2), value: flashCorrect)

                Button { adjust(+1)  } label: { stepLabel("+1")  }
                    .accessibilityLabel("Increase by 1")
                Button { adjust(+10) } label: { stepLabel("+10") }
                    .accessibilityLabel("Increase by 10")
            }
            .padding()
            .background(theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Text("Range: 1 – \(searchMax - 1)")
                .font(.caption2)
                .foregroundColor(theme.subtleText.opacity(0.5))
        }
    }

    func stepLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(theme.accent)
            .frame(width: 48, height: 40)
            .background(theme.accent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    var hintText: String {
        let diff = problem.solution - candidate
        if diff > 10 { return "Much higher ↑" }
        if diff > 0  { return "A little higher ↑" }
        if diff < -10 { return "Much lower ↓" }
        if diff < 0  { return "A little lower ↓" }
        return "You're on it!"
    }

    var hintButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { showHint.toggle() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: showHint ? "eye.slash" : "eye")
                Text(showHint ? hintText : "Show hint")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(theme.subtleText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(theme.secondaryBackground.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    var mathButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { showMathHint.toggle() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: showMathHint ? "book.fill" : "book")
                Text(showMathHint ? "Hide" : "Learn")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(theme.subtleText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(theme.secondaryBackground.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    var mathHintPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(theme.accent)
                Text("Chinese Remainder Theorem")
                    .font(.subheadline.bold())
                    .foregroundColor(theme.text)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("This puzzle is a classic number theory problem. You need to find a number that simultaneously satisfies multiple modular conditions.")
                    .font(.caption)
                    .foregroundColor(theme.subtleText)

                Text("The Chinese Remainder Theorem tells us that if each condition uses a different modulus, a unique solution exists within the range of their product.")
                    .font(.caption)
                    .foregroundColor(theme.subtleText)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Tip: Look for a pattern")
                    .font(.caption.bold())
                    .foregroundColor(theme.accent)
                Text("Start with the most restrictive condition and check which values satisfy the others.")
                    .font(.caption2)
                    .foregroundColor(theme.subtleText)
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(theme.accent.opacity(0.08))
        .cornerRadius(12)
        .border(theme.accent.opacity(0.2), width: 1)
    }

    var allSatisfied: Bool {
        problem.conditions.allSatisfy { candidate % $0.modulus == $0.remainder }
    }

    var submitButton: some View {
        Button(action: handleSubmit) {
            HStack(spacing: 8) {
                Image(systemName: isComplete ? "lock.open.fill" : "lock.fill")
                Text(isComplete ? "Unlocked!" : (allSatisfied ? "Submit ✓" : "Submit"))
                    .font(.title3.bold())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(buttonBgColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .animation(.easeInOut(duration: 0.2), value: allSatisfied)
            .animation(.easeInOut(duration: 0.2), value: isComplete)
        }
        .disabled(isComplete)
    }

    var buttonBgColor: Color {
        if isComplete   { return theme.success.opacity(0.8) }
        if allSatisfied { return theme.success.opacity(0.6) }
        return theme.accent.opacity(0.5)
    }

    func adjust(_ delta: Int) {
        if isComplete { return }
        candidate = max(1, min(searchMax - 1, candidate + delta))
    }

    func handleSubmit() {
        if isComplete { return }

        if allSatisfied {
            HapticManager.success()
            flashCorrect = true
            isComplete = true
            let earned = max(1, 3 - mistakes)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                onComplete(earned)
            }
        } else {
            mistakes += 1
            HapticManager.error()
            triggerShake()
        }
    }

    func triggerShake() {
        withAnimation(.easeInOut(duration: 0.08)) {
            shakeOffset = -14
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeInOut(duration: 0.08)) {
                shakeOffset = 14
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.easeInOut(duration: 0.1)) {
                shakeOffset = 0
            }
        }
    }
}

struct ConditionRow: View {
    let candidate: Int
    let remainder: Int
    let modulus: Int
    let isSatisfied: Bool
    let theme: DungeonTheme

    var body: some View {
        HStack(spacing: 14) {
            // Checkmark
            ZStack {
                Circle()
                    .fill(isSatisfied ? theme.success.opacity(0.2) : theme.secondaryBackground)
                Image(systemName: isSatisfied ? "checkmark" : "questionmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isSatisfied ? theme.success : theme.subtleText)
            }
            .frame(width: 32, height: 32)
            .animation(.easeInOut(duration: 0.25), value: isSatisfied)

            // Human-readable condition
            VStack(alignment: .leading, spacing: 2) {
                Text("Divided by \(modulus), remainder = \(remainder)")
                    .font(.body)
                    .foregroundColor(theme.text)
                Text("? ≡ \(remainder)  (mod \(modulus))")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(theme.subtleText)
            }

            Spacer()

            // Live remainder preview
            Text("\(candidate) mod \(modulus) = \(candidate % modulus)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(isSatisfied ? theme.success : theme.subtleText.opacity(0.6))
                .animation(.easeInOut(duration: 0.1), value: isSatisfied)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

#Preview {
    CipherLockView(
        problem: MathEngine.generateCipherLock(floor: 1),
        theme: .stone,
        onComplete: { stars in print("Stars: \(stars)") }
    )
}

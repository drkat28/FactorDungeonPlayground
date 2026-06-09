import SwiftUI

struct FactorForgeView: View {
    let problem: MathEngine.FactorForgeProblem
    let theme: DungeonTheme
    var onComplete: (Int) -> Void   // passes stars earned (1-3)

    @State var remaining: Int = 0
    @State var collectedFactors: [Int] = []
    @State var mistakes: Int = 0
    @State var shakeOffset: CGFloat = 0
    @State var flashWrong: Bool = false
    @State var isComplete: Bool = false
    @State var stars: Int = 0

    let availablePrimes = [2, 3, 5, 7, 11, 13, 17, 19, 23]

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 12)

                Spacer(minLength: 12)

                tileArea
                    .offset(x: shakeOffset)

                Spacer(minLength: 12)

                factorsCollected
                    .padding(.horizontal)

                Spacer(minLength: 16)

                primeTray
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
        }
        .onAppear { remaining = problem.target }
        .onChange(of: remaining) { _, newVal in
            if newVal == 1 { handleComplete() }
        }
    }

    var header: some View {
        VStack(spacing: 4) {
            Text("Factor Forge")
                .font(.headline)
                .foregroundColor(theme.subtleText)
            Text("Factorize \(problem.target)")
                .font(.title.bold())
                .foregroundColor(theme.text)
            Text("Tap a prime that divides \(remaining)")
                .font(.subheadline)
                .foregroundColor(theme.subtleText)
        }
    }

    var tileArea: some View {
        Group {
            if remaining <= 36 {
                HexTileGrid(count: remaining,
                            color: flashWrong ? theme.error : theme.accent.opacity(0.7),
                            hexRadius: hexRadius(for: remaining))
                    .animation(.easeInOut(duration: 0.3), value: remaining)
                    .animation(.easeInOut(duration: 0.15), value: flashWrong)
                    .padding()
            } else {
                // Labeled block for larger numbers
                RoundedRectangle(cornerRadius: 16)
                    .fill(flashWrong ? theme.error.opacity(0.3) : theme.accent.opacity(0.15))
                    .overlay(
                        VStack(spacing: 4) {
                            Text("\(remaining)")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundColor(theme.text)
                            Text("remaining")
                                .font(.caption)
                                .foregroundColor(theme.subtleText)
                        }
                    )
                    .frame(width: 200, height: 120)
                    .animation(.easeInOut(duration: 0.15), value: flashWrong)
            }
        }
    }

    var factorsCollected: some View {
        HStack(spacing: 8) {
            Text("\(problem.target) =")
                .font(.title3.bold())
                .foregroundColor(theme.subtleText)

            if collectedFactors.isEmpty {
                Text("?")
                    .font(.title3.bold())
                    .foregroundColor(theme.subtleText.opacity(0.4))
            } else {
                ForEach(0..<collectedFactors.count, id: \.self) { i in
                    let f = collectedFactors[i]
                    if i > 0 {
                        Text("×")
                            .font(.title3)
                            .foregroundColor(theme.subtleText)
                    }
                    Text("\(f)")
                        .font(.title3.bold())
                        .foregroundColor(theme.accent)
                        .transition(.opacity)
                }
                if remaining > 1 {
                    Text("× ?")
                        .font(.title3.bold())
                        .foregroundColor(theme.subtleText.opacity(0.4))
                }
            }
            Spacer()
        }
        .animation(.easeInOut(duration: 0.3), value: collectedFactors.count)
        .padding()
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    var primeTray: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prime tiles")
                .font(.caption)
                .foregroundColor(theme.subtleText)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(validPrimes, id: \.self) { prime in
                    Button {
                        applyPrime(prime)
                    } label: {
                        ZStack {
                            HexagonShape()
                                .fill(theme.accent.opacity(0.25))
                            HexagonShape()
                                .stroke(theme.accent.opacity(0.6), lineWidth: 1.5)
                            Text("\(prime)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(theme.text)
                        }
                        .frame(width: 50, height: 56)
                    }
                    .buttonStyle(.plain)
                    .disabled(isComplete)
                    .accessibilityLabel("Prime \(prime)")
                    .accessibilityHint(remaining % prime == 0 ? "Divides \(remaining)" : "Does not divide \(remaining)")
                }
            }
        }
    }

    var validPrimes: [Int] {
        var result: [Int] = []
        for p in availablePrimes {
            if p <= problem.target && result.count < 9 {
                result.append(p)
            }
        }
        return result
    }

    func applyPrime(_ prime: Int) {
        if isComplete { return }

        if remaining % prime == 0 {
            HapticManager.success()
            withAnimation(.easeInOut(duration: 0.4)) {
                collectedFactors.append(prime)
                remaining /= prime
            }
        } else {
            mistakes += 1
            HapticManager.error()
            triggerShake()
        }
    }

    func triggerShake() {
        flashWrong = true
        withAnimation(.easeInOut(duration: 0.08)) {
            shakeOffset = -12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeInOut(duration: 0.08)) {
                shakeOffset = 12
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.easeInOut(duration: 0.1)) {
                shakeOffset = 0
            }
            flashWrong = false
        }
    }

    func handleComplete() {
        isComplete = true
        let earned = max(1, 3 - mistakes)
        stars = earned
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onComplete(earned)
        }
    }

    func hexRadius(for n: Int) -> CGFloat {
        switch n {
        case 1...6:   return 28
        case 7...12:  return 22
        case 13...20: return 18
        default:      return 14
        }
    }
}

#Preview {
    FactorForgeView(
        problem: MathEngine.generateFactorForge(floor: 1),
        theme: .stone,
        onComplete: { stars in print("Stars: \(stars)") }
    )
}

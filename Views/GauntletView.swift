import SwiftUI

enum GauntletStep: Int, CaseIterable {
    case factorForge = 0
    case sieveStrike
    case modClock
    case bridgeBuilder
    case floodGate
    case cipherLock

    var title: String {
        switch self {
        case .factorForge:   return "Factor Forge"
        case .sieveStrike:   return "Sieve Strike"
        case .modClock:      return "Mod Clock"
        case .bridgeBuilder: return "Bridge Builder"
        case .floodGate:     return "Flood Gate"
        case .cipherLock:    return "Cipher Lock"
        }
    }

    var subtitle: String {
        GameState.roomSubtitle(for: title)
    }

    var icon: String {
        switch self {
        case .factorForge:   return "hammer.fill"
        case .sieveStrike:   return "grid"
        case .modClock:      return "clock.fill"
        case .bridgeBuilder: return "arrow.left.arrow.right"
        case .floodGate:     return "drop.fill"
        case .cipherLock:    return "lock.fill"
        }
    }

    var concept: String {
        switch self {
        case .factorForge:
            return "Every integer greater than 1 can be written as a unique product of prime numbers. For example, 12 = 2 × 2 × 3. This is called the Fundamental Theorem of Arithmetic."
        case .sieveStrike:
            return "The Sieve of Eratosthenes finds all multiples of a prime by repeatedly crossing them out. Any number not crossed out must be prime — it has no smaller divisors."
        case .modClock:
            return "Modular arithmetic wraps numbers around a fixed cycle, like a clock. 17 mod 5 = 2 because 17 is 3 full cycles of 5, with 2 left over. It's the mathematical foundation of codes and clocks."
        case .bridgeBuilder:
            return "The Greatest Common Divisor (GCD) is the largest number that divides two numbers evenly. The Euclidean algorithm finds it by repeatedly subtracting the smaller number from the larger number."
        case .floodGate:
            return "The Least Common Multiple (LCM) is the smallest number that both values divide into evenly. It answers: when do two repeating cycles first sync up again?"
        case .cipherLock:
            return "The Chinese Remainder Theorem finds a number that satisfies multiple modular conditions at once. Ancient mathematicians used it to coordinate calendars and coordinate large-scale counting."
        }
    }

    var instructions: String {
        switch self {
        case .factorForge:
            return "Tap prime number tiles to build the prime factorization of the target. Keep going until your product matches."
        case .sieveStrike:
            return "A prime is announced. Tap every multiple of that prime in the number grid. Hit all of them with no mistakes to clear the room."
        case .modClock:
            return "You'll see a starting value and a series of operations. Apply each one on the clock face and find the final result."
        case .bridgeBuilder:
            return "Two numbers are shown. Follow the Euclidean algorithm step by step — divide and take remainders — until you reach the GCD."
        case .floodGate:
            return "Two cycles are given. Find the smallest number that both divide into evenly - that's when the floodgates align."
        case .cipherLock:
            return "A set of modular conditions is shown. Adjust the dial to find a number that satisfies every condition simultaneously, then submit."
        }
    }
}

struct GauntletView: View {
    @Environment(GameState.self) var gameState

    // Called when the player taps "I'm Ready!" on the completion screen.
    var onFinished: (() -> Void)? = nil

    @State var phase: GauntletPhase = .intro
    @State var currentStep: Int = 0
    @State var starsEarned: [Int] = []
    @State var lastStars: Int = 0
    @State var reviewStarsVisible: Bool = false

    // Pre-generated problems (floor=1 for all Gauntlet rooms)
    let forgeProblem   = MathEngine.generateFactorForge(floor: 1)
    let sieveProblem   = MathEngine.generateSieveStrike(floor: 1)
    let clockProblem   = MathEngine.generateModClock(floor: 1)
    let bridgeProblem  = MathEngine.generateBridgeBuilder(floor: 1)
    let floodProblem   = MathEngine.generateFloodGate(floor: 1)
    let cipherProblem  = MathEngine.generateCipherLock(floor: 1)

    var theme: DungeonTheme { gameState.dungeonTheme }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            switch phase {
            case .intro:
                introView
                    .transition(.opacity)
            case .briefing:
                briefingView(for: GauntletStep(rawValue: currentStep)!)
                    .transition(.opacity)
                    .id("briefing-\(currentStep)")
            case .playing:
                roomView(for: GauntletStep(rawValue: currentStep)!)
                    .transition(.opacity)
                    .id(currentStep)
            case .reviewing:
                reviewingView
                    .transition(.opacity)
            case .complete:
                completionView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: phase)
        .animation(.easeInOut(duration: 0.35), value: currentStep)
        .navigationTitle("Gauntlet")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            if phase == .briefing || phase == .playing || phase == .reviewing {
                ToolbarItem(placement: .principal) {
                    progressBar
                }
            }
        }
    }

    var introView: some View {
        VStack(spacing: 28) {
            Spacer()

            Image("gauntlet_header1")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 0) {
                Text("Six challenges await:")
                    .font(.headline)
                    .foregroundColor(theme.subtleText)
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                ForEach(GauntletStep.allCases, id: \.rawValue) { step in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(theme.accent.opacity(0.2))
                                .frame(width: 32, height: 32)
                            Image(systemName: step.icon)
                                .font(.system(size: 14))
                                .foregroundColor(theme.accent)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.title)
                                .font(.body)
                                .foregroundColor(theme.text)
                            Text(step.subtitle)
                                .font(.caption)
                                .foregroundColor(theme.subtleText)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    if step.rawValue < GauntletStep.allCases.count - 1 {
                        Divider()
                            .background(theme.accent.opacity(0.1))
                            .padding(.leading, 54)
                    }
                }
            }
            .background(theme.secondaryBackground.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            Spacer()

            Button {
                withAnimation { phase = .briefing }
            } label: {
                Text("Begin Gauntlet")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.accent.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
            .padding(.bottom)
        }
    }

    func stepColor(for i: Int) -> Color {
        if i < starsEarned.count { return theme.success }
        if i == currentStep { return theme.accent }
        return theme.secondaryBackground
    }

    var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<GauntletStep.allCases.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(stepColor(for: i))
                    .frame(width: 28, height: 4)
            }
        }
    }

    func roomView(for step: GauntletStep) -> some View {
        Group {
            switch step {
            case .factorForge:
                FactorForgeView(problem: forgeProblem, theme: theme) { stars in
                    advance(stars: stars)
                }
            case .sieveStrike:
                SieveStrikeView(problem: sieveProblem, theme: theme) { stars in
                    advance(stars: stars)
                }
            case .modClock:
                ModClockView(problem: clockProblem, theme: theme) { stars in
                    advance(stars: stars)
                }
            case .bridgeBuilder:
                BridgeBuilderView(problem: bridgeProblem, theme: theme) { stars in
                    advance(stars: stars)
                }
            case .floodGate:
                FloodGateView(problem: floodProblem, theme: theme) { stars in
                    advance(stars: stars)
                }
            case .cipherLock:
                CipherLockView(problem: cipherProblem, theme: theme) { stars in
                    advance(stars: stars)
                }
            }
        }
    }

    func briefingView(for step: GauntletStep) -> some View {
        let roomNumber = step.rawValue + 1
        let total = GauntletStep.allCases.count

        return VStack(spacing: 0) {
            Spacer(minLength: 24)

            ZStack {
                Circle()
                    .fill(theme.accent.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: step.icon)
                    .font(.system(size: 32))
                    .foregroundColor(theme.accent)
            }
            .padding(.bottom, 16)

            Text("Room \(roomNumber) of \(total)")
                .font(.caption.bold())
                .foregroundColor(theme.subtleText)
                .padding(.bottom, 4)
            Text(step.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)

            Spacer(minLength: 28)

            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("The Concept", systemImage: "lightbulb.fill")
                        .font(.caption.bold())
                        .foregroundColor(theme.accent)
                    Text(step.concept)
                        .font(.subheadline)
                        .foregroundColor(theme.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(theme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 8) {
                    Label("How to Play", systemImage: "hand.point.up.left.fill")
                        .font(.caption.bold())
                        .foregroundColor(theme.accent)
                    Text(step.instructions)
                        .font(.subheadline)
                        .foregroundColor(theme.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(theme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 28)

            Button {
                withAnimation { phase = .playing }
            } label: {
                HStack(spacing: 8) {
                    Text("Let's Go!")
                        .font(.title3.bold())
                    Image(systemName: "arrow.right")
                        .font(.title3.bold())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.accent.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 24)
        }
    }

    var reviewingView: some View {
        let step = GauntletStep(rawValue: currentStep)!
        let isLast = currentStep == GauntletStep.allCases.count - 1
        let remaining = GauntletStep.allCases.count - currentStep - 1

        return VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(theme.accent.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: step.icon)
                    .font(.system(size: 36))
                    .foregroundColor(theme.accent)
            }

            VStack(spacing: 6) {
                Text(step.title)
                    .font(.title2.bold())
                    .foregroundColor(theme.text)
                Text("Complete!")
                    .font(.headline)
                    .foregroundColor(theme.success)
            }

            HStack(spacing: 16) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 40))
                        .foregroundColor(i < lastStars ? .yellow : theme.secondaryBackground)
                        .scaleEffect(i < (reviewStarsVisible ? lastStars : 0) ? 1.0 : 0.6)
                        .animation(.easeInOut(duration: 0.35).delay(Double(i) * 0.15), value: reviewStarsVisible)
                }
            }

            Text(isLast
                 ? "All six rooms cleared!"
                 : "\(remaining) room\(remaining == 1 ? "" : "s") remaining")
                .font(.subheadline)
                .foregroundColor(theme.subtleText)

            Spacer()

            Button(action: continueFromReview) {
                Text(isLast ? "See Results" : "Next Room →")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.accent.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
            .padding(.bottom)
        }
        .onAppear {
            HapticManager.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                reviewStarsVisible = true
            }
        }
    }

    var completionView: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundColor(theme.success)

            Text("Gauntlet Complete!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)

            Text("You've seen all six room types.\nNow explore the full dungeon.")
                .font(.body)
                .foregroundColor(theme.subtleText)
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                ForEach(0..<starsEarned.count, id: \.self) { i in
                    let stars = starsEarned[i]
                    VStack(spacing: 4) {
                        Text(GauntletStep(rawValue: i)?.title.components(separatedBy: " ").first ?? "")
                            .font(.caption2)
                            .foregroundColor(theme.subtleText)
                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { s in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(s < stars ? .yellow : theme.secondaryBackground)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Spacer()

            Button(action: { onFinished?() }) {
                HStack(spacing: 10) {
                    Text("I'm Ready!")
                        .font(.title3.bold())
                    Image(systemName: "arrow.right")
                        .font(.title3.bold())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.success.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
            .padding(.bottom)
        }
        .padding()
    }

    func advance(stars: Int) {
        lastStars = stars
        reviewStarsVisible = false
        starsEarned.append(stars)
        withAnimation { phase = .reviewing }
    }

    func continueFromReview() {
        reviewStarsVisible = false
        let nextStep = currentStep + 1
        if nextStep >= GauntletStep.allCases.count {
            withAnimation { phase = .complete }
        } else {
            withAnimation {
                currentStep = nextStep
                phase = .briefing
            }
        }
    }
}

enum GauntletPhase: Equatable {
    case intro, briefing, playing, reviewing, complete
}

#Preview {
    NavigationStack {
        GauntletView()
            .environment(GameState())
    }
}

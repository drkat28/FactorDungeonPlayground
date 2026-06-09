import SwiftUI

struct WorkshopView: View {
    var gameState: GameState

    let tools: [(id: Int, name: String, icon: String, description: String, unlockFloor: Int)] = [
        (0, "Factorization",   "hammer.fill",      "Visualize prime factorization of any number",    5),
        (1, "Divisors",        "list.number",       "Find all divisors of any number",                10),
        (2, "Collatz",         "waveform.path",     "Watch the Collatz sequence animate step by step",15),
        (3, "Mod Table",       "clock.fill",        "See a number across all clock faces (mod 2–12)", 20),
        (4, "Primality Tester","checkmark.seal.fill","Instantly test any number for primality",        25),
    ]

    var body: some View {
        ZStack {
            gameState.dungeonTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image("workshop_bench")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [.clear, gameState.dungeonTheme.background],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 60),
                            alignment: .bottom
                        )
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Mathematician's Workshop")
                            .font(.largeTitle.bold())
                            .foregroundColor(gameState.dungeonTheme.text)
                        Text("Recover tools from the ruins of the Great Library.")
                            .font(.subheadline)
                            .foregroundColor(gameState.dungeonTheme.subtleText)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 16) {
                        ForEach(tools, id: \.id) { tool in
                            ToolSlot(
                                tool: tool,
                                isUnlocked: isUnlocked(tool.id),
                                theme: gameState.dungeonTheme
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Workshop")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    func isUnlocked(_ id: Int) -> Bool {
        switch id {
        case 0: return gameState.workshopFactorizationUnlocked
        case 1: return gameState.workshopDivisorsUnlocked
        case 2: return gameState.workshopCollatzUnlocked
        case 3: return gameState.workshopModTableUnlocked
        case 4: return gameState.workshopPrimalityUnlocked
        default: return false
        }
    }
}

struct ToolSlot: View {
    let tool: (id: Int, name: String, icon: String, description: String, unlockFloor: Int)
    let isUnlocked: Bool
    let theme: DungeonTheme

    @State var inputText: String = ""
    @State var result: String = ""
    @State var collatzNavTarget: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isUnlocked ? theme.accent.opacity(0.2) : theme.secondaryBackground)
                        .frame(width: 48, height: 48)
                    Image(systemName: tool.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isUnlocked ? theme.accent : theme.subtleText)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(tool.name)
                        .font(.headline)
                        .foregroundColor(isUnlocked ? theme.text : theme.subtleText)
                    Text(tool.description)
                        .font(.caption)
                        .foregroundColor(theme.subtleText)
                }

                Spacer()

                if !isUnlocked {
                    VStack(spacing: 2) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(theme.subtleText)
                        Text("Floor \(tool.unlockFloor)")
                            .font(.caption2)
                            .foregroundColor(theme.subtleText)
                    }
                }
            }

            if isUnlocked {
                if tool.id == 2 {
                    // Collatz: launches dedicated explorer sheet
                    HStack(spacing: 10) {
                        TextField("Enter a number…", text: $inputText)
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(theme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .foregroundColor(theme.text)

                        Button("Animate →") {
                            if let n = Int(inputText), n > 0 {
                                collatzNavTarget = n
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(theme.accent.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .foregroundColor(.white)
                    }
                } else {
                    HStack(spacing: 10) {
                        TextField("Enter a number…", text: $inputText)
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(theme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .foregroundColor(theme.text)

                        Button("Calculate") {
                            computeResult()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(theme.accent.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .foregroundColor(.white)
                    }

                    if !result.isEmpty {
                        Text(result)
                            .font(.body.monospaced())
                            .foregroundColor(theme.accent)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(theme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding()
        .background(theme.secondaryBackground.opacity(0.6))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isUnlocked ? theme.accent.opacity(0.4) : theme.subtleText.opacity(0.15), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(isUnlocked ? 1.0 : 0.6)
        .navigationDestination(item: $collatzNavTarget) { n in
            CollatzExplorerView(startingNumber: n, theme: theme)
        }
    }

    func computeResult() {
        if let n = Int(inputText), n > 0 {
            switch tool.id {
            case 0: // Factorization
                let factors = MathEngine.primeFactorization(n)
                if factors.isEmpty {
                    result = "\(n) has no prime factors (it is 1)."
                } else {
                    let formatted = Dictionary(factors.map { ($0, 1) }, uniquingKeysWith: +)
                        .sorted { $0.key < $1.key }
                        .map { exp in exp.value > 1 ? "\(exp.key)^\(exp.value)" : "\(exp.key)" }
                        .joined(separator: " × ")
                    result = "\(n) = \(formatted)"
                }
            case 1: // Divisors
                let divs = MathEngine.allDivisors(n)
                result = "Divisors of \(n): \(divs.map { String($0) }.joined(separator: ", "))\nCount: \(divs.count)"
            case 2: // Collatz
                let seq = MathEngine.collatzSequence(n)
                let preview = seq.prefix(12).map { String($0) }.joined(separator: " → ")
                let suffix = seq.count > 12 ? " … → 1  (\(seq.count) steps)" : "  (\(seq.count) steps)"
                result = preview + suffix
            case 3: // Mod Table
                let lines = (2...12).map { m in "mod \(m): \(n % m)" }
                result = lines.joined(separator: "    ")
            case 4: // Primality
                if n == 1 {
                    result = "1 is the unit — neither prime nor composite"
                } else {
                    let prime = MathEngine.isPrime(n)
                    if prime {
                        result = "\(n) is PRIME ✓"
                    } else {
                        let factors = MathEngine.primeFactorization(n)
                        result = "\(n) is composite  =  \(factors.map { String($0) }.joined(separator: " × "))"
                    }
                }
            default:
                result = ""
            }
        } else {
            result = "Enter a positive integer."
        }
    }
}

#Preview {
    NavigationStack {
        WorkshopView(gameState: {
            let gs = GameState()
            gs.workshopFactorizationUnlocked = true
            gs.workshopDivisorsUnlocked = true
            return gs
        }())
    }
}

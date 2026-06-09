import SwiftUI

// Sets up a room with the right problem, shows stars when done
struct RoomSessionView: View {
    let roomName: String
    @Environment(GameState.self) var gameState
    @Environment(\.dismiss) var dismiss

    @State var generatedRoom: GeneratedRoom? = nil
    @State var starsEarned: Int? = nil

    var theme: DungeonTheme { gameState.dungeonTheme }

    var body: some View {
        ZStack {
            if let room = generatedRoom {
                roomContent(room)
                    .navigationTitle(roomName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            StarCounter(count: gameState.stars, theme: theme)
                        }
                    }
            } else {
                theme.background.ignoresSafeArea()
                ProgressView()
                    .tint(theme.accent)
            }

            // Post-room overlay
            if let stars = starsEarned {
                PostRoomView(
                    roomName: roomName,
                    starsEarned: stars,
                    totalStars: gameState.stars,
                    theme: theme,
                    onContinue: handleContinue
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: starsEarned != nil)
        .task { generateProblem() }
    }

    func roomContent(_ room: GeneratedRoom) -> some View {
        Group {
            switch room {
            case .factorForge(let p):
                FactorForgeView(problem: p, theme: theme)  { handleComplete($0) }
            case .sieveStrike(let p):
                SieveStrikeView(problem: p, theme: theme)  { handleComplete($0) }
            case .modClock(let p):
                ModClockView(problem: p, theme: theme)     { handleComplete($0) }
            case .bridgeBuilder(let p):
                BridgeBuilderView(problem: p, theme: theme){ handleComplete($0) }
            case .floodGate(let p):
                FloodGateView(problem: p, theme: theme)    { handleComplete($0) }
            case .cipherLock(let p):
                CipherLockView(problem: p, theme: theme)   { handleComplete($0) }
            }
        }
    }

    func generateProblem() {
        let floor = max(1, gameState.currentFloor)
        switch roomName {
        case "Factor Forge":   generatedRoom = .factorForge(MathEngine.generateFactorForge(floor: floor))
        case "Sieve Strike":   generatedRoom = .sieveStrike(MathEngine.generateSieveStrike(floor: floor))
        case "Mod Clock":      generatedRoom = .modClock(MathEngine.generateModClock(floor: floor))
        case "Bridge Builder": generatedRoom = .bridgeBuilder(MathEngine.generateBridgeBuilder(floor: floor))
        case "Flood Gate":     generatedRoom = .floodGate(MathEngine.generateFloodGate(floor: floor))
        case "Cipher Lock":    generatedRoom = .cipherLock(MathEngine.generateCipherLock(floor: floor))
        default:               generatedRoom = .factorForge(MathEngine.generateFactorForge(floor: floor))
        }
    }

    func handleComplete(_ stars: Int) {
        gameState.earnStars(stars)
        let nextFloor = gameState.currentFloor + 1
        gameState.advanceToFloor(nextFloor)
        starsEarned = stars
    }

    func handleContinue() {
        dismiss()
    }

    var collatzNumber: Int {
        gameState.currentFloor > 0 ? gameState.currentFloor : 7
    }
}

enum GeneratedRoom {
    case factorForge(MathEngine.FactorForgeProblem)
    case sieveStrike(MathEngine.SieveStrikeProblem)
    case modClock(MathEngine.ModClockProblem)
    case bridgeBuilder(MathEngine.BridgeBuilderProblem)
    case floodGate(MathEngine.FloodGateProblem)
    case cipherLock(MathEngine.CipherLockProblem)
}

#Preview {
    NavigationStack {
        RoomSessionView(roomName: "Factor Forge")
            .environment(GameState())
    }
}

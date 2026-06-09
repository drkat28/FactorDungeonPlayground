import SwiftUI

@main
struct DungeonApp: App {
    init() {
        // Register default values for first launch
        UserDefaults.standard.register(defaults: [
            "gf_floor": 1,
            "gf_stars": 0,
            "gf_completedRooms": [],
            "gf_unlockedScrolls": [0],
        ])
    }

    @State var gameState: GameState = {
        let gs = GameState()
        gs.load()
        return gs
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(gameState)
        }
    }
}

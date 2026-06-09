import SwiftUI

struct ContentView: View {
    @Environment(GameState.self) var gameState
    @State var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            MainMenuView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .gauntlet:
                        GauntletView(onFinished: { path = [.dungeonMap] })
                    case .dungeonMap:
                        DungeonMapView()
                    case .room(let name):
                        RoomSessionView(roomName: name)
                    case .workshop:
                        WorkshopView(gameState: gameState)
                    case .codex:
                        CodexView()
                    }
                }
        }
    }
}

import SwiftUI

struct MainMenuView: View {
    @Environment(GameState.self) var gameState

    var body: some View {
        ZStack {
            gameState.dungeonTheme.background
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 12) {
                    Image("menu_hero")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    Text("Factor Dungeon")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(gameState.dungeonTheme.text)

                    Text("Explore the ruins of the Great Library")
                        .font(.title3)
                        .foregroundColor(gameState.dungeonTheme.subtleText)

                    Text(gameState.currentTitle.displayName)
                        .font(.caption.bold())
                        .foregroundColor(gameState.dungeonTheme.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(gameState.dungeonTheme.accent.opacity(0.15))
                        .clipShape(Capsule())
                }

                StarCounter(count: gameState.stars, theme: gameState.dungeonTheme)

                Spacer()

                VStack(spacing: 16) {
                    NavigationLink(value: AppRoute.gauntlet) {
                        MenuButton(
                            title: "Enter Gauntlet",
                            subtitle: "Quick tutorial — all 6 rooms",
                            color: gameState.dungeonTheme.accent,
                            theme: gameState.dungeonTheme
                        )
                    }

                    NavigationLink(value: AppRoute.dungeonMap) {
                        MenuButton(
                            title: "Dungeon Map",
                            subtitle: "Floor \(gameState.currentFloor) — \(gameState.stars) ★ earned",
                            color: .purple,
                            theme: gameState.dungeonTheme
                        )
                    }

                    NavigationLink(value: AppRoute.workshop) {
                        MenuButton(
                            title: "Workshop",
                            subtitle: "Mathematician's tools",
                            color: .teal,
                            theme: gameState.dungeonTheme
                        )
                    }

                    NavigationLink(value: AppRoute.codex) {
                        MenuButton(
                            title: "Codex",
                            subtitle: "Facts & Crypto Scrolls",
                            color: .yellow,
                            theme: gameState.dungeonTheme
                        )
                    }
                }
                .padding(.horizontal, 60)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct MenuButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let theme: DungeonTheme

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(theme.text)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(theme.subtleText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(theme.subtleText)
        }
        .padding()
        .background(color.opacity(0.18))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.55), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        MainMenuView()
            .environment(GameState())
    }
}

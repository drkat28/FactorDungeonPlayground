import SwiftUI

// Screen where you can read facts and crypto scrolls
struct CodexView: View {
    @Environment(GameState.self) var gameState

    var theme: DungeonTheme { gameState.dungeonTheme }

    let roomOrder = GameState.floorRoomNames

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    scrollsSection
                    factsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Codex")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                StarCounter(count: gameState.stars, theme: theme)
            }
        }
    }

    var scrollsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Crypto Scrolls", systemImage: "scroll.fill")
                .font(.title3.bold())
                .foregroundColor(theme.text)

            ForEach(CryptoScrolls.all) { scroll in
                let unlocked = gameState.unlockedScrollIDs.contains(scroll.id)
                ScrollCard(scroll: scroll, unlocked: unlocked, theme: theme)
            }
        }
    }

    var factsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Did You Know?", systemImage: "lightbulb.fill")
                .font(.title3.bold())
                .foregroundColor(theme.text)

            ForEach(roomOrder, id: \.self) { room in
                RoomFactsGroup(
                    roomName: room,
                    facts: DidYouKnowFacts.facts[room] ?? [],
                    theme: theme
                )
            }
        }
    }
}

struct ScrollCard: View {
    let scroll: CryptoScroll
    let unlocked: Bool
    let theme: DungeonTheme

    @State var expanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: unlocked ? "scroll.fill" : "lock.fill")
                    .foregroundColor(unlocked ? .yellow : theme.subtleText)
                Text(unlocked ? scroll.title : "Unlocks at Floor \(scroll.unlockFloor)")
                    .font(.headline)
                    .foregroundColor(unlocked ? theme.text : theme.subtleText)
                Spacer()
                if unlocked {
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(theme.subtleText)
                }
            }

            if unlocked && expanded {
                Text(scroll.body)
                    .font(.body)
                    .foregroundColor(theme.text.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(theme.secondaryBackground.opacity(unlocked ? 0.6 : 0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            if !unlocked { return }
            withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() }
        }
        .accessibilityLabel(unlocked ? scroll.title : "Locked scroll, unlocks at floor \(scroll.unlockFloor)")
    }
}

struct RoomFactsGroup: View {
    let roomName: String
    let facts: [String]
    let theme: DungeonTheme

    @State var expanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() }
            } label: {
                HStack {
                    Text(roomName)
                        .font(.headline)
                        .foregroundColor(theme.accent)
                    Text("(\(facts.count))")
                        .font(.caption)
                        .foregroundColor(theme.subtleText)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(theme.subtleText)
                }
            }
            .buttonStyle(.plain)

            if expanded {
                ForEach(0..<facts.count, id: \.self) { i in
                    let fact = facts[i]
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundColor(.yellow.opacity(0.7))
                            .padding(.top, 3)
                        Text(fact)
                            .font(.subheadline)
                            .foregroundColor(theme.text.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)
                }
                .transition(.opacity)
            }
        }
        .padding()
        .background(theme.secondaryBackground.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        CodexView()
            .environment({
                let gs = GameState()
                gs.unlockedScrollIDs = [0, 1]
                return gs
            }())
    }
}

import SwiftUI

// Shows your stars and a fun fact after finishing a room
struct PostRoomView: View {
    let roomName: String
    let starsEarned: Int       // 1-3
    let totalStars: Int        // running total including this room's stars
    let theme: DungeonTheme
    var onContinue: () -> Void

    @State var visibleStars: Int = 0
    @State var factVisible: Bool = false

    let fact: String

    init(roomName: String, starsEarned: Int, totalStars: Int, theme: DungeonTheme, onContinue: @escaping () -> Void) {
        self.roomName   = roomName
        self.starsEarned = starsEarned
        self.totalStars  = totalStars
        self.theme       = theme
        self.onContinue  = onContinue
        self.fact        = DidYouKnowFacts.random(for: roomName)
    }

    var body: some View {
        ZStack {
            // Dimmed backdrop
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { } // absorb taps

            // Particle sparkle for 3 stars
            if starsEarned == 3 {
                StarBurstView(color: .yellow)
                    .frame(width: 300, height: 300)
            }

            // Card
            VStack(spacing: 24) {
                roomLabel
                starsRow
                factCard
                continueButton
            }
            .padding(28)
            .background(theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 10)
            .padding(.horizontal, 32)
        }
        .onAppear { animateIn() }
    }

    var roomLabel: some View {
        VStack(spacing: 4) {
            Text(roomName)
                .font(.headline)
                .foregroundColor(theme.subtleText)
            Text("Complete!")
                .font(.title.bold())
                .foregroundColor(theme.text)
            Text(GameState.roomSubtitle(for: roomName))
                .font(.caption)
                .foregroundColor(theme.accent)
        }
    }

    var starsRow: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 36))
                        .foregroundColor(i < visibleStars ? .yellow : theme.tile.opacity(0.4))
                        .scaleEffect(i < visibleStars ? 1.0 : 0.7)
                        .animation(.easeInOut(duration: 0.35).delay(Double(i) * 0.15), value: visibleStars)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
                Text("Total: \(totalStars)")
                    .font(.subheadline.bold())
                    .foregroundColor(theme.accent)
            }

            Text(starReason)
                .font(.caption)
                .foregroundColor(theme.subtleText)
        }
    }

    var starReason: String {
        switch starsEarned {
        case 3:  return "Perfect — no mistakes!"
        case 2:  return "Good — one small slip"
        default: return "Completed — keep practising!"
        }
    }

    var factCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Did You Know?", systemImage: "lightbulb.fill")
                .font(.caption.bold())
                .foregroundColor(theme.accent)

            Text(fact)
                .font(.body)
                .foregroundColor(theme.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(theme.background.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(factVisible ? 1 : 0)
        .offset(y: factVisible ? 0 : 12)
        .animation(.easeOut(duration: 0.4).delay(0.5), value: factVisible)
    }

    var continueButton: some View {
        Button(action: {
            HapticManager.light()
            onContinue()
        }) {
            Text("Continue")
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.accent.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .opacity(factVisible ? 1 : 0)
        .animation(.easeOut(duration: 0.3).delay(0.7), value: factVisible)
    }

    func animateIn() {
        HapticManager.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            visibleStars = starsEarned
            factVisible = true
        }
    }
}

#Preview {
    ZStack {
        DungeonTheme.stone.background.ignoresSafeArea()
        PostRoomView(
            roomName: "Factor Forge",
            starsEarned: 3,
            totalStars: 7,
            theme: .stone,
            onContinue: {}
        )
    }
}

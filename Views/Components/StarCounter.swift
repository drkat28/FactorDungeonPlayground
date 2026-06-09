import SwiftUI

// Shows the player's total star count
struct StarCounter: View {
    let count: Int
    let theme: DungeonTheme

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "star.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.yellow)
            Text("\(count)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(theme.text)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(theme.secondaryBackground)
        .clipShape(Capsule())
        .accessibilityLabel("\(count) stars")
    }
}

#Preview {
    StarCounter(count: 14, theme: .stone)
        .padding()
        .background(DungeonTheme.stone.background)
}

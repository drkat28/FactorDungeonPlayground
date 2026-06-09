import SwiftUI

struct DungeonMapView: View {
    @Environment(GameState.self) var gameState

    let totalFloors = 30
    let tileSize: CGFloat = 100
    let corridorHeight: CGFloat = 44

    var theme: DungeonTheme { gameState.dungeonTheme }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            GeometryReader { geo in
                let availWidth = geo.size.width - 48 // horizontal padding
                let leftX: CGFloat = tileSize / 2
                let rightX: CGFloat = availWidth - tileSize / 2

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            headerRow
                                .padding(.top, 12)
                                .padding(.bottom, 16)

                            ForEach(1...totalFloors, id: \.self) { floor in
                                let isLeft = floor % 2 == 1
                                let tileX = isLeft ? leftX : rightX

                                // Corridor from previous tile to this one
                                if floor > 1 {
                                    let prevIsLeft = (floor - 1) % 2 == 1
                                    let prevX = prevIsLeft ? leftX : rightX
                                    CorridorPath(
                                        fromX: prevX,
                                        toX: tileX,
                                        height: corridorHeight,
                                        isCompleted: gameState.completedRooms.contains(floor - 1),
                                        isLocked: floor > gameState.currentFloor,
                                        theme: theme
                                    )
                                    .frame(width: availWidth, height: corridorHeight)
                                }

                                // Room tile
                                HStack(spacing: 0) {
                                    if !isLeft { Spacer() }
                                    MapRoomTile(
                                        floor: floor,
                                        roomName: GameState.roomName(for: floor),
                                        isCurrentFloor: floor == gameState.currentFloor,
                                        isCompleted: gameState.completedRooms.contains(floor),
                                        isLocked: floor > gameState.currentFloor,
                                        theme: theme
                                    )
                                    .frame(width: tileSize, height: tileSize)
                                    .id(floor)
                                    if isLeft { Spacer() }
                                }
                                .frame(width: availWidth)
                            }

                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 24)
                    }
                    .onAppear {
                        let target = min(totalFloors, gameState.currentFloor)
                        proxy.scrollTo(target, anchor: .center)
                    }
                }
            }
        }
        .navigationTitle("Dungeon Map")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                StarCounter(count: gameState.stars, theme: theme)
            }
        }
    }

    var headerRow: some View {
        VStack(spacing: 4) {
            Text("Floor \(gameState.currentFloor) of \(totalFloors)")
                .font(.title2.bold())
                .foregroundColor(theme.text)
            Text(gameState.currentTitle.displayName)
                .font(.subheadline)
                .foregroundColor(theme.accent)
            Text(theme.name)
                .font(.caption)
                .foregroundColor(theme.subtleText)
        }
    }
}

struct MapRoomTile: View {
    let floor: Int
    let roomName: String
    let isCurrentFloor: Bool
    let isCompleted: Bool
    let isLocked: Bool
    let theme: DungeonTheme

    var roomImageName: String {
        switch roomName {
        case "Factor Forge":   return "room_factor_forge"
        case "Sieve Strike":   return "room_sieve_strike"
        case "Bridge Builder": return "room_bridge_builder"
        case "Flood Gate":     return "room_flood_gate"
        case "Cipher Lock":    return "room_cipher_lock"
        default:               return "room_mod_clock"
        }
    }

    var body: some View {
        NavigationLink(value: AppRoute.room(name: roomName)) {
            VStack(spacing: 4) {
                // Room icon
                ZStack {
                    Image(roomImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .opacity(isLocked ? 0.3 : 1.0)
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 13))
                            .foregroundColor(theme.subtleText)
                    }
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.success)
                    }
                }

                // Floor number
                Text("Floor \(floor)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(theme.subtleText)

                // Room name
                Text(roomName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isLocked ? theme.subtleText : theme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(tileBg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(tileBorder, lineWidth: isCurrentFloor ? 2.5 : 1)
            )
            .overlay(alignment: .top) {
                if isCurrentFloor {
                    Text("HERE")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.accent)
                        .clipShape(Capsule())
                        .offset(y: -8)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
        .accessibilityLabel("Floor \(floor): \(roomName)\(isCompleted ? ", completed" : isLocked ? ", locked" : "")")
        .accessibilityHint(isLocked ? "Complete earlier floors to unlock" : "Tap to play this room")
    }

    var tileBg: Color {
        if isCurrentFloor { return theme.accent.opacity(0.1) }
        if isCompleted    { return theme.success.opacity(0.06) }
        return theme.secondaryBackground.opacity(0.5)
    }

    var tileBorder: Color {
        if isCurrentFloor { return theme.accent.opacity(0.8) }
        if isCompleted    { return theme.success.opacity(0.4) }
        return theme.secondaryBackground.opacity(0.6)
    }
}

struct CorridorPath: View {
    let fromX: CGFloat
    let toX: CGFloat
    let height: CGFloat
    let isCompleted: Bool
    let isLocked: Bool
    let theme: DungeonTheme

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: fromX, y: 0))
            path.addLine(to: CGPoint(x: toX, y: height))
        }
        .stroke(
            corridorColor,
            style: StrokeStyle(
                lineWidth: 3,
                lineCap: .round,
                dash: isLocked ? [6, 4] : []
            )
        )
    }

    var corridorColor: Color {
        if isCompleted { return theme.success.opacity(0.5) }
        if isLocked    { return theme.secondaryBackground.opacity(0.5) }
        return theme.accent.opacity(0.4)
    }
}

#Preview {
    NavigationStack {
        DungeonMapView()
            .environment({
                let gs = GameState()
                gs.advanceToFloor(4)
                return gs
            }())
    }
}

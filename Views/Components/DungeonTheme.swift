import SwiftUI

struct DungeonTheme {
    let name: String
    let background: Color
    let secondaryBackground: Color
    let accent: Color
    let text: Color
    let subtleText: Color
    let tile: Color
    let tileText: Color
    let success: Color
    let error: Color

    static let stone = DungeonTheme(
        name: "Stone",
        background:          Color(red: 0.12, green: 0.10, blue: 0.09),
        secondaryBackground: Color(red: 0.18, green: 0.15, blue: 0.13),
        accent:              Color(red: 0.90, green: 0.55, blue: 0.20),  // torchlight orange
        text:                .white,
        subtleText:          Color.white.opacity(0.55),
        tile:                Color(red: 0.30, green: 0.25, blue: 0.22),
        tileText:            .white,
        success:             Color(red: 0.35, green: 0.80, blue: 0.40),
        error:               Color(red: 0.90, green: 0.25, blue: 0.25)
    )

    static let crystalCave = DungeonTheme(
        name: "Crystal Cave",
        background:          Color(red: 0.06, green: 0.08, blue: 0.18),
        secondaryBackground: Color(red: 0.10, green: 0.13, blue: 0.28),
        accent:              Color(red: 0.45, green: 0.65, blue: 1.00),  // ice blue
        text:                .white,
        subtleText:          Color.white.opacity(0.55),
        tile:                Color(red: 0.18, green: 0.22, blue: 0.42),
        tileText:            .white,
        success:             Color(red: 0.30, green: 0.85, blue: 0.75),
        error:               Color(red: 0.85, green: 0.30, blue: 0.55)
    )

    static let volcano = DungeonTheme(
        name: "Volcano",
        background:          Color(red: 0.14, green: 0.05, blue: 0.04),
        secondaryBackground: Color(red: 0.22, green: 0.08, blue: 0.06),
        accent:              Color(red: 1.00, green: 0.38, blue: 0.10),  // ember orange-red
        text:                .white,
        subtleText:          Color.white.opacity(0.55),
        tile:                Color(red: 0.35, green: 0.12, blue: 0.08),
        tileText:            .white,
        success:             Color(red: 0.95, green: 0.75, blue: 0.10),
        error:               Color(red: 1.00, green: 0.15, blue: 0.10)
    )

    static let deepSpace = DungeonTheme(
        name: "Deep Space",
        background:          Color(red: 0.03, green: 0.04, blue: 0.12),
        secondaryBackground: Color(red: 0.06, green: 0.08, blue: 0.20),
        accent:              Color(red: 0.60, green: 0.40, blue: 1.00),  // nebula purple
        text:                .white,
        subtleText:          Color.white.opacity(0.55),
        tile:                Color(red: 0.10, green: 0.10, blue: 0.28),
        tileText:            .white,
        success:             Color(red: 0.30, green: 0.90, blue: 0.60),
        error:               Color(red: 0.90, green: 0.20, blue: 0.50)
    )

    static let insideTheMachine = DungeonTheme(
        name: "Inside the Machine",
        background:          Color(red: 0.04, green: 0.08, blue: 0.04),
        secondaryBackground: Color(red: 0.06, green: 0.14, blue: 0.06),
        accent:              Color(red: 0.10, green: 0.90, blue: 0.40),  // circuit green
        text:                Color(red: 0.85, green: 1.00, blue: 0.85),
        subtleText:          Color(red: 0.85, green: 1.00, blue: 0.85).opacity(0.55),
        tile:                Color(red: 0.08, green: 0.20, blue: 0.08),
        tileText:            Color(red: 0.10, green: 0.90, blue: 0.40),
        success:             Color(red: 0.10, green: 0.95, blue: 0.50),
        error:               Color(red: 0.90, green: 0.20, blue: 0.10)
    )

    static let all: [DungeonTheme] = [.stone, .crystalCave, .volcano, .deepSpace, .insideTheMachine]
}

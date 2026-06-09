import Foundation

enum AppRoute: Hashable {
    case gauntlet
    case dungeonMap
    case room(name: String)
    case workshop
    case codex
}

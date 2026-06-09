import UIKit

struct HapticManager {
    // Call on correct answer / room completion
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // Call on wrong answer / mistake
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    // Call when collecting a star
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // used when tapping any tile in Factor Forge
    static func soft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    // used when tapping in Sieve Strike or confirming a button
    static func rigid() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    // used for big errors like when time runs out
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}

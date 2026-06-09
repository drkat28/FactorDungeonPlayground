import Observation
import Foundation

@Observable
class GameState {
    var currentFloor: Int = 1
    var stars: Int = 0
    var completedRooms: Set<Int> = []

    var currentTitle: PlayerTitle = .apprenticeFactorer
    var dungeonTheme: DungeonTheme = .stone

    var workshopFactorizationUnlocked: Bool = false
    var workshopDivisorsUnlocked: Bool = false
    var workshopCollatzUnlocked: Bool = false
    var workshopModTableUnlocked: Bool = false
    var workshopPrimalityUnlocked: Bool = false

    var unlockedScrollIDs: [Int] = []

    init() {
        load()
        updateWorkshopUnlocks()
        // Always unlock the first scroll (Level 1)
        if !unlockedScrollIDs.contains(0) {
            unlockedScrollIDs.insert(0, at: 0)
        }
    }

    static let floorRoomNames = [
        "Factor Forge", "Sieve Strike", "Mod Clock",
        "Bridge Builder", "Flood Gate", "Cipher Lock",
    ]

    static func roomName(for floor: Int) -> String {
        let idx = (max(1, floor) - 1) % floorRoomNames.count
        return floorRoomNames[idx]
    }

    static func roomSubtitle(for name: String) -> String {
        switch name {
        case "Factor Forge":   return "Break numbers into prime factors"
        case "Sieve Strike":   return "Find all multiples of a prime"
        case "Mod Clock":      return "Clock arithmetic — addition wraps around"
        case "Bridge Builder": return "Find the greatest common divisor"
        case "Flood Gate":     return "When do two cycles align?"
        case "Cipher Lock":    return "Solve a system of remainders"
        default:               return ""
        }
    }

    func advanceToFloor(_ floor: Int) {
        currentFloor = floor
        completedRooms.insert(floor - 1)
        updateTheme()
        updateTitle()
        updateWorkshopUnlocks()
        checkScrollUnlocks()
        save()
    }

    func earnStars(_ count: Int) {
        stars += count
        save()
    }

    func spendStars(_ count: Int) -> Bool {
        if stars < count { return false }
        stars -= count
        save()
        return true
    }

    enum Keys {
        static let floor           = "gf_floor"
        static let stars           = "gf_stars"
        static let completedRooms  = "gf_completedRooms"
        static let unlockedScrolls = "gf_unlockedScrolls"
    }

    func save() {
        let ud = UserDefaults.standard
        ud.set(currentFloor, forKey: Keys.floor)
        ud.set(stars,         forKey: Keys.stars)
        ud.set(Array(completedRooms), forKey: Keys.completedRooms)
        ud.set(unlockedScrollIDs,     forKey: Keys.unlockedScrolls)
    }

    func load() {
        let ud = UserDefaults.standard
        currentFloor     = max(1, ud.integer(forKey: Keys.floor)) // make sure floor is at least 1 (old saves might have stored 0)
        stars            = ud.integer(forKey: Keys.stars)
        let rooms        = (ud.array(forKey: Keys.completedRooms) as? [Int]) ?? []
        let scrolls      = (ud.array(forKey: Keys.unlockedScrolls) as? [Int]) ?? []
        completedRooms   = Set(rooms)
        unlockedScrollIDs = scrolls

        updateTheme()
        updateTitle()
        updateWorkshopUnlocks()
    }

    func resetProgress() {
        currentFloor = 0; stars = 0
        completedRooms = []; unlockedScrollIDs = []
        workshopFactorizationUnlocked = false
        workshopDivisorsUnlocked = false
        workshopCollatzUnlocked = false
        workshopModTableUnlocked = false
        workshopPrimalityUnlocked = false
        dungeonTheme = .stone
        currentTitle = .apprenticeFactorer
        save()
    }

    func updateTheme() {
        switch currentFloor {
        case 0...10:  dungeonTheme = .stone
        case 11...20: dungeonTheme = .crystalCave
        case 21...30: dungeonTheme = .volcano
        case 31...40: dungeonTheme = .deepSpace
        default:      dungeonTheme = .insideTheMachine
        }
    }

    func updateTitle() {
        for title in PlayerTitle.allCases.reversed() {
            if currentFloor >= title.requiredFloor {
                currentTitle = title; break
            }
        }
    }

    func updateWorkshopUnlocks() {
        if currentFloor >= 5  { workshopFactorizationUnlocked = true }
        if currentFloor >= 10 { workshopDivisorsUnlocked = true }
        if currentFloor >= 15 { workshopCollatzUnlocked = true }
        if currentFloor >= 20 { workshopModTableUnlocked = true }
        if currentFloor >= 25 { workshopPrimalityUnlocked = true }
    }

    func checkScrollUnlocks() {
        let milestones = [5, 10, 15, 20, 25, 30, 40, 50]
        for i in 0..<milestones.count {
            let m = milestones[i]
            if currentFloor >= m && !unlockedScrollIDs.contains(i) {
                unlockedScrollIDs.append(i)
            }
        }
    }
}

enum PlayerTitle: CaseIterable {
    case apprenticeFactorer, sieveInitiate, numberCruncher
    case primeSeekerTitle, gcdGuardian, modularThinker
    case cipherBreaker, primeWarden, rsaArchitect

    var requiredFloor: Int {
        switch self {
        case .apprenticeFactorer: return 0
        case .sieveInitiate:      return 5
        case .numberCruncher:     return 10
        case .primeSeekerTitle:   return 15
        case .gcdGuardian:        return 20
        case .modularThinker:     return 25
        case .cipherBreaker:      return 30
        case .primeWarden:        return 40
        case .rsaArchitect:       return 50
        }
    }

    var displayName: String {
        switch self {
        case .apprenticeFactorer: return "Apprentice Factorer"
        case .sieveInitiate:      return "Sieve Initiate"
        case .numberCruncher:     return "Number Cruncher"
        case .primeSeekerTitle:   return "Prime Seeker"
        case .gcdGuardian:        return "GCD Guardian"
        case .modularThinker:     return "Modular Thinker"
        case .cipherBreaker:      return "Cipher Breaker"
        case .primeWarden:        return "Prime Warden"
        case .rsaArchitect:       return "RSA Architect"
        }
    }
}

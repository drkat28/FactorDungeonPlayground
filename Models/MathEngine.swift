import Foundation

struct MathEngine {

    static func primeFactorization(_ n: Int) -> [Int] {
        if n <= 1 { return [] }
        var factors: [Int] = []
        var remaining = n
        var divisor = 2
        while divisor * divisor <= remaining {
            while remaining % divisor == 0 {
                factors.append(divisor)
                remaining /= divisor
            }
            divisor += 1
        }
        if remaining > 1 { factors.append(remaining) }
        return factors
    }

    // TODO: make array and cache numbers - we won't use numbers > X,000 
    static func isPrime(_ n: Int) -> Bool {
        if n < 2 { return false }
        if n == 2 { return true }
        if n % 2 == 0 { return false }
        var i = 3
        while i * i <= n {
            if n % i == 0 { return false }
            i += 2
        }
        return true
    }

    static func gcd(_ a: Int, _ b: Int) -> Int {
        let a = abs(a), b = abs(b)
        if b == 0 { return a }
        return gcd(b, a % b)
    }

    static func lcm(_ a: Int, _ b: Int) -> Int {
        if a == 0 || b == 0 { return 0 }
        return abs(a) / gcd(a, b) * abs(b)
    }

    // Returns array where index i is true if i is prime
    static func sieveOfEratosthenes(upTo n: Int) -> [Bool] {
        if n < 2 { return Array(repeating: false, count: max(0, n + 1)) }
        var sieve = Array(repeating: true, count: n + 1)
        sieve[0] = false
        sieve[1] = false
        var i = 2
        while i * i <= n {
            if sieve[i] {
                var multiple = i * i
                while multiple <= n {
                    sieve[multiple] = false
                    multiple += i
                }
            }
            i += 1
        }
        return sieve
    }

    static func collatzSequence(_ n: Int) -> [Int] {
        if n < 1 { return [] }
        var seq = [n]
        var current = n
        while current != 1 {
            current = current % 2 == 0 ? current / 2 : current * 3 + 1
            seq.append(current)
        }
        return seq
    }

    // Chinese Remainder Theorem solver - finds a number that fits all conditions
    static func solveChineseRemainder(remainders: [(remainder: Int, modulus: Int)]) -> Int? {
        if remainders.isEmpty { return nil }
        var x = remainders[0].remainder
        var step = remainders[0].modulus
        for pair in remainders.dropFirst() {
            let m = pair.modulus
            let r = pair.remainder
            // Find the smallest x that satisfies current constraints + new one
            var found = false
            for k in 0..<m {
                if (x + step * k) % m == r {
                    x = x + step * k
                    step = lcm(step, m)
                    found = true
                    break
                }
            }
            if !found { return nil }
        }
        return x
    }

    // Modular arithmetic, always returns a non-negative result
    static func mod(_ a: Int, _ m: Int) -> Int {
        if m <= 0 { return 0 }
        return ((a % m) + m) % m
    }

    static func allDivisors(_ n: Int) -> [Int] {
        if n <= 0 { return [] }
        var divisors: [Int] = []
        var i = 1
        while i * i <= n {
            if n % i == 0 {
                divisors.append(i)
                if i != n / i { divisors.append(n / i) }
            }
            i += 1
        }
        return divisors.sorted()
    }

    struct FactorForgeProblem {
        let target: Int
        let solution: [Int]        // prime factors in order
    }

    static func generateFactorForge(floor: Int) -> FactorForgeProblem {
        let target: Int
        switch floor {
        case 1...5:
            let candidates = [6, 8, 9, 10, 12, 14, 15, 18, 20, 21, 22, 24, 25, 26, 28]
            target = candidates.randomElement()!
        case 6...15:
            let candidates = [36, 40, 42, 48, 54, 60, 72, 84, 90, 96, 100, 120, 126, 132, 144, 150, 180, 200]
            target = candidates.randomElement()!
        default:
            let primes = [2, 3, 5, 7, 11, 13]
            let a = primes.randomElement()!, b = primes.randomElement()!, c = primes.randomElement()!
            target = a * b * c * (floor > 25 ? b : 1)
        }
        return FactorForgeProblem(target: target, solution: primeFactorization(target))
    }

    struct SieveStrikeProblem {
        let gridSize: Int          // sieve from 2 to gridSize
        let announcedPrime: Int
        let multiples: [Int]       // correct targets to tap
    }

    static func generateSieveStrike(floor: Int) -> SieveStrikeProblem {
        let gridSize: Int
        switch floor {
        case 1...5:  gridSize = 30
        case 6...15: gridSize = 50
        default:     gridSize = 80
        }
        let sieve = sieveOfEratosthenes(upTo: gridSize)
        let primes = sieve.indices.filter { sieve[$0] }
        let prime = primes.prefix(8).filter { $0 > 2 }.randomElement() ?? 3
        let multiples = (1...(gridSize / prime)).map { prime * $0 }
        return SieveStrikeProblem(gridSize: gridSize, announcedPrime: prime, multiples: multiples)
    }

    struct BridgeBuilderProblem {
        let a: Int
        let b: Int
        let solution: Int          // gcd(a, b)
        let steps: [(Int, Int)]    // each step: (bigger number, smaller number)
    }

    static func generateBridgeBuilder(floor: Int) -> BridgeBuilderProblem {
        let pairs: [(Int, Int)]
        switch floor {
        case 1...5:  pairs = [(12,8),(15,10),(18,12),(24,16),(20,15),(21,14)]
        case 6...15: pairs = [(144,60),(48,36),(90,60),(84,56),(100,75),(126,84)]
        default:     pairs = [(360,240),(504,360),(630,420),(840,560),(1000,750)]
        }
        let (a, b) = pairs.randomElement()!
        var steps: [(Int, Int)] = []
        var x = max(a, b), y = min(a, b)
        while y != 0 {
            steps.append((x, y))
            let r = x % y
            x = y; y = r
        }
        return BridgeBuilderProblem(a: a, b: b, solution: gcd(a, b), steps: steps)
    }

    struct FloodGateProblem {
        let intervalA: Int
        let intervalB: Int
        let solution: Int          // lcm(intervalA, intervalB)
    }

    static func generateFloodGate(floor: Int) -> FloodGateProblem {
        let pairs: [(Int, Int)]
        switch floor {
        case 1...5:  pairs = [(2,3),(3,4),(4,6),(2,5),(3,5)]
        case 6...15: pairs = [(4,7),(5,6),(3,8),(6,9),(3,10)]
        default:     pairs = [(8,12),(10,15),(6,10)]
        }
        let (a, b) = pairs.randomElement()!
        return FloodGateProblem(intervalA: a, intervalB: b, solution: lcm(a, b))
    }

    struct CipherLockProblem {
        let conditions: [(remainder: Int, modulus: Int)]
        let solution: Int
    }

    static func generateCipherLock(floor: Int) -> CipherLockProblem {
        let pairs: [[(remainder: Int, modulus: Int)]]
        switch floor {
        case 1...5:
            pairs = [
                [(2,3),(1,5)],
                [(1,3),(2,5)],
                [(0,3),(3,5)],
                [(2,4),(1,5)],
            ]
        case 6...15:
            pairs = [
                [(3,5),(2,7)],
                [(1,4),(3,7)],
                [(2,5),(1,6)],
                [(3,8),(5,11)],
            ]
        default:
            pairs = [
                [(2,5),(3,7),(1,3)],
                [(1,4),(2,9),(3,11)],
                [(4,7),(3,8),(2,5)],
            ]
        }
        let conditions = pairs.randomElement()!
        let solution = solveChineseRemainder(remainders: conditions) ?? 1
        return CipherLockProblem(conditions: conditions, solution: solution)
    }

    struct ModClockProblem {
        let modulus: Int
        let start: Int
        let operations: [(symbol: String, value: Int)]
        let solution: Int
    }

    static func generateModClock(floor: Int) -> ModClockProblem {
        let modulus: Int
        let ops: [(String, Int)]
        switch floor {
        case 1...5:
            modulus = [5, 6, 7].randomElement()!
            ops = [("+", Int.random(in: 2...modulus-1))]
        case 6...15:
            modulus = [7, 8, 10, 11, 12].randomElement()!
            let useMultiply = Bool.random()
            ops = useMultiply ? [("×", Int.random(in: 2...4))] : [("+", Int.random(in: 3...modulus-1))]
        default:
            modulus = [11, 12, 13].randomElement()!
            let a = Int.random(in: 2...modulus-1)
            let b = Int.random(in: 2...4)
            ops = [("+", a), ("×", b)]
        }
        let start = Int.random(in: 0...(modulus - 1))
        var current = start
        for op in ops {
            switch op.0 {
            case "+": current = mod(current + op.1, modulus)
            case "×": current = mod(current * op.1, modulus)
            default: break
            }
        }
        let operations = ops.map { (symbol: $0.0, value: $0.1) }
        return ModClockProblem(modulus: modulus, start: start, operations: operations, solution: current)
    }
}

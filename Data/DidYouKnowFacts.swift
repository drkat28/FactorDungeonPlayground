import Foundation

struct DidYouKnowFacts {

    static let facts: [String: [String]] = [
        "Factor Forge": [
            "91 fools everyone — it looks prime but it's 7 × 13!",
            "Every even number can be divided by 2. That makes 2 the only even prime number!",
            "The number 1 is not prime and not composite — it's in a category all by itself.",
            "A perfect number equals the sum of its divisors. 6 = 1 + 2 + 3. The next one is 28!",
            "The largest known prime has over 24 million digits. It would take you weeks just to write it down!",
        ],
        "Sieve Strike": [
            "Eratosthenes invented this algorithm over 2,200 years ago in ancient Greece.",
            "The sieve can find all primes up to 10 million in under a second on a modern computer.",
            "Eratosthenes used just a stick and its shadow to measure the whole distance around the Earth with over 98% accuracy!",
            "There are infinitely many primes. Euclid proved this around 300 BCE with a one-paragraph proof.",
            "The gap between consecutive primes can be arbitrarily large — but twin primes (p, p+2) never seem to run out.",
        ],
        "Bridge Builder": [
            "Euclid described this algorithm around 300 BCE. It may be the oldest algorithm still in daily use.",
            "If two numbers have a GCD of 1, they're called 'coprime' - they share no common factors at all.",
            "The Euclidean trick is super fast: solving it takes at most 5 times the number of digits in your smaller number!",
            "GCD(Fibonacci(n), Fibonacci(m)) = Fibonacci(GCD(n, m)). Fibonacci and GCD are deeply connected.",
            "Computer secret codes (RSA) work because finding common divisors is fast, but finding the factors of giant numbers is super slow.",
        ],
        "Flood Gate": [
            "LCM tells you when two cycles align. It predicts eclipses, gear rotations, and bus schedules.",
            "For any two numbers: GCD × LCM = the product of the two numbers. Always, without exception.",
            "Ancient Chinese astronomers used LCM to predict when multiple planet cycles would coincide.",
            "The Metonic cycle — 19 years — is roughly the LCM of the lunar month and solar year.",
            "Cicada bugs hatch every 13 or 17 years (both primes). Their LCM is 221 years, so different swarms rarely hatch together!",
        ],
        "Cipher Lock": [
            "Sun Tzu described this theorem in the 3rd century — the mathematician, not the general behind The Art of War.",
            "The Chinese Remainder Theorem (CRT) helps computers unlock RSA secret codes four times faster.",
            "Ancient Chinese generals used this exact trick to quickly count thousands of soldiers.",
            "CRT lets computer chips solve giant math problems faster by chopping the big numbers into smaller pieces.",
            "In the year 628, an Indian mathematician, Brahmagupta, was already solving these tricky remainder puzzles.",
        ],
        "Mod Clock": [
            "Every clock is a mod-12 calculator. 10 o'clock + 5 hours = 3 o'clock. That's modular arithmetic.",
            "Modular arithmetic is the foundation of every hash function, digital signature, and checksum.",
            "Book barcodes and credit cards use mod-10 math to instantly catch if you type a number wrong.",
            "Safe websites use 'Diffie-Hellman' math: mixing giant numbers with mod to lock up your data before sending it!",
            "Fermat's Little Theorem: for any prime p and integer a not divisible by p, a^(p−1) ≡ 1 (mod p).",
        ],
    ]

    static func random(for roomName: String) -> String {
        facts[roomName]?.randomElement() ?? "Mathematics is the language in which the universe is written."
    }
}

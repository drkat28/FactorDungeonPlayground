import Foundation

// Crypto stories that unlock as you go higher in the dungeon
struct CryptoScroll: Identifiable {
    let id: Int
    let title: String
    let body: String
    let unlockFloor: Int
}

enum CryptoScrolls {
    static let all: [CryptoScroll] = [
        CryptoScroll(
            id: 0,
            title: "The Prime Foundation",
            body: "Every number greater than 1 can be broken into prime factors in exactly one way. This uniqueness, called the Fundamental Theorem of Arithmetic, is the bedrock of modern encryption. Without it, RSA and many other systems would crumble.",
            unlockFloor: 5
        ),
        CryptoScroll(
            id: 1,
            title: "Sieve of Eratosthenes",
            body: "Around 240 BC, the Greek mathematician Eratosthenes invented a beautifully simple method to find all primes up to any limit. Modern cryptographic key generation still relies on fast prime-finding algorithms that descend from his ancient sieve.",
            unlockFloor: 10
        ),
        CryptoScroll(
            id: 2,
            title: "The Collatz Mystery",
            body: "Pick any positive integer: if even, halve it; if odd, triple it and add one. This simple rule always seems to reach 1, but nobody has ever proved it. Mathematician Paul Erdős said 'Mathematics is not yet ready for such problems.' It remains one of the great unsolved puzzles.",
            unlockFloor: 15
        ),
        CryptoScroll(
            id: 3,
            title: "Modular Arithmetic & Clocks",
            body: "When we say 15:00 is the same as 3 PM, we're doing arithmetic modulo 12. Cryptographers use modular arithmetic with enormous numbers to scramble messages. The 'wrap-around' property makes it easy to encode but extraordinarily hard to reverse without the key.",
            unlockFloor: 20
        ),
        CryptoScroll(
            id: 4,
            title: "Euclid's GCD Algorithm",
            body: "Over 2,300 years ago, Euclid described an algorithm to find the greatest common divisor of two numbers using repeated subtraction. It's one of the oldest algorithms still in everyday use — modern computers run it billions of times to set up secure connections.",
            unlockFloor: 25
        ),
        CryptoScroll(
            id: 5,
            title: "RSA: The Public-Key Revolution",
            body: "In 1977, Rivest, Shamir, and Adleman published RSA, a system where you can share your encryption key publicly. Its security rests on one fact: multiplying two large primes is easy, but factoring the product back is astronomically hard. Every HTTPS connection you make uses ideas from RSA.",
            unlockFloor: 30
        ),
        CryptoScroll(
            id: 6,
            title: "The Chinese Remainder Theorem",
            body: "A 1,700-year-old theorem from ancient China lets you reconstruct a number from its remainders when divided by several coprime moduli. Today, it speeds up RSA decryption by splitting one giant calculation into several smaller ones that run in parallel.",
            unlockFloor: 40
        ),
        CryptoScroll(
            id: 7,
            title: "Quantum Threat & Post-Quantum Hope",
            body: "Quantum computers could one day factor huge numbers in minutes, breaking RSA. Cryptographers are already building 'post-quantum' systems based on lattice problems and error-correcting codes — mathematical puzzles that even quantum machines find hard.",
            unlockFloor: 50
        ),
    ]

    static func scroll(for id: Int) -> CryptoScroll? {
        all.first { $0.id == id }
    }
}

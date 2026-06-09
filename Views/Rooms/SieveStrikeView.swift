import SwiftUI

struct SieveStrikeView: View {
    let problem: MathEngine.SieveStrikeProblem
    let theme: DungeonTheme
    var onComplete: (Int) -> Void

    @State var struckNumbers: Set<Int> = []
    @State var mistakes: Int = 0
    @State var isComplete: Bool = false
    @State var timeLeft: Double = 30
    @State var timerActive: Bool = true
    @State var displayNumbers: [Int] = []
    @State var shapeRowSizes: [Int] = []

    @State var timer: Timer? = nil

    var remainingTargets: [Int] {
        problem.multiples.filter { !struckNumbers.contains($0) }
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                timerBar
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                numberGrid
                    .padding(.horizontal, 12)

                Spacer(minLength: 8)
            }
        }
        .onAppear {
            setupDisplayNumbers()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if !timerActive || isComplete { return }
                if timeLeft > 0 {
                    timeLeft -= 0.1
                } else {
                    handleComplete()
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    var header: some View {
        VStack(spacing: 4) {
            Text("Sieve Strike")
                .font(.headline)
                .foregroundColor(theme.subtleText)
            Text("Strike all multiples of \(problem.announcedPrime)")
                .font(.title2.bold())
                .foregroundColor(theme.text)
            HStack(spacing: 4) {
                Text("\(remainingTargets.count) remaining")
                    .font(.subheadline)
                    .foregroundColor(theme.accent)
                Text("·")
                    .foregroundColor(theme.subtleText)
                Text("\(mistakes) mistakes")
                    .font(.subheadline)
                    .foregroundColor(mistakes > 0 ? theme.error : theme.subtleText)
            }
        }
    }

    var timerBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(theme.secondaryBackground)
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 4)
                    .fill(timerColor)
                    .frame(width: geo.size.width * CGFloat(timeLeft / 30), height: 8)
                    .animation(.linear(duration: 0.1), value: timeLeft)
            }
        }
        .frame(height: 8)
    }

    var numberGrid: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 8
            let maxCols = shapeRowSizes.max() ?? 1
            let rawSize = (geo.size.width - spacing * CGFloat(maxCols - 1)) / CGFloat(maxCols)
            let tileSize = max(44, min(80, rawSize))
            let rows = shapeRows

            ScrollView {
                VStack(spacing: spacing) {
                    ForEach(0..<rows.count, id: \.self) { i in
                        let row = rows[i]
                        HStack(spacing: spacing) {
                            ForEach(row, id: \.self) { n in
                                NumberCell(
                                    number: n,
                                    state: cellState(for: n),
                                    theme: theme
                                ) {
                                    tapped(n)
                                }
                                .frame(width: tileSize, height: tileSize)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
    }

    var shapeRows: [[Int]] {
        var result: [[Int]] = []
        var idx = 0
        for size in shapeRowSizes {
            let end = min(idx + size, displayNumbers.count)
            result.append(Array(displayNumbers[idx..<end]))
            idx = end
        }
        return result
    }

    func setupDisplayNumbers() {
        if !displayNumbers.isEmpty { return }

        // how many tiles to show — more on higher floors, always includes all the multiples
        let base: ClosedRange<Int> = {
            switch problem.gridSize {
            case ...30: return 8...12
            case ...50: return 12...16
            default:    return 16...20
            }
        }()
        let displayCount = min(20, max(problem.multiples.count + 2, Int.random(in: base)))

        // Shape
        shapeRowSizes = SieveShape.allCases.randomElement()!.rowSizes(for: displayCount)

        // Numbers
        let mults = problem.multiples
        let nonMultiples = (2...problem.gridSize).filter { !mults.contains($0) }
        let needed = max(0, displayCount - mults.count)
        let distractors = Array(nonMultiples.shuffled().prefix(needed))
        displayNumbers = (mults + distractors).shuffled()
    }

    func cellState(for n: Int) -> NumberCellState {
        if struckNumbers.contains(n) {
            return problem.multiples.contains(n) ? .correctlyStruck : .wronglyStruck
        }
        return .normal
    }

    func tapped(_ n: Int) {
        if isComplete { return }
        if struckNumbers.contains(n) { return }

        struckNumbers.insert(n)

        if problem.multiples.contains(n) {
            HapticManager.rigid()
        } else {
            mistakes += 1
            HapticManager.error()
        }

        if remainingTargets.isEmpty {
            handleComplete()
        }
    }

    func handleComplete() {
        if isComplete { return }
        isComplete = true
        timerActive = false
        let earned = max(1, 3 - mistakes)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onComplete(earned)
        }
    }

    var timerColor: Color {
        if timeLeft > 15 { return theme.success }
        if timeLeft > 8 { return .orange }
        return theme.error
    }
}

enum SieveShape: CaseIterable {
    case triangle, square, trapezoid, circle

    func rowSizes(for n: Int) -> [Int] {
        switch self {
        case .triangle:
            // ascending rows: 1, 2, 3, …
            var rows: [Int] = [], remaining = n, size = 1
            while remaining > 0 {
                let r = min(size, remaining)
                rows.append(r); remaining -= r; size += 1
            }
            return rows

        case .square:
            // nearly-square grid
            let cols = Int(Double(n).squareRoot().rounded(.up))
            var rows: [Int] = [], remaining = n
            while remaining > 0 {
                let r = min(cols, remaining); rows.append(r); remaining -= r
            }
            return rows

        case .trapezoid:
            // narrow top, wide bottom
            return proportional(n, parts: [3, 3, 4, 5])

        case .circle:
            // bell-shaped rows forming an oval
            let parts: [Int] = n <= 10  ? [1, 2, 3, 2, 1]
                             : n <= 14  ? [2, 3, 4, 3, 2]
                             : n <= 17  ? [2, 4, 5, 4, 2]
                             :            [2, 4, 6, 5, 3]
            return proportional(n, parts: parts)
        }
    }

    // resize the row sizes to add up to n, fix any rounding leftover on the biggest row
    func proportional(_ n: Int, parts: [Int]) -> [Int] {
        var total = 0
        for p in parts { total += p }
        var rows: [Int] = []
        for p in parts {
            rows.append(Int((Double(p) / Double(total) * Double(n)).rounded()))
        }
        var sum = 0
        for r in rows { sum += r }
        let diff = n - sum
        if diff != 0 {
            var maxIdx = 0
            for i in 1..<rows.count {
                if rows[i] > rows[maxIdx] { maxIdx = i }
            }
            rows[maxIdx] += diff
        }
        var result: [Int] = []
        for r in rows {
            if r > 0 { result.append(r) }
        }
        return result
    }
}

enum NumberCellState { case normal, correctlyStruck, wronglyStruck }

struct NumberCell: View {
    let number: Int
    let state: NumberCellState
    let theme: DungeonTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                HexagonShape()
                    .fill(bgColor)
                HexagonShape()
                    .stroke(borderColor, lineWidth: 1.5)
                Text("\(number)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(foreColor)
            }
            .opacity(state == .correctlyStruck ? 0.3 : 1.0)
            .animation(.easeOut(duration: 0.15), value: state)
        }
        .buttonStyle(.plain)
        .disabled(state != .normal)
        .accessibilityLabel("Number \(number)")
        .accessibilityHint(state == .normal ? "Tap to strike" : (state == .correctlyStruck ? "Correctly struck" : "Wrongly struck"))
    }

    var bgColor: Color {
        switch state {
        case .normal:          return theme.tile.opacity(0.7)
        case .correctlyStruck: return theme.success.opacity(0.25)
        case .wronglyStruck:   return theme.error.opacity(0.25)
        }
    }
    var foreColor: Color {
        switch state {
        case .normal:          return theme.tileText
        case .correctlyStruck: return theme.success
        case .wronglyStruck:   return theme.error
        }
    }
    var borderColor: Color {
        switch state {
        case .normal:          return theme.accent.opacity(0.3)
        case .correctlyStruck: return theme.success.opacity(0.5)
        case .wronglyStruck:   return theme.error.opacity(0.6)
        }
    }
}

#Preview {
    SieveStrikeView(
        problem: MathEngine.generateSieveStrike(floor: 1),
        theme: .stone,
        onComplete: { stars in print("Stars: \(stars)") }
    )
}

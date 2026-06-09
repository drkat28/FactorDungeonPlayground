import SwiftUI

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX, cy = rect.midY
        let r = min(rect.width, rect.height) / 2
        var path = Path()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let pt = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }
}

struct HexTile: View {
    let label: String?
    let color: Color
    let size: CGFloat        // radius

    var w: CGFloat { size * sqrt(3) }
    var h: CGFloat { size * 2 }

    var body: some View {
        ZStack {
            HexagonShape()
                .fill(color)
            HexagonShape()
                .stroke(color.opacity(0.4), lineWidth: 1)
            if let label {
                Text(label)
                    .font(.system(size: size * 0.55, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(width: w, height: h)
    }
}

struct HexTileGrid: View {
    let count: Int
    let color: Color
    let hexRadius: CGFloat

    var tilesPerRow: Int {
        // Aim for a roughly square grid
        max(1, Int(ceil(sqrt(Double(count) * 1.15))))
    }
    var w: CGFloat { hexRadius * sqrt(3) }
    var h: CGFloat { hexRadius * 2 }
    var hStep: CGFloat { w + 1 }
    var vStep: CGFloat { hexRadius * 1.5 + 1 }

    var rows: Int { (count + tilesPerRow - 1) / tilesPerRow }
    var gridWidth:  CGFloat { CGFloat(tilesPerRow) * hStep + w / 2 }
    var gridHeight: CGFloat { CGFloat(max(0, rows - 1)) * vStep + h }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear.frame(width: gridWidth, height: gridHeight)
            ForEach(0..<count, id: \.self) { i in
                let row = i / tilesPerRow
                let col = i % tilesPerRow
                let x = CGFloat(col) * hStep + (row % 2 == 1 ? w / 2 : 0)
                let y = CGFloat(row) * vStep
                HexTile(label: nil, color: color, size: hexRadius)
                    .offset(x: x, y: y)
            }
        }
        .frame(width: gridWidth, height: gridHeight)
    }
}

#Preview {
    VStack(spacing: 24) {
        HexTileGrid(count: 12, color: .orange, hexRadius: 22)
        HexTileGrid(count: 36, color: .purple, hexRadius: 16)
    }
    .padding()
    .background(Color(red: 0.1, green: 0.08, blue: 0.12))
}

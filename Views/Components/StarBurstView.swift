import SwiftUI

// Sparkle animation when you finish a room
struct StarBurstView: View {
    let color: Color
    @State var animate = false

    let offsets: [(CGFloat, CGFloat)] = [
        (-60, -50), (-40, -30), (-20, -60), (0, -40),
        (20, -50), (40, -30), (60, -60), (-50, 20),
        (-30, 40), (10, 30), (30, 50), (50, 20)
    ]

    var body: some View {
        ZStack {
            ForEach(0..<offsets.count, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .offset(x: offsets[i].0, y: offsets[i].1)
                    .scaleEffect(animate ? 1.0 : 0.0)
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(
                        .easeOut(duration: 0.8).delay(Double(i) * 0.05),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    StarBurstView(color: .yellow)
        .frame(width: 300, height: 300)
        .background(.black)
}

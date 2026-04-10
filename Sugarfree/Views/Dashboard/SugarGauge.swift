import SwiftUI

struct SugarGauge: View {
    let consumed: Double
    let limit: Double

    private var fraction: Double {
        guard limit > 0 else { return 0 }
        return min(consumed / limit, 1.5)
    }

    private var displayFraction: Double {
        min(fraction, 1.0)
    }

    private var isOver: Bool { consumed > limit }

    private var ringColor: Color {
        if consumed == 0 { return .green }
        if fraction < 0.5 { return .green }
        if fraction < 0.8 { return .yellow }
        if fraction <= 1.0 { return .orange }
        return .red
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 16)

                Circle()
                    .trim(from: 0, to: displayFraction)
                    .stroke(
                        ringColor.gradient,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.6), value: displayFraction)

                VStack(spacing: 2) {
                    Text("\(consumed, specifier: "%.0f")g")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(isOver ? .red : .primary)
                        .contentTransition(.numericText())

                    Text(String(format: String(localized: "of %.0fg"), limit))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 180, height: 180)

            if isOver {
                let over = consumed - limit
                Text(String(format: String(localized: "%.0fg over limit"), over))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
            } else {
                let remaining = limit - consumed
                Text(String(format: String(localized: "%.0fg remaining"), remaining))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        SugarGauge(consumed: 12, limit: 25)
        SugarGauge(consumed: 30, limit: 25)
    }
}

import SwiftUI

struct StreakBadge: View {
    let days: Int
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(days > 0 ? Color.orange.opacity(0.15) : Color.secondary.opacity(0.08))
                    .frame(width: 56, height: 56)

                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(days > 0 ? .orange : .secondary.opacity(0.4))
            }

            Text("\(days)")
                .font(.title3.bold().monospacedDigit())

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

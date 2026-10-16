import SwiftUI

/// History — what Voltex installed, deleted and sideloaded. Keeps the newest 20.
struct HistoryView: View {
    @ObservedObject private var store = HistoryStore.shared

    var body: some View {
        ZStack {
            BlobBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header

                    if store.events.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 10) {
                            ForEach(store.events) { event in
                                eventRow(event)
                            }
                        }
                        .padding(.horizontal, 20)

                        Text("Only the newest 20 are kept — older ones fall off the bottom.")
                            .font(.footnote)
                            .foregroundStyle(VoltexTheme.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)

                        Button {
                            store.clear()
                            ToastCenter.shared.show("History cleared")
                        } label: {
                            Text("Clear history")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 11)
                                .background(Capsule().stroke(Color.red.opacity(0.6), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 130)
                }
                .padding(.top, 24)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40))
                .foregroundStyle(VoltexTheme.brandGradient)

            Text("History")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(VoltexTheme.brandGradient)

            Text("Last \(store.events.count) of 20 events")
                .font(.subheadline)
                .foregroundStyle(VoltexTheme.secondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(VoltexTheme.orange.opacity(0.8))
            Text("Nothing yet")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Installs, deletions and side-loads will show up here.")
                .font(.footnote)
                .foregroundStyle(VoltexTheme.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .fill(VoltexTheme.card)
        )
        .padding(.horizontal, 20)
    }

    private func eventRow(_ event: HistoryEvent) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName(for: event.text))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(VoltexTheme.orange)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )

            Text(event.text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)

            Text(Self.formatter.string(from: event.date))
                .font(.system(size: 11))
                .foregroundStyle(VoltexTheme.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(VoltexTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(VoltexTheme.hairline, lineWidth: 1)
        )
    }

    private func iconName(for text: String) -> String {
        let lower = text.lowercased()
        if lower.hasPrefix("uninstalled") || lower.hasPrefix("deleted") { return "trash.fill" }
        if lower.hasPrefix("sideloaded") { return "shippingbox.fill" }
        if lower.hasPrefix("installed") { return "arrow.down.circle.fill" }
        return "clock.fill"
    }

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
}

#Preview {
    HistoryView().preferredColorScheme(.dark)
}

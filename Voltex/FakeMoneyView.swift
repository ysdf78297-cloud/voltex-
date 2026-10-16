import SwiftUI
import UIKit

/// "Fake money test" — pick an item and a price, flip notifications on, and
/// it pretends orders are coming in (and spams real notifications about them).
/// None of the money is real; it's just for fun.
struct FakeMoneyView: View {
    @AppStorage("fmItem")    private var itemName  = "Steak"
    @AppStorage("fmPrice")   private var priceText = "24.99"
    @AppStorage("fmEnabled") private var enabled   = false
    @AppStorage("fmTotal")   private var total     = 0.0
    @AppStorage("fmSales")   private var sales     = 0
    @AppStorage("fmLog")     private var logRaw    = ""

    @State private var flash = false

    private let ticker = Timer.publish(every: 7, on: .main, in: .common).autoconnect()

    private var price: Double { Double(priceText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var entries: [String] { logRaw.split(separator: "\n").map(String.init) }

    var body: some View {
        ZStack {
            BlobBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                    balance
                    settingsCard
                    actions
                    logCard

                    Text("Every number here is fake. Nothing is charged, sent or stored anywhere.")
                        .font(.footnote)
                        .foregroundStyle(VoltexTheme.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 140)
                }
                .padding(.top, 24)
            }
        }
        .onReceive(ticker) { _ in
            guard enabled else { return }
            if Double.random(in: 0...1) < 0.6 { makeSale() }
        }
        .onChange(of: enabled) { newValue in
            if newValue {
                Notifier.requestPermission()
                ToastCenter.shared.show("Orders are rolling in")
            } else {
                ToastCenter.shared.show("Notifications off")
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "cart.fill")
                .font(.system(size: 40))
                .foregroundStyle(VoltexTheme.brandGradient)

            Text("Fake money test")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(VoltexTheme.brandGradient)

            Text("Looks real. Isn't.")
                .font(.footnote)
                .foregroundStyle(VoltexTheme.secondary)
        }
    }

    private var balance: some View {
        VStack(spacing: 6) {
            Text("Saved")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .kerning(2)
                .foregroundStyle(VoltexTheme.secondary)

            Text("$\(String(format: "%.2f", total))")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(flash ? VoltexTheme.orange : .white)
                .contentTransition(.numericText())

            Text("\(sales) order\(sales == 1 ? "" : "s")")
                .font(.system(size: 13))
                .foregroundStyle(VoltexTheme.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .background(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .fill(VoltexTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .stroke(flash ? VoltexTheme.orange.opacity(0.6) : VoltexTheme.hairline, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            field("Item name", text: $itemName, keyboard: .default)
            divider
            field("Price", text: $priceText, keyboard: .decimalPad)
            divider

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notifications")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                    Text("Spam a notification on every order")
                        .font(.footnote)
                        .foregroundStyle(VoltexTheme.secondary)
                }
                Spacer()
                Toggle("", isOn: $enabled)
                    .labelsHidden()
                    .tint(VoltexTheme.orange)
            }
            .padding(.vertical, 14)
        }
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .fill(VoltexTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .stroke(VoltexTheme.hairline, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                makeSale()
            } label: {
                Text("Make a sale now")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(VoltexTheme.brandGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button {
                total = 0
                sales = 0
                logRaw = ""
                ToastCenter.shared.show("Money reset")
            } label: {
                Text("Reset")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(Capsule().stroke(VoltexTheme.hairline, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    private var logCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RECENT ORDERS")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .kerning(1.4)
                .foregroundStyle(VoltexTheme.orange)

            if entries.isEmpty {
                Text("No orders yet.")
                    .font(.footnote)
                    .foregroundStyle(VoltexTheme.secondary)
                    .padding(.vertical, 12)
            } else {
                ForEach(entries.prefix(12), id: \.self) { entry in
                    Text(entry)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .fill(VoltexTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: VoltexTheme.corner, style: .continuous)
                .stroke(VoltexTheme.hairline, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var divider: some View {
        Rectangle().fill(VoltexTheme.hairline).frame(height: 1)
    }

    private func field(_ title: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            Spacer(minLength: 16)
            TextField("", text: text)
                .keyboardType(keyboard)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(VoltexTheme.orange)
                .frame(maxWidth: 180)
        }
        .padding(.vertical, 14)
    }

    private func makeSale() {
        let amount = price
        total += amount
        sales += 1

        let stamp = Self.formatter.string(from: Date())
        let line = "\(stamp) · \(itemName.isEmpty ? "Item" : itemName) · $\(String(format: "%.2f", amount))"
        var lines = entries
        lines.insert(line, at: 0)
        logRaw = lines.prefix(30).joined(separator: "\n")

        withAnimation(.easeInOut(duration: 0.25)) { flash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeInOut(duration: 0.35)) { flash = false }
        }

        Notifier.send(title: "New order",
                      body: "Someone bought \(itemName.isEmpty ? "an item" : itemName) for $\(String(format: "%.2f", amount))")
    }

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()
}

#Preview {
    FakeMoneyView().preferredColorScheme(.dark)
}

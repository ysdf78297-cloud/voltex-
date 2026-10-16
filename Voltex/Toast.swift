import SwiftUI

/// Android-style toast messages, shown as a dark pill sliding up from the bottom.
final class ToastCenter: ObservableObject {
    static let shared = ToastCenter()

    @Published private(set) var message: String?
    private var dismissWork: DispatchWorkItem?

    func show(_ text: String) {
        dismissWork?.cancel()
        withAnimation(.easeOut(duration: 0.2)) { message = text }

        let work = DispatchWorkItem { [weak self] in
            withAnimation(.easeIn(duration: 0.25)) { self?.message = nil }
        }
        dismissWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2, execute: work)
    }
}

/// Drop this anywhere to have toasts appear on that screen.
struct AndroidToastHost: View {
    @ObservedObject private var center = ToastCenter.shared

    var body: some View {
        VStack {
            Spacer()
            if let message = center.message {
                Text(message)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(white: 0.94))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(white: 0.16).opacity(0.97))
                            .shadow(color: .black.opacity(0.45), radius: 12, y: 4)
                    )
                    .padding(.horizontal, 28)
                    .padding(.bottom, 132)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

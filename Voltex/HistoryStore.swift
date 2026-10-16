import Foundation

struct HistoryEvent: Identifiable, Codable {
    let id: UUID
    let text: String
    let date: Date
}

/// Keeps the last 20 things Voltex did. Anything older falls off the bottom.
final class HistoryStore: ObservableObject {
    static let shared = HistoryStore()

    @Published private(set) var events: [HistoryEvent] = []

    private let key = "voltexHistory"
    private let limit = 20

    private init() { load() }

    func add(_ text: String) {
        var list = events
        list.insert(HistoryEvent(id: UUID(), text: text, date: Date()), at: 0)
        if list.count > limit {
            list = Array(list.prefix(limit))
        }
        events = list
        save()
    }

    func clear() {
        events = []
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([HistoryEvent].self, from: data) else { return }
        events = Array(list.prefix(limit))
    }

    private func save() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

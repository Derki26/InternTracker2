import Foundation
import SwiftUI
import Combine

@MainActor
final class HoursClockStore: ObservableObject {

    @Published var entries: [TimeEntry] = [] {
        didSet { save() }
    }

    private let key = "hours_clock_entries_v3"

    init() { load() }

    func activeEntryIndex(for username: String) -> Int? {
        entries.firstIndex { $0.clockOut == nil && $0.username == username }
    }

    func isClockedIn(username: String) -> Bool {
        activeEntryIndex(for: username) != nil
    }

    func clockIn(company: String, username: String) {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !u.isEmpty else { return }
        guard !isClockedIn(username: u) else { return }

        entries.insert(
            TimeEntry(username: u, company: company, clockIn: Date()),
            at: 0
        )
    }

    func clockOut(username: String) {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let idx = activeEntryIndex(for: u) else { return }
        entries[idx].clockOut = Date()
    }

    // ✅ Missing
    func addMissingClockIn(company: String, username: String, clockIn: Date, clockOut: Date) {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !u.isEmpty else { return }
        guard clockOut >= clockIn else { return }

        entries.insert(
            TimeEntry(username: u, company: company, clockIn: clockIn, clockOut: clockOut),
            at: 0
        )
    }

    func fixMissingClockOut(username: String, clockOut: Date = Date()) {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let idx = activeEntryIndex(for: u) else { return }
        entries[idx].clockOut = clockOut
    }

    func totalSecondsToday(username: String) -> TimeInterval {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: Date())

        return entries
            .filter { $0.username == username }
            .filter { $0.clockIn >= startOfDay || ($0.clockOut ?? Date()) >= startOfDay }
            .reduce(0) { $0 + durationWithinDay($1, startOfDay: startOfDay) }
    }

    private func durationWithinDay(_ entry: TimeEntry, startOfDay: Date) -> TimeInterval {
        let end = entry.clockOut ?? Date()
        let start = max(entry.clockIn, startOfDay)
        return max(0, end.timeIntervalSince(start))
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("save error:", error)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            entries = try JSONDecoder().decode([TimeEntry].self, from: data)
        } catch {
            print("load error:", error)
            entries = []
        }
    }
}


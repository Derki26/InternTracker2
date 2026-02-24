import Foundation
 import Combine

final class ToDoStore: ObservableObject {
    @Published var items: [ToDoItem] = []
    @Published var weeks: [ToDoWeek] = []

    // Groups by month → weeks → items
    var grouped: [(month: MonthKey, weeks: [(week: ToDoWeek, items: [ToDoItem])])] {
        let cal = Calendar.current

        let weeksByMonth = Dictionary(grouping: weeks) { wk in
            let year = cal.component(.year, from: wk.createdAt)
            let month = cal.component(.month, from: wk.createdAt)
            return MonthKey(year: year, month: month)
        }

        return weeksByMonth.keys.sorted().map { monthKey in
            let monthWeeks = (weeksByMonth[monthKey] ?? []).sorted()

            let wkTuples: [(ToDoWeek, [ToDoItem])] = monthWeeks.map { wk in
                let wkItems = items
                    .filter { $0.weekId == wk.id }
                    .sorted { $0.createdAt < $1.createdAt }
                return (wk, wkItems)
            }

            return (month: monthKey, weeks: wkTuples.map { (week: $0.0, items: $0.1) })
        }
    }

    func monthTitle(_ key: MonthKey) -> String {
        let comps = DateComponents(calendar: .current, year: key.year, month: key.month)
        let date = comps.date ?? Date()

        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date).capitalized
    }

    func toggleDone(_ id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isDone.toggle()
    }

    func addWeek(number: Int, title: String, createdAt: Date = Date()) {
        weeks.append(ToDoWeek(number: number, title: title, createdAt: createdAt))
    }

    func addItem(title: String, to weekId: UUID) {
        items.append(ToDoItem(title: title, weekId: weekId))
    }

    struct MonthKey: Hashable, Comparable {
        let year: Int
        let month: Int

        static func < (lhs: MonthKey, rhs: MonthKey) -> Bool {
            if lhs.year != rhs.year { return lhs.year < rhs.year }
            return lhs.month < rhs.month
        }
    }

    func seedIfNeeded() {
        guard weeks.isEmpty, items.isEmpty else { return }

        let w1 = ToDoWeek(number: 1, title: "Onboarding")
        let w2 = ToDoWeek(number: 2, title: "Training")
        weeks = [w1, w2]

        items = [
            ToDoItem(title: "Set up laptop and accounts", weekId: w1.id),
            ToDoItem(title: "Get access to Jamf / SharePoint", weekId: w1.id),
            ToDoItem(title: "Review Internship Tracker requirements", weekId: w2.id),
            ToDoItem(title: "Complete first supervisor-assigned task", weekId: w2.id)
        ]
    }
}


import Foundation

struct TimeEntry: Identifiable, Codable {
    let id: UUID
    var username: String
    var company: String
    var clockIn: Date
    var clockOut: Date?

    init(
        id: UUID = UUID(),
        username: String,
        company: String,
        clockIn: Date,
        clockOut: Date? = nil
    ) {
        self.id = id
        self.username = username
        self.company = company
        self.clockIn = clockIn
        self.clockOut = clockOut
    }

    var durationSeconds: TimeInterval {
        let end = clockOut ?? Date()
        return max(0, end.timeIntervalSince(clockIn))
    }
}


import Foundation

enum ProjectStatus: String, CaseIterable, Identifiable, Codable {
    case inProgress = "In Progress"
    case production = "Production"

    var id: String { rawValue }
}

struct DailyActivity: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var hours: Double
    var note: String
}

struct InternProject: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var status: ProjectStatus
    var link: String?          // URL as text
    var startDate: Date
    var endDate: Date
    var activities: [DailyActivity]
}

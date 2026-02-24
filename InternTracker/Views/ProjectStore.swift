import SwiftUI
import Foundation
 import Combine

@MainActor
final class ProjectStore: ObservableObject {

    @Published var projects: [InternProject] = []

    func upsert(_ project: InternProject) {
        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            projects[idx] = project
        } else {
            projects.append(project)
        }
    }

    func delete(_ project: InternProject) {
        projects.removeAll { $0.id == project.id }
    }

    // MARK: - Activities (Project Log)

    func activities(for projectId: UUID) -> [DailyActivity] {
        projects.first(where: { $0.id == projectId })?.activities ?? []
    }

    func totalHours(for projectId: UUID) -> Double {
        activities(for: projectId).reduce(0) { $0 + $1.hours }
    }

    func addActivity(_ activity: DailyActivity, to projectId: UUID) {
        guard let idx = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[idx].activities.insert(activity, at: 0) // newest first
    }

    func updateActivity(_ activity: DailyActivity, in projectId: UUID) {
        guard let pIdx = projects.firstIndex(where: { $0.id == projectId }) else { return }
        guard let aIdx = projects[pIdx].activities.firstIndex(where: { $0.id == activity.id }) else { return }
        projects[pIdx].activities[aIdx] = activity
    }

    func deleteActivity(id: UUID, from projectId: UUID) {
        guard let pIdx = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[pIdx].activities.removeAll { $0.id == id }
    }
}

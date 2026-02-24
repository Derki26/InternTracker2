import SwiftUI

struct ReportsView: View {

    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var data: LocalDataStore
    @EnvironmentObject var projectStore: ProjectStore

    var body: some View {
        Group {
            if sessionStore.session?.role == .admin {
                adminReports
            } else {
                internWeeklyReport
            }
        }
        .navigationTitle(sessionStore.session?.role == .admin ? "Reports" : "Weekly Activity Report")
    }

    // MARK: - INTERN (ONLY)

    private var internWeeklyReport: some View {
        VStack(spacing: 14) {

            Text("Select a project to print your logged activities.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            if projectStore.projects.isEmpty {
                // Empty state (iOS 17+ uses ContentUnavailableView, iOS 16 fallback)
                if #available(iOS 17.0, *) {
                    ContentUnavailableView(
                        "No Projects",
                        systemImage: "folder",
                        description: Text("Create a project to start logging activities.")
                    )
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "folder")
                            .font(.system(size: 36))
                            .foregroundStyle(.secondary)

                        Text("No Projects")
                            .font(.headline)

                        Text("Create a project to start logging activities.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 22)
                    }
                    .padding(.vertical, 24)
                }

                Spacer()

            } else {
                // Content when there ARE projects
                List {
                    Section("What you can do") {
                        Label("Filter activities by date range (From / To)", systemImage: "calendar")
                        Label("Print selected range or print all logs", systemImage: "printer")
                    }

                    Section("Projects") {
                        ForEach(projectStore.projects) { p in
                            Text(p.name)
                        }
                    }
                }
            }
        }
    }

    private var currentInternName: String {
        if let s = sessionStore.session,
           let intern = data.interns.first(where: { $0.id == s.internId }) {
            return intern.fullName
        }
        return sessionStore.session?.username ?? "Intern"
    }

    // MARK: - ADMIN (placeholder)

    private var adminReports: some View {
        List {
            Text("Admin reports coming soon…")
                .foregroundStyle(.secondary)
        }
    }
}


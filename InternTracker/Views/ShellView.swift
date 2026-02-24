import SwiftUI

struct ShellView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var data: LocalDataStore

    var body: some View {
        let isAdmin = sessionStore.session?.role == .admin
        let isAdminMode = isAdmin && sessionStore.mode == .admin

        NavigationStack {
            List {
                Section {
                    HStack {
                        Text(isAdminMode ? "ADMIN MODE" : "STUDENT MODE")
                            .font(.caption).bold()
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(.thinMaterial)
                            .clipShape(Capsule())

                        Spacer()

                        if isAdmin {
                            Button(isAdminMode ? "Student View" : "Admin View") {
                                sessionStore.toggleMode()
                            }
                        }

                        Button("Log out") { sessionStore.logout() }
                            .foregroundStyle(.red)
                    }
                }

                if isAdminMode {
                    Section("Admin") {
                        NavigationLink("Interns Directory") { InternsDirectoryView() }
                        NavigationLink("Reports (placeholder)") { Text("Reports") }
                    }

                    Section("Viewing As") {
                        Text(viewingAsName())
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section("Student") {
                        Text("My Profile (placeholder)")
                        Text("My Projects (placeholder)")
                        Text("My Logs (placeholder)")
                    }
                }
            }
            .navigationTitle("InternTracker")
        }
    }

    private func viewingAsName() -> String {
        guard let id = sessionStore.activeInternId,
              let intern = data.interns.first(where: { $0.id == id }) else {
            return "None selected"
        }
        return "\(intern.fullName) (@\(intern.username))"
    }
}


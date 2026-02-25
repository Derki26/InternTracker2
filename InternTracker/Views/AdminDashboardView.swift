import SwiftUI


struct AdminDashboardView: View {
    @EnvironmentObject var sessionStore: SessionStore

    var body: some View {
        List {
            Section("Admin") {
                NavigationLink("Intern Directory") {
                    InternsDirectoryView()
                }

                NavigationLink("Approve Logs") {
                    ApprovalsView()   // ahora sí existe (abajo)
                }

                NavigationLink("Reports") {
                    ReportsView()     // ahora sí existe (abajo)
                }
            }

            Section("Viewing As") {
                Text(sessionStore.activeInternId?.uuidString ?? "None selected")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Admin")
    }
}



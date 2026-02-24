import SwiftUI
import Combine


struct InternsDirectoryView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var data: LocalDataStore

    @State private var q = ""

    private var filtered: [ITIntern] {
        let t = q.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if t.isEmpty { return data.interns }
        return data.interns.filter {
            $0.fullName.lowercased().contains(t) ||
            $0.username.lowercased().contains(t)
        }
    }

    var body: some View {
        List {
            Section {
                TextField("Search interns", text: $q)
            }

            Section("Interns") {
                ForEach(filtered) { intern in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(intern.fullName)
                                .font(.headline)
                            Text("@\(intern.username)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if sessionStore.activeInternId == intern.id {
                            Text("Viewing")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Button("View") {
                                sessionStore.setActiveIntern(intern.id)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }

            Section {
                Button("Clear selection") {
                    sessionStore.setActiveIntern(nil)
                }
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Interns")
    }
}

#Preview {
    NavigationStack {
        InternsDirectoryView()
            .environmentObject(SessionStore())
            .environmentObject(LocalDataStore())
    }
}

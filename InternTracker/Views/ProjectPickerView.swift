import SwiftUI

struct ProjectPickerView: View {
    let projects: [InternProject]
    @ObservedObject var store: ProjectStore
    let internName: String

    var body: some View {
        List(projects) { p in
            NavigationLink {
                ProjectLogView(
                    projectId: p.id,
                    projectName: p.name,
                    plannedHours: hoursPlanned(for: p),
                    internName: internName,
                    store: store
                )
            } label: {
                VStack(alignment: .leading) {
                    Text(p.name).font(.headline)
                    Text(p.status.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Select Project")
    }

    // 👉 Si no tienes plannedHours en el modelo, lo calculas aquí o lo pasas fijo
    private func hoursPlanned(for p: InternProject) -> Double {
        // puedes hacer: p.activities.reduce(0) { $0 + $1.hours }
        return 40
    }
}


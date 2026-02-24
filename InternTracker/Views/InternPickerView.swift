import SwiftUI

struct InternPickerView: View {
    let interns: [Intern]
    let onSelect: (Intern) -> Void

    var body: some View {
        List(interns) { intern in
            Button {
                onSelect(intern)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(intern.fullName).font(.headline)
                    Text(intern.email).font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
    }
}


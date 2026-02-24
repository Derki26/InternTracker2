import SwiftUI

struct ManageInternView: View {
    @EnvironmentObject var store: InternStore

    @State private var showCreate = false
    @State private var showPicker = false
    @State private var internToEdit: Intern?

    var body: some View {
        List {
            Section("Intern") {

                Button {
                    showCreate = true
                } label: {
                    Label("Create Intern", systemImage: "plus.circle.fill")
                }

                Button {
                    showPicker = true
                } label: {
                    Label("Edit Intern", systemImage: "pencil.circle.fill")
                }
                .disabled(store.interns.isEmpty)
            }

            if store.interns.isEmpty {
                Text("No interns yet. Create one first.")
                    .foregroundStyle(.secondary)
            } else {
                Section("Current interns") {
                    ForEach(store.interns) { i in
                        Text(i.fullName)
                    }
                }
            }
        }
        .navigationTitle("Intern")
        .sheet(isPresented: $showCreate) {
            NavigationStack {
                InternFormView(mode: .add) { intern in
                    store.upsert(intern)   // ✅ aquí se guarda para que luego exista en Edit
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            NavigationStack {
                InternPickerView(interns: store.interns) { selected in
                    internToEdit = selected
                    showPicker = false
                }
                .navigationTitle("Select Intern")
            }
        }
        .sheet(item: $internToEdit) { selected in
            NavigationStack {
                InternFormView(mode: .edit(existing: selected)) { updated in
                    store.upsert(updated)
                }
            }
        }
    }
}


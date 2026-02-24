import SwiftUI

struct ManageProjectView: View {

    @EnvironmentObject var store: ProjectStore

    @State private var showCreate = false
    @State private var showPicker = false
    @State private var projectToEdit: InternProject?

    // Ajusta el nombre como tú quieras (o pásalo desde Profile si lo tienes)
    private let internName = "Intern"

    var body: some View {
        List {

            Section("Project") {

                Button {
                    showCreate = true
                } label: {
                    Label("Create Project", systemImage: "plus.circle.fill")
                }

                // ✅ Abre el picker que ahora navega al ProjectLogView
                Button {
                    showPicker = true
                } label: {
                    Label("View Project Log", systemImage: "list.bullet.rectangle")
                }
                .disabled(store.projects.isEmpty)

                // ✅ Mantén "Edit Project" para abrir el form (sin usar picker)
                Button {
                    // Si quieres elegir cuál editar, abajo te dejo la opción.
                    // Por ahora: edita el último o el primero.
                    projectToEdit = store.projects.first
                } label: {
                    Label("Edit Project (Form)", systemImage: "pencil.circle.fill")
                }
                .disabled(store.projects.isEmpty)
            }

            if store.projects.isEmpty {
                Text("No projects yet. Create one first.")
                    .foregroundStyle(.secondary)
            } else {
                Section("Current projects") {
                    ForEach(store.projects) { p in
                        HStack {
                            Text(p.name).font(.headline)
                            Spacer()

                            // ✅ Botón rápido para editar ESTE proyecto en el form
                            Button {
                                projectToEdit = p
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle("Project")

        // CREATE
        .sheet(isPresented: $showCreate) {
            NavigationStack {
                ProjectFormView(mode: .add) { project in
                    store.upsert(project)
                }
            }
        }

        // ✅ PICKER (ahora sin closure)
        .sheet(isPresented: $showPicker) {
            NavigationStack {
                ProjectPickerView(
                    projects: store.projects,
                    store: store,
                    internName: internName
                )
                .navigationTitle("Select Project")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Close") { showPicker = false }
                    }
                }
            }
        }

        // EDIT FORM
        .sheet(item: $projectToEdit) { selected in
            NavigationStack {
                ProjectFormView(mode: .edit(existing: selected)) { updated in
                    store.upsert(updated)
                }
            }
        }
    }
}


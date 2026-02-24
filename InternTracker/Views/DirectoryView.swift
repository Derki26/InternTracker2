import SwiftUI

// MARK: - Models

struct Intern: Identifiable, Hashable {
    var id: UUID = UUID()

    var fullName: String
    var university: String
    var email: String
    var phone: String

    var mentor: String
    var mentorEmail: String

    var startDate: Date
    var endDate: Date

    var linkedin: String
    var notes: String
    var weeks: Int?
    var totalHours: Double?
    var photoUrl: String?
}

struct Project: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var department: String
    var status: String
}

// MARK: - DirectoryView

struct DirectoryView: View {

    private let royalBlue = Color(red: 0/255, green: 63/255, blue: 135/255)

    enum Tab: String, CaseIterable {
        case interns = "Interns"
        case projects = "Projects"
    }

    @State private var selectedTab: Tab = .interns
    @State private var searchText = ""
    
    @State private var showEditIntern = false
    @State private var selectedIntern: Intern?


    @State private var showAddIntern = false

    @State private var interns: [Intern] = []
    @State private var projects: [Project] = [
        .init(name: "Intern Tracker", department: "Padron Campus", status: "Active")
    ]

    var body: some View {
        VStack(spacing: 12) {

            Picker("Directory", selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .tint(royalBlue)

            Group {
                switch selectedTab {
                case .interns:
                    internsList
                case .projects:
                    projectsList
                }
            }
        }
        .background(Color.white.ignoresSafeArea()) // ✅ background blanco
        .navigationTitle("Directory")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: selectedTab == .interns ? "Search interns…" : "Search projects…")
        .tint(royalBlue)                 // ✅ flechas/chevrons/segmented/search
        .foregroundColor(royalBlue)      // ✅ texto general azul
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if selectedTab == .interns {
                    Button {
                        showAddIntern = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(royalBlue)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddIntern) {
            AddInternView { newIntern in
                interns.insert(newIntern, at: 0)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEditIntern) {
            if let intern = selectedIntern {
                InternFormView(mode: .edit(existing: intern)) { updated in
                    if let idx = interns.firstIndex(where: { $0.id == updated.id }) {
                        interns[idx] = updated
                    }
                }
            }
        }

    }

    // MARK: - Interns List

    private var internsList: some View {
        List {
            if filteredInterns.isEmpty {
                emptyInternsState
                    .listRowBackground(Color.white)
            } else {
                ForEach(filteredInterns) { intern in
                    Button {
                        selectedIntern = intern
                        showEditIntern = true
                    } label: {
                        InternRow(intern: intern, royalBlue: royalBlue)
                    }
                    .buttonStyle(.plain)

                    .listRowBackground(Color.white)
                }
            }
        }
        .scrollContentBackground(.hidden) // ✅ quita fondo gris del List
        .background(Color.white)
        .navigationDestination(for: Intern.self) { intern in
            InternDetailsView(intern: intern, royalBlue: royalBlue)
        }
    }

    private var emptyInternsState: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 44))
                .foregroundColor(royalBlue)

            Text("No interns yet")
                .font(.headline)
                .foregroundColor(royalBlue)

            Text("Tap + to add your first intern.")
                .font(.subheadline)
                .foregroundColor(royalBlue.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    private var filteredInterns: [Intern] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return interns }
        return interns.filter {
            $0.fullName.lowercased().contains(q) ||
            $0.email.lowercased().contains(q) ||
            $0.university.lowercased().contains(q) ||
            $0.mentor.lowercased().contains(q)
        }
    }

    // MARK: - Projects List

    private var projectsList: some View {
        List {
            ForEach(filteredProjects) { project in
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundColor(royalBlue)

                    Text("\(project.department) • \(project.status)")
                        .font(.subheadline)
                        .foregroundColor(royalBlue.opacity(0.75))
                }
                .listRowBackground(Color.white)
            }

            if filteredProjects.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "folder")
                        .font(.system(size: 44))
                        .foregroundColor(royalBlue)

                    Text("No projects found")
                        .font(.headline)
                        .foregroundColor(royalBlue)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .listRowBackground(Color.white)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.white)
    }

    private var filteredProjects: [Project] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return projects }
        return projects.filter {
            $0.name.lowercased().contains(q) ||
            $0.department.lowercased().contains(q) ||
            $0.status.lowercased().contains(q)
        }
    }
}

// MARK: - Rows

private struct InternRow: View {
    let intern: Intern
    let royalBlue: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(royalBlue.opacity(0.12))
                .frame(width: 42, height: 42)
                .overlay(
                    Text(initials)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(royalBlue)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(intern.fullName)
                    .font(.headline)
                    .foregroundColor(royalBlue)

                Text("\(intern.university) • Mentor: \(intern.mentor)")
                    .font(.subheadline)
                    .foregroundColor(royalBlue.opacity(0.75))
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var initials: String {
        let parts = intern.fullName.split(separator: " ")
        let f = parts.first?.first.map(String.init) ?? ""
        let l = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (f + l).uppercased()
    }
}

// MARK: - Details

private struct InternDetailsView: View {
    let intern: Intern
    let royalBlue: Color

    var body: some View {
        List {
            Section {
                row("Name", intern.fullName)
                row("University", intern.university)
                row("Email", intern.email)
                row("Phone", intern.phone)
                row("Mentor", intern.mentor)
                row("Mentor Email", intern.mentorEmail)
            } header: {
                Text("Intern Info").foregroundColor(royalBlue)
            }

            Section {
                row("Start", intern.startDate.formatted(date: .abbreviated, time: .omitted))
                row("End", intern.endDate.formatted(date: .abbreviated, time: .omitted))
            } header: {
                Text("Dates").foregroundColor(royalBlue)
            }

            Section {
                Text(intern.notes.isEmpty ? "—" : intern.notes)
                    .foregroundColor(royalBlue)
            } header: {
                Text("Notes / Skills").foregroundColor(royalBlue)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.white)
        .navigationTitle("Intern")
        .navigationBarTitleDisplayMode(.inline)
        .tint(royalBlue)
        .foregroundColor(royalBlue)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundColor(royalBlue)
            Spacer()
            Text(value).foregroundColor(royalBlue.opacity(0.75))
        }
    }
}

#Preview {
    NavigationStack {
        DirectoryView()
    }
}


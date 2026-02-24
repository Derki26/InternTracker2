import SwiftUI

struct ProjectFormView: View {

    enum Mode {
        case add
        case edit(existing: InternProject)

        var title: String {
            switch self {
            case .add: return "Create Project"
            case .edit: return "Edit Project"
            }
        }
    }

    let mode: Mode
    var onSave: (InternProject) -> Void

    @Environment(\.dismiss) private var dismiss
    private let royalBlue = Color(red: 0/255, green: 63/255, blue: 135/255)

    // Project fields
    @State private var id: UUID = UUID()
    @State private var name: String = ""
    @State private var status: ProjectStatus = .inProgress
    @State private var link: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()

    // Activities
    @State private var activities: [DailyActivity] = []

    // Add activity UI
    @State private var showAddActivity = false
    @State private var newActivityDate = Date()
    @State private var newActivityHoursText = ""
    @State private var newActivityNote = ""

    private var canSave: Bool {
        let nameOK = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let datesOK = endDate >= startDate
        return nameOK && datesOK
    }

    var body: some View {
        Form {
            Section("Project") {
                TextField("Project Name", text: $name)

                Picker("Status", selection: $status) {
                    ForEach(ProjectStatus.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .tint(royalBlue)

                TextField("Project Link (optional)", text: $link)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                if let url = URL(string: normalizedURLString(link)),
                   !link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Link("Open Link", destination: url)
                        .foregroundColor(royalBlue)
                }
            }

            Section("Dates") {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)

                if endDate < startDate {
                    Text("End date must be on/after Start date")
                        .foregroundStyle(.red)
                }
            }

            Section {
                HStack {
                    Text("Daily Activities")
                        .font(.headline)
                        .foregroundColor(royalBlue)
                    Spacer()
                    Button {
                        showAddActivity = true
                        newActivityDate = Date()
                        newActivityHoursText = ""
                        newActivityNote = ""
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .foregroundColor(royalBlue)
                }
            }

            if activities.isEmpty {
                Text("No activities yet.")
                    .foregroundStyle(.secondary)
            } else {
                Section {
                    ForEach(activities) { a in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(a.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "%.2f h", a.hours))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Text(a.note)
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteActivities)
                } footer: {
                    Text("Swipe left to delete an activity.")
                }

                Section("Totals") {
                    HStack {
                        Text("Total Hours")
                        Spacer()
                        Text(String(format: "%.2f", totalHours))
                            .foregroundColor(royalBlue)
                    }
                }
            }
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .tint(royalBlue)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundColor(royalBlue)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { save() }
                    .foregroundColor(royalBlue)
                    .disabled(!canSave)
            }
        }
        .onAppear { loadIfEditing() }
        .sheet(isPresented: $showAddActivity) { addActivitySheet }
    }

    private var totalHours: Double {
        activities.reduce(0) { $0 + $1.hours }
    }

    private func loadIfEditing() {
        if case .edit(let existing) = mode {
            id = existing.id
            name = existing.name
            status = existing.status
            link = existing.link ?? ""
            startDate = existing.startDate
            endDate = existing.endDate
            activities = existing.activities
        }
    }

    private func save() {
        let project = InternProject(
            id: id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            status: status,
            link: link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : normalizedURLString(link),
            startDate: startDate,
            endDate: endDate,
            activities: activities.sorted(by: { $0.date < $1.date })
        )
        onSave(project)
        dismiss()
    }

    private func deleteActivities(at offsets: IndexSet) {
        activities.remove(atOffsets: offsets)
    }

    private func normalizedURLString(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return "" }
        if t.lowercased().hasPrefix("http://") || t.lowercased().hasPrefix("https://") {
            return t
        }
        return "https://\(t)"
    }

    private var addActivitySheet: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $newActivityDate, displayedComponents: .date)

                TextField("Hours", text: $newActivityHoursText)
                    .keyboardType(.decimalPad)

                TextEditor(text: $newActivityNote)
                    .frame(minHeight: 120)
            }
            .navigationTitle("Add Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { showAddActivity = false }
                        .foregroundColor(royalBlue)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") { addActivity() }
                        .foregroundColor(royalBlue)
                        .disabled(!canAddActivity)
                }
            }
        }
    }

    private var canAddActivity: Bool {
        let h = Double(newActivityHoursText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? -1
        let noteOK = !newActivityNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return h > 0 && noteOK
    }

    private func addActivity() {
        let h = Double(newActivityHoursText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let activity = DailyActivity(date: newActivityDate, hours: h, note: newActivityNote.trimmingCharacters(in: .whitespacesAndNewlines))
        activities.append(activity)
        showAddActivity = false
    }
}


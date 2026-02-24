import SwiftUI

struct ProjectLogView: View {
    let projectId: UUID
    let projectName: String
    let plannedHours: Double
    let internName: String

    @ObservedObject var store: ProjectStore

    // Print range (filtro)
    @State private var fromDate = Date()
    @State private var toDate = Date()
    @State private var useRange = false

    // Pagination
    private let pageSize = 10
    @State private var page = 1

    // Editing
    @State private var editingId: UUID? = nil
    @State private var draftDate = Date()
    @State private var draftHours = ""
    @State private var draftNote = ""
    @State private var errors: [String: String] = [:]

    // Alerts
    @State private var alertMsg: String? = nil

    private var activities: [DailyActivity] {
        store.activities(for: projectId)
    }

    private var totalRecords: Int { activities.count }
    private var totalHours: Double { store.totalHours(for: projectId) }

    private var totalPages: Int {
        max(1, Int(ceil(Double(totalRecords) / Double(pageSize))))
    }

    private var paged: [DailyActivity] {
        let start = (page - 1) * pageSize
        guard start < activities.count else { return [] }
        let end = min(start + pageSize, activities.count)
        return Array(activities[start..<end])
    }

    private var showingFrom: Int { totalRecords == 0 ? 0 : (page - 1) * pageSize + 1 }
    private var showingTo: Int { min(page * pageSize, totalRecords) }

    var body: some View {
        VStack(spacing: 12) {
            header

            if activities.isEmpty {
                Text("No entries yet for this project.")
                    .foregroundStyle(.secondary)
            } else {
                pagination
                table
            }

            if editingId != nil { editCard }
        }
        .padding()
        .navigationTitle("Project Log")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") { addEntryAndEdit() }
            }
        }
        .onChange(of: activities.count) { _ in
            page = min(max(1, page), totalPages)
        }
        .alert("Notice", isPresented: Binding(
            get: { alertMsg != nil },
            set: { if !$0 { alertMsg = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMsg ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Project Log — Records: \(totalRecords) — Logged: \(totalHours, specifier: "%.2f") / Planned: \(plannedHours, specifier: "%.2f")")
                .font(.headline)

            HStack(spacing: 8) {
                Pill(text: internName.isEmpty ? "Intern" : internName)
                Pill(text: "Records: \(totalRecords)")
                Spacer()
            }

            HStack(spacing: 12) {
                Toggle("Range", isOn: $useRange)
                    .toggleStyle(.switch)

                DatePicker("From", selection: $fromDate, displayedComponents: .date)
                    .labelsHidden()
                    .disabled(!useRange)

                DatePicker("To", selection: $toDate, displayedComponents: .date)
                    .labelsHidden()
                    .disabled(!useRange)

                Button("Print logs") { printLogs(range: true) }
                    .buttonStyle(.borderedProminent)

                Button("Print all") { printLogs(range: false) }
                    .buttonStyle(.bordered)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var pagination: some View {
        HStack {
            Text("Showing \(showingFrom)–\(showingTo) of \(totalRecords)")
                .foregroundStyle(.secondary)
            Spacer()

            Button("Prev") { page = max(1, page - 1) }
                .disabled(page <= 1)

            Text("Page \(page) / \(totalPages)")

            Button("Next") { page = min(totalPages, page + 1) }
                .disabled(page >= totalPages)
        }
        .padding(.horizontal, 6)
    }

    private var table: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Date").bold().frame(width: 90, alignment: .leading)
                Text("Hours").bold().frame(width: 60, alignment: .leading)
                Text("Note").bold()
                Spacer()
                Text("Actions").bold().frame(width: 160, alignment: .leading)
            }
            .font(.caption)
            .padding(10)
            .background(Color(.systemGray6))

            ForEach(paged) { a in
                HStack(alignment: .top, spacing: 10) {
                    Text(a.date.ymdString).frame(width: 90, alignment: .leading)
                    Text(String(format: "%.2f", a.hours)).frame(width: 60, alignment: .leading)

                    Text(a.note.isEmpty ? "—" : a.note)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        Button("Edit") { startEdit(a) }
                            .buttonStyle(.bordered)

                        Button("Delete", role: .destructive) {
                            store.deleteActivity(id: a.id, from: projectId)
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(width: 160, alignment: .leading)
                }
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)

                Divider()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 1))
    }

    private var editCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Edit entry — \(projectName) (\(draftDate.ymdString))")
                    .font(.headline)
                Spacer()
                Button("Save") { saveEdit() }
                    .buttonStyle(.borderedProminent)
                Button("Cancel") { cancelEdit() }
                    .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Date").font(.caption).bold()
                    DatePicker("", selection: $draftDate, displayedComponents: .date)
                        .labelsHidden()
                    if let m = errors["date"] { Text(m).font(.caption2).foregroundStyle(.red) }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Hours").font(.caption).bold()
                    TextField("", text: $draftHours)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    if let m = errors["hours"] { Text(m).font(.caption2).foregroundStyle(.red) }
                }
                .frame(width: 140)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Note").font(.caption).bold()
                TextEditor(text: $draftNote)
                    .frame(minHeight: 220)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
                if let m = errors["note"] { Text(m).font(.caption2).foregroundStyle(.red) }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private func startEdit(_ a: DailyActivity) {
        editingId = a.id
        draftDate = a.date
        draftHours = String(format: "%.2f", a.hours)
        draftNote = a.note
        errors = [:]
    }

    private func cancelEdit() {
        editingId = nil
        errors = [:]
    }

    private func saveEdit() {
        guard let id = editingId else { return }

        var errs: [String: String] = [:]
        let hoursNum = Double(draftHours.trimmingCharacters(in: .whitespacesAndNewlines)) ?? .nan
        if !hoursNum.isFinite || hoursNum <= 0 { errs["hours"] = "Enter valid hours (> 0)." }
        if draftNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errs["note"] = "Describe the activity." }

        if !errs.isEmpty {
            errors = errs
            return
        }

        let updated = DailyActivity(
            id: id,
            date: draftDate,
            hours: (hoursNum * 100).rounded() / 100,
            note: draftNote
        )

        store.updateActivity(updated, in: projectId)
        cancelEdit()
    }

    private func addEntryAndEdit() {
        let new = DailyActivity(date: Date(), hours: 1.0, note: "New activity...")
        store.addActivity(new, to: projectId)
        startEdit(new)
    }

    private func printLogs(range: Bool) {
        guard !activities.isEmpty else {
            alertMsg = "There are no entries to print."
            return
        }

        let filtered: [DailyActivity]
        if range && useRange {
            let start = Calendar.current.startOfDay(for: fromDate)
            let endNext = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: Calendar.current.startOfDay(for: toDate)
            )!

            filtered = activities.filter { $0.date >= start && $0.date < endNext }
        } else {
            filtered = activities
        }

        guard !filtered.isEmpty else {
            alertMsg = "There are no entries in the selected date range."
            return
        }

        let html = PrintHelper.buildProjectLogHTML(
            internName: internName,
            projectName: projectName,
            plannedHours: plannedHours,
            totalHours: totalHours,
            from: (range && useRange) ? fromDate : nil,
            to: (range && useRange) ? toDate : nil,
            entries: filtered
        )

        PrintHelper.printHTML(
            jobName: "Project Log - \(projectName)",
            html: html
        )
    }

}

struct Pill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().stroke(Color(.separator), lineWidth: 1))
    }
}


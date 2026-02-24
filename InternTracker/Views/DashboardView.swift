import SwiftUI

struct DashboardView: View {
    @ObservedObject var store: HoursClockStore
    let username: String

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            List {
                ForEach(groupedByDayKeys, id: \.self) { day in
                    Section {
                        ForEach(entriesForDay(day)) { e in
                            entryRow(e)
                        }
                    } header: {
                        dayHeader(day)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Agrupación y orden

    private var groupedByDay: [Date: [TimeEntry]] {
        let cal = Calendar.current
        let userEntries = store.entries.filter { $0.username == username }

        // Agrupar por inicio del día
        let grouped = Dictionary(grouping: userEntries) { entry in
            cal.startOfDay(for: entry.clockIn)
        }

        return grouped
    }

    private var groupedByDayKeys: [Date] {
        groupedByDay.keys.sorted(by: >) // más reciente primero
    }

    private func entriesForDay(_ day: Date) -> [TimeEntry] {
        (groupedByDay[day] ?? []).sorted { $0.clockIn > $1.clockIn } // más reciente primero
    }

    // MARK: - UI pieces

    private func dayHeader(_ day: Date) -> some View {
        HStack {
            Text(dayFormatted(day))
                .font(.headline)
            Spacer()
            Text("Total: \(totalForDay(day))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .textCase(nil)
        .padding(.vertical, 6)
    }

    private func entryRow(_ e: TimeEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(e.company)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(e.clockOut == nil ? "ACTIVE" : "")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            }

            HStack {
                Text("In: \(timeString(e.clockIn))")
                    .foregroundStyle(.primary)
                Spacer()
                Text("Out: \(e.clockOut == nil ? "--" : timeString(e.clockOut!))")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()
                Text("Duration: \(formatDuration(e.durationSeconds))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .listRowBackground(Color(.systemBackground))
    }

    // MARK: - Helpers

    private func totalForDay(_ day: Date) -> String {
        let total = entriesForDay(day).reduce(0.0) { $0 + $1.durationSeconds }
        return formatDuration(total)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f.string(from: date)
    }

    private func dayFormatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .none
        return f.string(from: date)
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
//
//  DashboardView.swift
//  InternTracker
//
//  Created by Derki Echevarria Rodriguez on 2/2/26.
//


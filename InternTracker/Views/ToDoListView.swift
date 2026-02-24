import SwiftUI

struct ToDoListView: View {
    @ObservedObject var store: ToDoStore

    @State private var showAddWeek = false
    @State private var newWeekNumber = 1
    @State private var newWeekTitle = ""

    var body: some View {
        NavigationStack {
            List {
                let groups = store.grouped

                ForEach(groups.indices, id: \.self) { mIndex in
                    Section(header: Text(store.monthTitle(groups[mIndex].month))) {
                        ForEach(groups[mIndex].weeks.indices, id: \.self) { wIndex in
                            let weekGroup = groups[mIndex].weeks[wIndex]

                            DisclosureGroup(
                                "Week \(weekGroup.week.number) — \(weekGroup.week.title)"
                            ) {
                                // Add task to this week
                                Button("➕ Add task to this week") {
                                    store.addItem(
                                        title: "New Task",
                                        to: weekGroup.week.id
                                    )
                                }

                                ForEach(weekGroup.items) { item in
                                    HStack {
                                        Image(systemName: item.isDone
                                              ? "checkmark.circle.fill"
                                              : "circle")
                                            .onTapGesture {
                                                store.toggleDone(item.id)
                                            }

                                        VStack(alignment: .leading) {
                                            Text(item.title)

                                            Text(item.createdAt, style: .date)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("To Do")
            .toolbar {
                Button("Add Week") {
                    let maxWeek = store.weeks.map(\.number).max() ?? 0
                    newWeekNumber = maxWeek + 1
                    newWeekTitle = ""
                    showAddWeek = true
                }
            }
            .sheet(isPresented: $showAddWeek) {
                NavigationStack {
                    Form {
                        Stepper(
                            "Week: \(newWeekNumber)",
                            value: $newWeekNumber,
                            in: 1...52
                        )

                        TextField(
                            "Title (Onboarding, Training...)",
                            text: $newWeekTitle
                        )
                    }
                    .navigationTitle("New Week")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showAddWeek = false
                            }
                        }

                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                let title = newWeekTitle
                                    .trimmingCharacters(in: .whitespacesAndNewlines)

                                store.addWeek(
                                    number: newWeekNumber,
                                    title: title.isEmpty ? "Untitled" : title
                                )

                                showAddWeek = false
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            store.seedIfNeeded()
        }
    }
}


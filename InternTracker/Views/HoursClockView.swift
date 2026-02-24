import SwiftUI
 import Combine

struct HoursClockView: View {

    let username: String

    @StateObject private var store = HoursClockStore()

    @State private var now = Date()
    @State private var selectedCompany: String = "Eduardo J. Padrón Campus"
    @State private var showDashboard = false

    // ✅ Missing
    @State private var showMissingSheet = false
    @State private var missingClockIn =
        Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
    @State private var missingClockOut = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let royalBlue = Color(red: 0/255, green: 63/255, blue: 135/255)
    private let clockGreen = Color(red: 46/255, green: 125/255, blue: 50/255)

    private let companies = [
        "Eduardo J. Padrón Campus",
        "Kendall Campus",
        "North Campus",
        "Hialeah Campus",
        "InterAmerican Campus",
        "Homestead Campus",
        "West Campus",
        "Medical Campus"
    ]
    private var isActive: Bool {
        store.isClockedIn(username: username)
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 14) {

                // Header
                HStack(spacing: 10) {
                    Text("MDC")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(clockGreen)

                    Rectangle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 1, height: 28)

                    Text("TimeClock")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.primary)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Card principal
                VStack(spacing: 14) {

                    // Fecha + Hora
                    VStack(spacing: 6) {
                        Text(now.formatted(date: .numeric, time: .omitted))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.primary)

                        Text(now.formatted(date: .omitted, time: .standard))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(clockGreen)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    }
                    .padding(.top, 6)

                    // Company selector
                    HStack(spacing: 12) {
                        Text("Select Company")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 120, alignment: .trailing)

                        Picker("", selection: $selectedCompany) {
                            ForEach(companies, id: \.self) { c in
                                Text(c).tag(c)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }

                    // Username display
                    HStack(spacing: 14) {
                        Text("User")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 120, alignment: .trailing)

                        Text(username)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.secondarySystemBackground))
                            )
                    }

                    // Today Total
                    VStack(spacing: 4) {
                        Text("Today Total")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)

                        Text(formatDuration(store.totalSecondsToday(username: username)))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(royalBlue)
                    }
                    .padding(.top, 2)

                    HStack(spacing: 8) {
                        Circle()
                            .fill(isActive ? Color.green : Color.gray)
                            .frame(width: 10, height: 10)

                        Text(isActive ? "STATUS: CLOCKED IN (ACTIVE)" : "STATUS: CLOCKED OUT")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(isActive ? Color.green : Color.secondary)

                        Spacer()
                    }
                    .padding(.top, 6)

                    // Clock In / Out
                    HStack(spacing: 14) {
                        Button {
                            store.clockIn(company: selectedCompany, username: username)
                        } label: {
                            VStack(spacing: 2) {
                                Text("Clock")
                                Text("In")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 12).fill(clockGreen))
                            .opacity(isActive ? 0.45 : 1.0)

                        }
                        .disabled(store.isClockedIn(username: username))

                        Button {
                            store.clockOut(username: username)
                        } label: {
                            VStack(spacing: 2) {
                                Text("Clock")
                                Text("Out")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 12).fill(royalBlue))
                        }
                        .disabled(!store.isClockedIn(username: username))
                    }

                    // ✅ Missing button
                    Button {
                        showMissingSheet = true
                    } label: {
                        Text("Missing Clock In / Clock Out")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.35), lineWidth: 1.2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                    )
                            )
                    }
                    .padding(.top, 10)

                    // Dashboard
                    Button {
                        showDashboard = true
                    } label: {
                        Text("Log On To Dashboard")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.35), lineWidth: 1.2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                    )
                            )
                    }
                    .padding(.top, 24)
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
                )
                .padding(.horizontal)

                Spacer()
            }
        }
        .onReceive(timer) { _ in now = Date() }
        .navigationTitle("Hours Clock")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showDashboard) {
            DashboardView(store: store, username: username)
        }
        // ✅ Sheet BIEN puesto (NO fuera del body)
        .sheet(isPresented: $showMissingSheet) {
            NavigationStack {
                Form {
                    Section("Missing Clock In") {
                        DatePicker("Clock In",
                                   selection: $missingClockIn,
                                   displayedComponents: [.date, .hourAndMinute])

                        DatePicker("Clock Out",
                                   selection: $missingClockOut,
                                   displayedComponents: [.date, .hourAndMinute])

                        Button("Add Missing Clock In") {
                            store.addMissingClockIn(
                                company: selectedCompany,
                                username: username,
                                clockIn: missingClockIn,
                                clockOut: missingClockOut
                            )
                            showMissingSheet = false
                        }
                        .disabled(missingClockOut < missingClockIn)
                    }

                    Section("Missing Clock Out") {
                        Button("Fix Missing Clock Out") {
                            store.fixMissingClockOut(username: username, clockOut: Date())
                            showMissingSheet = false
                        }
                        .disabled(!store.isClockedIn(username: username))
                    }
                }
                .navigationTitle("Fix Missing Entry")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showMissingSheet = false }
                    }
                }
            }
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}


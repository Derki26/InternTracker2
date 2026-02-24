//
//  InternFormView.swift
//  InternTracker
//
//  Created by Derki Echevarria Rodriguez on 1/24/26.
//

import SwiftUI
import PhotosUI

struct InternFormView: View {

    enum Mode {
        case add
        case edit(existing: Intern)

        var title: String {
            switch self {
            case .add: return "Add Intern"
            case .edit: return "Edit Intern"
            }
        }
    }

    let mode: Mode
    var onSave: (Intern) -> Void

    @Environment(\.dismiss) private var dismiss

    private let royalBlue = Color(red: 0/255, green: 63/255, blue: 135/255)

    // ✅ Lists
    private let mdcCampuses: [String] = [
        "MDC – Padron Campus",
        "MDC – Wolfson Campus",
        "MDC – Kendall Campus",
        "MDC – North Campus",
        "MDC – Homestead Campus",
        "MDC – InterAmerican Campus",
        "MDC – Hialeah Campus",
        "MDC – West Campus",
        "MDC – Medical Campus"
    ]

    private let mentors: [(name: String, email: String)] = [
        (name: "Javier Crespo", email: "javier.crespo@mdc.edu"),
        (name: "Ricardo Alfonso Jr", email: "ricardo.alfonso@mdc.edu")
    ]

    // ✅ photo (preview only)
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    private var photoPreviewImage: Image? {
        guard let photoData, let ui = UIImage(data: photoData) else { return nil }
        return Image(uiImage: ui)
    }

    // ✅ Fields
    @State private var id: UUID = UUID()
    @State private var fullName = ""
    @State private var university = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var mentor = ""
    @State private var mentorEmail = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date()
    @State private var linkedin = ""
    @State private var notes = ""
    @State private var weeksText = ""
    @State private var totalHoursText = ""

    // ✅ Date confirm flow (Done)
    @State private var showStartPicker = false
    @State private var showEndPicker = false
    @State private var tempStartDate = Date()
    @State private var tempEndDate = Date()
    @State private var startConfirmed = false
    @State private var endConfirmed = false

    private var canSave: Bool {
        let nameOK = !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let uniOK = !university.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emailOK = isValidEmail(email)
        let mentorOK = !mentor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let datesOK = endDate >= startDate
        return nameOK && uniOK && emailOK && mentorOK && datesOK
    }

    var body: some View {
        NavigationStack {
            Form {

                // Photo section (same)
                Section {
                    HStack(spacing: 14) {
                        avatarView

                        VStack(alignment: .leading, spacing: 6) {
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Label("Add Photo", systemImage: "camera")
                                    .foregroundColor(royalBlue)
                            }

                            if photoData != nil {
                                Button(role: .destructive) {
                                    photoData = nil
                                    selectedPhotoItem = nil
                                } label: {
                                    Text("Remove Photo")
                                }
                            } else {
                                Text("Optional")
                                    .font(.footnote)
                                    .foregroundColor(royalBlue.opacity(0.65))
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Photo").foregroundColor(royalBlue)
                }

                Section("Basic Info") {
                    TextField("Full Name", text: $fullName)
                        .textInputAutocapitalization(.words)

                    Picker("University", selection: $university) {
                        ForEach(mdcCampuses, id: \.self) { campus in
                            Text(campus).tag(campus)
                        }
                    }
                    .tint(royalBlue)

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section("Mentor / Supervisor") {
                    Picker("Mentor Name", selection: $mentor) {
                        ForEach(mentors, id: \.name) { m in
                            Text(m.name).tag(m.name)
                        }
                    }
                    .tint(royalBlue)
                    .onChange(of: mentor) { newValue in
                        if let match = mentors.first(where: { $0.name == newValue }) {
                            mentorEmail = match.email
                        }
                    }

                    TextField("Mentor Email (optional)", text: $mentorEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Internship Dates") {

                    Button {
                        tempStartDate = startDate
                        showStartPicker = true
                    } label: {
                        HStack {
                            Text("Start Date")
                                .foregroundColor(startConfirmed ? royalBlue : .gray)
                            Spacer()
                            Text(startDate.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(startConfirmed ? royalBlue : .gray)
                        }
                    }

                    Button {
                        tempEndDate = endDate
                        showEndPicker = true
                    } label: {
                        HStack {
                            Text("Final Date")
                                .foregroundColor(endConfirmed ? royalBlue : .gray)
                            Spacer()
                            Text(endDate.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(endConfirmed ? royalBlue : .gray)
                        }
                    }

                    if endDate < startDate {
                        Text("Final date must be on/after Start date")
                            .foregroundStyle(.red)
                    }
                }

                Section("Total Weeks") {
                    TextField("Weeks", text: $weeksText)
                        .keyboardType(.numberPad)

                    TextField("Total Hours per Week (optional)", text: $totalHoursText)
                        .keyboardType(.decimalPad)
                }

                Section("Socials") {
                    TextField("LinkedIn (optional)", text: $linkedin)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Skills / Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }

                Section { EmptyView() }
                    .listRowBackground(Color.clear)
            }
            .foregroundColor(royalBlue)
            .tint(royalBlue)
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(.keyboard, edges: .bottom)
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
            .onAppear {
                // Load existing intern if editing
                if case .edit(let existing) = mode {
                    id = existing.id
                    fullName = existing.fullName
                    university = existing.university
                    email = existing.email
                    phone = existing.phone
                    mentor = existing.mentor
                    mentorEmail = existing.mentorEmail
                    startDate = existing.startDate
                    endDate = existing.endDate
                    linkedin = existing.linkedin
                    notes = existing.notes
                    weeksText = existing.weeks.map(String.init) ?? ""
                    totalHoursText = existing.totalHours.map { String($0) } ?? ""

                    startConfirmed = true
                    endConfirmed = true
                } else {
                    // set default mentor email if empty
                    if mentorEmail.isEmpty, let match = mentors.first(where: { $0.name == mentor }) {
                        mentorEmail = match.email
                    }
                }
            }
            .task(id: selectedPhotoItem) {
                await loadSelectedPhoto()
            }
            // sheets for date confirmation
            .sheet(isPresented: $showStartPicker) { startPickerSheet }
            .sheet(isPresented: $showEndPicker) { endPickerSheet }
        }
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(royalBlue.opacity(0.12))
                .frame(width: 54, height: 54)

            if let img = photoPreviewImage {
                img.resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(royalBlue.opacity(0.8))
            }
        }
        .overlay(Circle().stroke(royalBlue.opacity(0.35), lineWidth: 1))
    }

    private var startPickerSheet: some View {
        NavigationStack {
            VStack {
                DatePicker("", selection: $tempStartDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                Spacer()
            }
            .navigationTitle("Start Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { showStartPicker = false }
                        .foregroundColor(royalBlue)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        startDate = tempStartDate
                        calculateWeeks()
                        startConfirmed = true
                        showStartPicker = false
                    }
                    .foregroundColor(royalBlue)
                }
            }
        }
    }

    private var endPickerSheet: some View {
        NavigationStack {
            VStack {
                DatePicker("", selection: $tempEndDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                Spacer()
            }
            .navigationTitle("Final Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { showEndPicker = false }
                        .foregroundColor(royalBlue)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        endDate = tempEndDate
                        calculateWeeks()
                        endConfirmed = true
                        showEndPicker = false
                    }
                    .foregroundColor(royalBlue)
                }
            }
        }
    }

    private func loadSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                await MainActor.run { self.photoData = data }
            }
        } catch { }
    }

    private func calculateWeeks() {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        if days >= 0 {
            let weeks = Int(ceil(Double(days) / 7.0))
            weeksText = weeks > 0 ? "\(weeks)" : "1"
        }
    }

    private func save() {
        let weeks = Int(weeksText.trimmingCharacters(in: .whitespacesAndNewlines))
        let totalHours = Double(totalHoursText.trimmingCharacters(in: .whitespacesAndNewlines))

        let intern = Intern(
            id: id,
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            university: university.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            mentor: mentor.trimmingCharacters(in: .whitespacesAndNewlines),
            mentorEmail: mentorEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            startDate: startDate,
            endDate: endDate,
            linkedin: linkedin.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            weeks: weeks,
            totalHours: totalHours,
            photoUrl: nil
        )

        onSave(intern)
        dismiss()
    }

    private func isValidEmail(_ s: String) -> Bool {
        let v = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return v.contains("@") && v.contains(".") && v.count >= 5
    }
}

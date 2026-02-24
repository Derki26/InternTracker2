import SwiftUI
import Foundation
import Combine


@MainActor
final class SessionStore: ObservableObject {
    @Published var session: Session? = nil
    @Published var mode: AppMode = .student
    @Published var activeInternId: UUID? = nil

    private let kSession = "internTracker.session"
    private let kMode = "internTracker.mode"
    private let kActive = "internTracker.activeInternId"

    // TEMP local admins
    private let adminUsernames: Set<String> = ["drodri54", "admin", "mentor1"]

    func load() {
        if let data = UserDefaults.standard.data(forKey: kSession),
           let s = try? JSONDecoder().decode(Session.self, from: data) {
            session = s
        }
        if let raw = UserDefaults.standard.string(forKey: kMode),
           let m = AppMode(rawValue: raw) { mode = m }
        if let raw = UserDefaults.standard.string(forKey: kActive),
           let id = UUID(uuidString: raw) { activeInternId = id }

        enforce()
    }

    func login(username raw: String, data: LocalDataStore) -> String? {
        let cleaned = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let u = cleaned.contains("@")
            ? cleaned.components(separatedBy: "@").first ?? cleaned
            : cleaned

        guard u.count >= 2 else { return "Username too short." }

        guard let intern = data.intern(for: u) else {
            return "Username not found in local interns."
        }

        let role: Role = adminUsernames.contains(u) ? .admin : .student
        session = Session(username: u, role: role, internId: intern.id)

        mode = .student
        activeInternId = nil
        save()
        enforce()
        return nil
    }

    func logout() {
        session = nil
        mode = .student
        activeInternId = nil
        UserDefaults.standard.removeObject(forKey: kSession)
        UserDefaults.standard.removeObject(forKey: kMode)
        UserDefaults.standard.removeObject(forKey: kActive)
    }

    func toggleMode() {
        guard session?.role == .admin else { return }
        mode = (mode == .admin) ? .student : .admin
        if mode == .student { activeInternId = nil }
        save()
    }

    func setActiveIntern(_ id: UUID?) {
        guard session?.role == .admin else { return }
        activeInternId = id
        save()
    }

    private func enforce() {
        if session?.role != .admin {
            mode = .student
            activeInternId = nil
        }
    }

    private func save() {
        if let session,
           let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: kSession)
        }
        UserDefaults.standard.set(mode.rawValue, forKey: kMode)
        if let activeInternId {
            UserDefaults.standard.set(activeInternId.uuidString, forKey: kActive)
        } else {
            UserDefaults.standard.removeObject(forKey: kActive)
        }
    }
}


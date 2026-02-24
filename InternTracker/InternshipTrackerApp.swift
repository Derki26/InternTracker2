import SwiftUI

@main
struct InternshipTrackerApp: App {
    @StateObject private var internStore = InternStore()
    @StateObject private var projectStore = ProjectStore()

    // ✅ NUEVOS (para Admin/Student gate)
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var dataStore = LocalDataStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(internStore)
                .environmentObject(projectStore)
                .environmentObject(sessionStore) // ✅
                .environmentObject(dataStore)    // ✅
        }
    }
}


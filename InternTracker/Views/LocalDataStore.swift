import SwiftUI
import Foundation
import Combine

@MainActor
final class LocalDataStore: ObservableObject {

    @Published var interns: [ITIntern] = [
        ITIntern(id: UUID(), fullName: "Ana Perez", username: "ana"),
        ITIntern(id: UUID(), fullName: "Luis Gomez", username: "luis"),
        ITIntern(id: UUID(), fullName: "Derki Echeverria", username: "drodri54"),
    ]

    func intern(for username: String) -> ITIntern? {
        let u = username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return interns.first { $0.username.lowercased() == u }
    }
}


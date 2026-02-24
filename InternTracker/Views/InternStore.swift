//
//  InternStore.swift
//  InternTracker
//
//  Created by Derki Echevarria Rodriguez on 1/24/26.
//

import SwiftUI
 import Combine

@MainActor
final class InternStore: ObservableObject {

    @Published var interns: [Intern] = []

    func upsert(_ intern: Intern) {
        if let idx = interns.firstIndex(where: { $0.id == intern.id }) {
            interns[idx] = intern
        } else {
            interns.append(intern)
        }
    }

    func delete(_ intern: Intern) {
        interns.removeAll { $0.id == intern.id }
    }
}


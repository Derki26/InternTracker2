import Foundation

struct ToDoWeek: Identifiable, Hashable, Codable, Comparable {
    let id: UUID
    var number: Int
    var title: String
    var createdAt: Date

    init(id: UUID = UUID(), number: Int, title: String, createdAt: Date = Date()) {
        self.id = id
        self.number = number
        self.title = title
        self.createdAt = createdAt
    }

    static func < (lhs: ToDoWeek, rhs: ToDoWeek) -> Bool {
        if lhs.number != rhs.number { return lhs.number < rhs.number }
        return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
    }
}
//
//  ToDoWeek.swift
//  InternTracker
//
//  Created by Derki Echevarria Rodriguez on 2/2/26.
//


import Foundation

enum Role: String, Codable { case student, admin }
enum AppMode: String, Codable { case student, admin }

struct Session: Codable {
    var username: String
    var role: Role
    var internId: UUID
}

struct ITIntern: Identifiable, Codable {
    var id: UUID
    var fullName: String
    var username: String
}

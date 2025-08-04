import Foundation

struct ScoreEntry: Codable, Identifiable {
    let id: String // Firebase push key
    let score: Int
    let timestamp: TimeInterval

    var date: Date {
        return Date(timeIntervalSince1970: timestamp)
    }
}


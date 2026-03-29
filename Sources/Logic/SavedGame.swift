import Foundation

struct SavedGame: Codable {
    let levelIndex: Int
    let score: Int
    let lives: Int
    let brickGrid: [[BrickCell]]
}

import Foundation

/**
 * Represents the type that a verse can take.
 */
enum VerseType: String, Codable {
    case verse
    case chorus
    case other
    case copyright
    case note
    case doNotDisplay = "do_not_display"
}

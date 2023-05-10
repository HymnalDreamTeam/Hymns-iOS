import Foundation

/**
 * Represents the type that a verse can take.
 */
enum VerseType: String, Codable {
    case verse
    case chorus
    case doNotDisplay = "do_not_display"
    case other
}

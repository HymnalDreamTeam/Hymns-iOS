import Foundation

protocol AnalyticsEvent {
    static var name: String { get }
}

struct SearchActiveChanged: AnalyticsEvent {

    static let name = "search_active"

    // Allow non-alphanumeric characters for logging params
    // swiftlint:disable identifier_name
    enum Params: String {
        case is_active
    }
    // swiftlint:enable identifier_name
}

struct QueryChanged: AnalyticsEvent {

    static let name = "query_changed"

    // Allow non-alphanumeric characters for logging params
    // swiftlint:disable identifier_name
    enum Params: String {
        case query_text
    }
    // swiftlint:enable identifier_name
}

// Allow non-alphanumeric characters for logging params
// swiftlint:disable:identifier_name
struct DisplaySong: AnalyticsEvent {

    static let name = "display_song"

    // Allow non-alphanumeric characters for logging params
    // swiftlint:disable identifier_name
    enum Params: String {
        case hymn_identifier
    }
    // swiftlint:enable identifier_name
}

struct PreloadMusicPdf: AnalyticsEvent {

    static let name = "display_music_pdf_preloading"

    // Allow non-alphanumeric characters for logging params
    // swiftlint:disable identifier_name
    enum Params: String {
        case pdf_url
    }
    // swiftlint:enable identifier_name
}

struct LoadMusicPdf: AnalyticsEvent {

    static let name = "display_music_pdf_preloading"

    // Allow non-alphanumeric characters for logging params
    // swiftlint:disable identifier_name
    enum Params: String {
        case pdf_url
    }
    // swiftlint:enable identifier_name
}

struct DisplayMusicPdfSuccess: AnalyticsEvent {

    static let name = "display_music_pdf_loading"

    // Allow non-alphanumeric characters for logging params
    // swiftlint:disable identifier_name
    enum Params: String {
        case pdf_url
    }
    // swiftlint:enable identifier_name
}

struct DisplayMusicPdfFailed: AnalyticsEvent {

    static let name = "display_music_pdf_failed"

    // Allow non-alphanumeric characters for logging params
    // swiftlint:disable identifier_name
    enum Params: String {
        case pdf_url
    }
    // swiftlint:enable identifier_name
}

struct NonFatalEvent: AnalyticsEvent {

    static let name = "non_fatal_error"

    enum Params: String {
        case message
        case error
    }

    enum ErrorCode: Int {
        case databaseInitialization
    }
}

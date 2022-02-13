import FirebaseAnalytics
import Foundation
import Resolver

/**
 * Wrapper for `FirebaseAnalytics` to help keep track of what we are logging and analyzing.
 */
class AnalyticsLogger {

    private let backgroundThread: DispatchQueue

    init(backgroundThread: DispatchQueue = Resolver.resolve(name: "background")) {
        self.backgroundThread = backgroundThread
    }

    func logBFALinkClicked() {
        backgroundThread.async {
            Analytics.logEvent("bfa_link_clicked", parameters: nil)
        }
    }

    func logSearchActive(isActive: Bool) {
        backgroundThread.async {
            Analytics.logEvent(SearchActiveChanged.name, parameters: [
                SearchActiveChanged.Params.is_active.rawValue: isActive ? "true" : false
            ])
        }
    }

    func logQueryChanged(queryText: String) {
        backgroundThread.async {
            Analytics.logEvent(QueryChanged.name, parameters: [
                QueryChanged.Params.query_text.rawValue: queryText
            ])
        }
    }

    func logDisplaySong(hymnIdentifier: HymnIdentifier) {
        backgroundThread.async {
            Analytics.logEvent(DisplaySong.name, parameters: [
                DisplaySong.Params.hymn_identifier.rawValue: String(describing: hymnIdentifier)
            ])
        }
    }

    func logPreloadMusicPdf(url: URL) {
        backgroundThread.async {
            Analytics.logEvent(PreloadMusicPdf.name, parameters: [
                PreloadMusicPdf.Params.pdf_url.rawValue: url.absoluteString
            ])
        }
    }

    func logLoadMusicPdf(url: URL) {
        backgroundThread.async {
            Analytics.logEvent(LoadMusicPdf.name, parameters: [
                LoadMusicPdf.Params.pdf_url.rawValue: url.absoluteString
            ])
        }
    }

    func logDisplayMusicPdfSuccess(url: URL) {
        backgroundThread.async {
            Analytics.logEvent(DisplayMusicPdfSuccess.name, parameters: [
                DisplayMusicPdfSuccess.Params.pdf_url.rawValue: url.absoluteString
            ])
        }
    }

    func logDisplayMusicPdfFailed(url: URL) {
        backgroundThread.async {
            Analytics.logEvent(DisplayMusicPdfFailed.name, parameters: [
                DisplayMusicPdfFailed.Params.pdf_url.rawValue: url.absoluteString
            ])
        }
    }

    /**
     * Log when an error ocurred but is not a fatal error but may happen frequently enough that we don't to
     * log it as a Crashlytics non-fatal.
     * https://firebase.google.com/docs/crashlytics/customize-crash-reports?platform=ios#log-excepts
     */
    func logError(message: String, error: Error? = nil, extraParameters: [String: String]? = nil) {
        var parameters: [String: String] = [NonFatalEvent.Params.message.rawValue: message]
        if let error = error {
            parameters[NonFatalEvent.Params.error.rawValue] = error.localizedDescription
        }
        if let extraParameters = extraParameters {
            parameters.merge(extraParameters) { (current, _) in current }
        }
        backgroundThread.async {
            Analytics.logEvent(NonFatalEvent.name, parameters: parameters)
        }
    }
}

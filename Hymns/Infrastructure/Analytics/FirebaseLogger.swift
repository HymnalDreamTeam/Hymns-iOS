import FirebaseAnalytics
import FirebaseCrashlytics
import Foundation
import Resolver

/**
 * Wrapper for `FirebaseAnalytics` and `FirebaseCrashLyrics` to help keep track of what we are logging and analyzing.
 */
protocol FirebaseLogger {
    func logLaunchTask(description: String)
    func logScreenView(screenName: String)
    func logSearchActive(isActive: Bool)
    func logQueryChanged(queryText: String)
    func logDisplaySong(hymnIdentifier: HymnIdentifier)
    func logDonation(product: CoffeeDonation, result: PurchaseResultWrapper)
    func logPreloadMusicPdf(url: URL)
    func logLoadMusicPdf(url: URL)
    func logDisplayMusicPdfSuccess(url: URL)
    func logDisplayMusicPdfFailed(url: URL)

    func logError(message: String)
    func logError(message: String, error: Error)
    func logError(message: String, extraParameters: [String: String])
    /// By definition, logging an error is logging a non fatal because if it were fatal, we the app would be crashing
    /// https://firebase.google.com/docs/crashlytics/customize-crash-reports?platform=ios#log-excepts
    func logError(message: String, error: Error?, extraParameters: [String: String]?)
}

class FirebaseLoggerImpl: FirebaseLogger {

    private let backgroundThread: DispatchQueue

    init(backgroundThread: DispatchQueue = Resolver.resolve(name: "background")) {
        self.backgroundThread = backgroundThread
    }

    func logLaunchTask(description: String) {
        backgroundThread.async {
            Analytics.logEvent(LaunchTask.name, parameters: [
                LaunchTask.Params.description.rawValue: description
            ])
        }
    }

    func logScreenView(screenName: String) {
        backgroundThread.async {
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                AnalyticsParameterScreenName: screenName
            ])
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

    func logDonation(product: CoffeeDonation, result: PurchaseResultWrapper) {
        backgroundThread.async {
            Analytics.logEvent(DonateCoffee.name, parameters: [
                DonateCoffee.Params.product.rawValue: String(describing: product),
                DonateCoffee.Params.result.rawValue: String(describing: result)
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

    func logError(message: String) {
        logError(message: message, error: nil, extraParameters: nil)
    }

    func logError(message: String, error: Error) {
        logError(message: message, error: error, extraParameters: nil)
    }

    func logError(message: String, extraParameters: [String: String]) {
        logError(message: message, error: nil, extraParameters: extraParameters)
    }

    func logError(message: String, error: Error?, extraParameters: [String: String]?) {
        guard let error = error else {
            backgroundThread.async {
                Crashlytics.crashlytics().record(error: AppError(errorDescription: message))
            }
            return
        }

        var userInfo = extraParameters ?? [String: String]()
        userInfo["error_message"] = message
        backgroundThread.async {
            Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
        }
    }
}

import AVFoundation
import Combine
import Resolver
import WebKit

class SoundCloudViewModel: ObservableObject {

    @UserDefault("has_seen_soundcloud_minimize_tooltip", defaultValue: false) var hasSeenSoundCloudMinimizeTooltip: Bool

    @Published var url: URL
    @Published var showMinimizeCaret: Bool = false
    @Published var showMinimizeToolTip: Bool = false
    @Published var title: String?

    private var timerConnection: Cancellable?

    var titleObservation: NSKeyValueObservation?

    var titleObserver: ((WKWebView, NSKeyValueObservedChange<String?>) -> Void) { { (webView, change) in
        guard let title = change.newValue else {
            return
        }
        self.title = title
        }}

    init(url: URL) {
        self.url = url
        timerConnection = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink(receiveValue: { [weak self ]_ in
            guard let self = self else { return }
            if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint {
                // Media is playing
                self.showMinimizeCaret = true
                if !self.hasSeenSoundCloudMinimizeTooltip {
                    self.showMinimizeToolTip = true
                }
            } else {
                self.showMinimizeCaret = false
            }
        })
    }

    deinit {
        timerConnection?.cancel()
        timerConnection = nil
        titleObservation = nil
    }

    func dismissToolTip() {
        showMinimizeToolTip = false
        hasSeenSoundCloudMinimizeTooltip = true
    }
}

extension SoundCloudViewModel: Hashable {
    static func == (lhs: SoundCloudViewModel, rhs: SoundCloudViewModel) -> Bool {
        lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

import AVFoundation
import Combine
import Resolver
import WebKit
import SwiftUI

class SoundCloudViewModel: ObservableObject {

    @Published var url: URL
    @Published var showMinimizeCaret: Bool = false
    @Published var showMinimizeToolTip: Bool = false
    @Published var title: String?

    private let userDefaultsManager: UserDefaultsManager

    var timerConnection: Cancellable?

    var titleObservation: NSKeyValueObservation?

    var titleObserver: ((WKWebView, NSKeyValueObservedChange<String?>) -> Void) { { (_, change) in
        guard let title = change.newValue else {
            return
        }
        self.title = title
        }}

    init(url: URL, userDefaultsManager: UserDefaultsManager = Resolver.resolve()) {
        self.url = url
        self.userDefaultsManager = userDefaultsManager

        timerConnection = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink(receiveValue: { [weak self ] _ in
            guard let self = self else { return }
            if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint {
                // Media is playing
                self.showMinimizeCaret = true
                if !userDefaultsManager.hasSeenSoundCloudMinimizeTooltip {
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
        userDefaultsManager.hasSeenSoundCloudMinimizeTooltip = true
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

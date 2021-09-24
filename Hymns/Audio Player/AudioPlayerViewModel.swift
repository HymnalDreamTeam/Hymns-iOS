import AVFoundation
import FirebaseCrashlytics
import Combine
import Resolver
import SwiftUI

enum PlaybackState: Int {
    case buffering
    case playing
    case stopped
}

class AudioPlayerViewModel: NSObject, ObservableObject {

    @Published var playbackState: PlaybackState = .stopped
    @Published var showSpeedAdjuster = true
    @Published var shouldRepeat = false
    @Published var currentSpeed: Float = 1.0
    @Published var currentTime: TimeInterval
    @Published var songDuration: TimeInterval?

    /**
     * Number of seconds to seek forward or backwards when rewind/fast-forward is triggered.
     */
    public static let seekDuration: Float64 = 2

    private let backgroundQueue: DispatchQueue
    private let mainQueue: DispatchQueue
    private let url: URL
    private let service: HymnalNetService

    private var dataFetchCall: Cancellable?
    private var interruptedObserver: Any?
    private var timerConnection: Cancellable?
    /* VISIBLE FOR UNIT TESTS. DO NOT USE OUTSIDE OF THIS CLASS */ var player: AVAudioPlayer?

    init(url: URL,
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         service: HymnalNetService = Resolver.resolve(),
         systemUtil: SystemUtil = Resolver.resolve()) {
        self.url = url
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.service = service
        self.currentTime = TimeInterval.zero

        // For small screens, don't show the speed adjuster button.
        if systemUtil.isSmallScreen() {
            self.showSpeedAdjuster = false
        }

        // https://stackoverflow.com/questions/30832352/swift-keep-playing-sounds-when-the-device-is-locked
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
            Crashlytics.crashlytics().record(error: NonFatal(localizedDescription: "Unable to set AVAudioSession category to \(AVAudioSession.Category.playback.rawValue)"))
        }
    }

    func load(completion: ((_ player: AVAudioPlayer) -> Void)? = nil, failed: (() -> Void)? = nil) {
        if let dataFetchCall = dataFetchCall {
            dataFetchCall.cancel()
        }
        dataFetchCall = service.getData(url)
            .subscribe(on: backgroundQueue)
            .tryMap({ data -> AVAudioPlayer in
                try AVAudioPlayer(data: data)
            })
            .replaceError(with: nil)
            .receive(on: mainQueue)
            .sink { [weak self] audioPlayer in
                guard let self = self else { return }
                self.player = audioPlayer
                guard let player = self.player else {
                    if let failed = failed {
                        failed()
                    }
                    Crashlytics.crashlytics().record(error: NonFatal(localizedDescription: "Failed to initialize audio player"))
                    return
                }
                player.delegate = self
                player.enableRate = true
                self.songDuration = player.duration
                self.interruptedObserver
                    = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: nil, using: { _ in
                        self.pause()
                    })
                if let completion = completion {
                    completion(player)
                }
        }
    }

    func play() {
        playbackState = .buffering
        guard let player = player else {
            load(completion: { player in
                self.playInternal(player)
            }, failed: {
                self.playbackState = .stopped
            })
            return
        }
        playInternal(player)
    }

    /**
     * Internal function to actually perform the play command.
     */
    private func playInternal(_ player: AVAudioPlayer) {
        playbackState = .playing
        startTimer()
        player.play()
    }

    func pause() {
        playbackState = .stopped
        stopTimer()
        player?.pause()
    }

    func increaseSpeed() {
        player?.rate += 0.1
        currentSpeed = player?.rate ?? 1.0
    }

    func decreaseSpeed() {
        player?.rate -= 0.1
        currentSpeed = player?.rate ?? 1.0
    }

    func rewind() {
        guard let player = player else {
            return
        }
        let rewoundTime = player.currentTime - AudioPlayerViewModel.seekDuration
        player.currentTime = rewoundTime >= TimeInterval.zero ? rewoundTime : TimeInterval.zero
        self.currentTime = player.currentTime
    }

    func fastForward() {
        guard let player = player else {
            return
        }
        let fastForwardedTime = player.currentTime + AudioPlayerViewModel.seekDuration
        player.currentTime = fastForwardedTime <= player.duration ? fastForwardedTime : player.duration
        self.currentTime = player.currentTime
    }

    func toggleRepeat() {
        shouldRepeat.toggle()
    }

    func reset() {
        playbackState = .stopped
        shouldRepeat = false
        player?.stop()
        player = nil
        currentTime = TimeInterval.zero
        interruptedObserver = nil
        timerConnection = nil
        load()
    }

    func seek(to time: TimeInterval) {
        currentTime = time
        player?.currentTime = time
    }

    func stopTimer() {
        timerConnection?.cancel()
    }

    func startTimer() {
        timerConnection = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect().sink(receiveValue: { [weak self ]_ in
            guard let self = self else { return }
            self.currentTime = self.player?.currentTime ?? 0
        })
    }
}

extension AudioPlayerViewModel: AVAudioPlayerDelegate {
    
    override func isEqual(_ object: Any?) -> Bool {
        return url == (object as? AudioPlayerViewModel)?.url
    }
    
    override var hash: Int {
        return url.hashValue
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.currentTime = TimeInterval.zero
        currentTime = player.currentTime
        if self.shouldRepeat {
            player.play()
        } else {
            self.playbackState = .stopped
            player.stop()
            stopTimer()
        }
    }
}

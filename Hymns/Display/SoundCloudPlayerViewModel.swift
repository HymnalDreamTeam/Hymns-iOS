import AVFoundation
import Combine
import RealmSwift
import Resolver
import SwiftUI

class SoundCloudPlayerViewModel: ObservableObject {

    @Published var showPlayer: Bool = false
    @Published var title: String?

    @Binding var dialogModel: DialogViewModel<AnyView>?

    private var timerConnection: Cancellable?

    private var disposables = Set<AnyCancellable>()

    init(dialogModel: Binding<DialogViewModel<AnyView>?>, title: Published<String?>.Publisher,
         mainQueue: DispatchQueue = Resolver.resolve(name: "main")) {
        self._dialogModel = dialogModel
        timerConnection = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink(receiveValue: { [weak self ]_ in
            guard let self = self else { return }
            self.showPlayer = AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint
        })
        title.receive(on: mainQueue)
            .sink { title in
                guard let title = title else {
                    return
                }
                self.title = title
        }.store(in: &disposables)
    }

    deinit {
        timerConnection?.cancel()
        timerConnection = nil
    }

    func openPlayer() {
        dialogModel?.opacity = 1
    }

    func dismissPlayer() {
        self.timerConnection?.cancel()
        self.showPlayer = false
        self.dialogModel = nil
    }
}

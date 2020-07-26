import Resolver
import SwiftUI

struct DisplayHymnBottomBar: View {

    @Binding var dialogBuilder: (() -> AnyView)?
    @State private var actionSheet: ActionSheetItem?
    @State private var sheet: DisplayHymnSheet?

    // Navigating out of an action sheet requires another state variable
    // https://stackoverflow.com/questions/59454407/how-to-navigate-out-of-a-actionsheet
    @State private var resultToShow: SongResultViewModel?

    @State var audioPlayer: AudioPlayerViewModel?

    @ObservedObject var viewModel: DisplayHymnBottomBarViewModel
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory

    let userDefaultsManager: UserDefaultsManager = Resolver.resolve()

    var body: some View {
        VStack {
            audioPlayer.map { audioPlayer in
                VStack {
                    Divider()
                    AudioPlayer(viewModel: audioPlayer).padding()
                }
            }
            HStack(spacing: 0) {
                Spacer()
                ForEach(viewModel.buttons) { button in
                    Button<AnyView>(action: {
                        switch button {
                        case .share(let lyrics):
                            self.sheet = .share(lyrics)
                        case .fontSize:
                            self.actionSheet = .fontSize
                        case .languages(let viewModels):
                            self.actionSheet = .languages(viewModels)
                        case .musicPlayback(let audioPlayer):
                            if self.audioPlayer == nil {
                                self.audioPlayer = audioPlayer
                            } else {
                                self.audioPlayer = nil
                            }
                        case .relevant(let viewModels):
                            self.actionSheet = .relevant(viewModels)
                        case .tags:
                            self.sheet = .tags
                        case .songInfo(let songInfoDialogViewModel):
                            self.dialogBuilder = {
                                SongInfoDialogView(viewModel: songInfoDialogViewModel).eraseToAnyView()
                            }
                        }
                    }, label: {
                        switch button {
                        case .musicPlayback:
                            return self.audioPlayer == nil ?
                                button.unselectedLabel.eraseToAnyView() :
                                button.selectedLabel.eraseToAnyView()
                        default:
                            return button.unselectedLabel.eraseToAnyView()
                        }
                    })
                    Spacer()
                }
                resultToShow.map { viewModel in
                    NavigationLink(destination: viewModel.destinationView,
                                   tag: viewModel,
                                   selection: $resultToShow) { EmptyView() }
                }
            }
        }.onAppear {
            self.viewModel.fetchHymn()
        }.actionSheet(item: $actionSheet) { item -> ActionSheet in
            switch item {
            case .fontSize:
                return
                    ActionSheet(
                        title: Text(NSLocalizedString("Lyrics font size",
                                                      comment: "Title for the lyrics font size action sheet")),
                        message: Text(NSLocalizedString("Change the song lyrics font size",
                                                        comment: "Message for the lyrics font size action sheet")),
                        buttons: [
                            .default(Text(FontSize.normal.rawValue),
                                     action: {
                                        self.userDefaultsManager.fontSize = .normal
                            }),
                            .default(Text(FontSize.large.rawValue),
                                     action: {
                                        self.userDefaultsManager.fontSize = .large
                            }),
                            .default(Text(FontSize.xlarge.rawValue),
                                     action: {
                                        self.userDefaultsManager.fontSize = .xlarge
                            }), .cancel()])
            case .languages(let viewModels):
                return
                    ActionSheet(
                        title: Text(NSLocalizedString("Languages",
                                                      comment: "Title for the languages action sheet")),
                        message: Text(NSLocalizedString("Change to another language",
                                                        comment: "Message for the languages action sheet")),
                        buttons: viewModels.map({ viewModel -> Alert.Button in
                            .default(Text(viewModel.title), action: {
                                self.resultToShow = viewModel
                            })
                        }) + [.cancel()])
            case .relevant(let viewModels):
                return
                    ActionSheet(
                        title: Text(NSLocalizedString("Relevant songs",
                                                      comment: "Title for the relevant songs action sheet")),
                        message: Text(NSLocalizedString("Change to a relevant hymn",
                                                        comment: "Message for the relevant songs action sheet")),
                        buttons: viewModels.map({ viewModel -> Alert.Button in
                            .default(Text(viewModel.title), action: {
                                self.resultToShow = viewModel
                            })
                        }) + [.cancel()])
            }
        }.sheet(item: $sheet) { tab -> AnyView in
            switch tab {
            case .share(let lyrics):
                return ShareSheet(activityItems: [lyrics]).eraseToAnyView()
            case .tags:
                return TagSheetView(viewModel: TagSheetViewModel(hymnToDisplay: self.viewModel.identifier), sheet: self.$sheet).eraseToAnyView()
            case .songInfo(let viewModel): // Case only used for large accesability
                return SongInfoSheetView(viewModel: viewModel).eraseToAnyView()
            }
        }.background(Color(.systemBackground))
    }
}

private enum ActionSheetItem {
    case fontSize
    case languages([SongResultViewModel])
    case relevant([SongResultViewModel])
}

extension ActionSheetItem: Identifiable {
    var id: Int {
        switch self {
        case .fontSize:
            return 0
        case .languages:
            return 1
        case .relevant:
            return 2
        }
    }
}

enum DisplayHymnSheet {
    case share(String)
    case tags
    case songInfo(SongInfoDialogViewModel)
}

extension DisplayHymnSheet: Identifiable {
    var id: Int {
        switch self {
        case .share:
            return 0
        case .tags:
            return 1
        case .songInfo:
            return 2
        }
    }
}

#if DEBUG
struct DisplayHymnBottomBar_Previews: PreviewProvider {
    static var previews: some View {
        var dialogBuilder: (() -> AnyView)?

        let minimumViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        let minimum = DisplayHymnBottomBar(dialogBuilder: Binding<(() -> AnyView)?>(
            get: {dialogBuilder},
            set: {dialogBuilder = $0}), viewModel: minimumViewModel)

        let maximumViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        maximumViewModel.buttons = [
            .share("lyrics"),
            .fontSize,
            .languages([SongResultViewModel(title: "language", destinationView: EmptyView().eraseToAnyView())]),
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)),
            .relevant([SongResultViewModel(title: "relevant", destinationView: EmptyView().eraseToAnyView())]),
            .tags,
            .songInfo(SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151))
        ]
        let maximum = DisplayHymnBottomBar(dialogBuilder: Binding<(() -> AnyView)?>(
            get: {dialogBuilder},
            set: {dialogBuilder = $0}), viewModel: maximumViewModel)

        return Group {
            minimum.previewDisplayName("minimum number of buttons")
            maximum.previewDisplayName("maximum number of buttons")
        }
    }
}
#endif

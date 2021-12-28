import Resolver
import SwiftUI

struct DisplayHymnBottomBar: View {

    @Binding var dialogModel: DialogViewModel<AnyView>?
    @State private var actionSheet: ActionSheetItem?
    @State private var sheet: DisplayHymnSheet?

    // Navigating out of an action sheet requires another state variable
    // https://stackoverflow.com/questions/59454407/how-to-navigate-out-of-a-actionsheet
    @State private var resultToShow: SongResultViewModel?

    @State var audioPlayer: AudioPlayerViewModel?
    @State var soundCloudPlayer: SoundCloudPlayerViewModel?

    @ObservedObject var viewModel: DisplayHymnBottomBarViewModel
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory

    let application: Application = Resolver.resolve()
    let userDefaultsManager: UserDefaultsManager = Resolver.resolve()

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            soundCloudPlayer.map { soundCloudPlayer in
                SoundCloudPlayer(viewModel: soundCloudPlayer)
            }

            audioPlayer.map { audioPlayer in
                AudioPlayer(viewModel: audioPlayer).padding()
            }
            HStack(spacing: 0) {
                ForEach(viewModel.buttons, id: \.self) { button in
                    Spacer()
                    Button<AnyView>(action: {
                        self.performAction(button: button)
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
                viewModel.overflowButtons.map { buttons in
                    Button(action: {
                        self.actionSheet = .overflow(buttons)
                    }, label: {
                        BottomBarLabel(image: Image(systemName: "ellipsis"),
                                       a11yLabel: NSLocalizedString("More options", comment: "Bottom bar overflow button"))
                            .foregroundColor(.primary)
                    })
                }
            }
            resultToShow.map { viewModel in
                NavigationLink(destination: viewModel.destinationView,
                               tag: viewModel,
                               selection: $resultToShow) { EmptyView() }
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
                        title: Text("Relevant songs"),
                        message: Text(NSLocalizedString("Change to a relevant hymn",
                                                        comment: "Message for the relevant songs action sheet")),
                        buttons: viewModels.map({ viewModel -> Alert.Button in
                            .default(Text(viewModel.title), action: {
                                self.resultToShow = viewModel
                            })
                        }) + [.cancel()])
            case .overflow(let buttons):
                return
                    ActionSheet(
                        title: Text(NSLocalizedString("Additional options",
                                                      comment: "Title for the overflow menu action sheet")),
                        buttons: buttons.map({ button -> Alert.Button in
                            .default(Text(button.label), action: {
                                self.performAction(button: button)
                            })
                        }) + [.cancel()])
            }
        }.fullScreenCover(item: $sheet) { tab -> AnyView in
            switch tab {
            case .share(let lyrics):
                return ShareSheet(activityItems: [lyrics]).eraseToAnyView()
            case .tags:
                return TagSheetView(viewModel: TagSheetViewModel(hymnToDisplay: self.viewModel.identifier), sheet: self.$sheet).eraseToAnyView()
            }
        }.background(Color(.systemBackground))
    }

    private func performAction(button: BottomBarButton) {
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
            self.dialogModel = DialogViewModel(contentBuilder: {
                SongInfoDialogView(viewModel: songInfoDialogViewModel).eraseToAnyView()
            }, options: DialogOptions(transition: .opacity))
        case .soundCloud(let viewModel):
            self.dialogModel = DialogViewModel(contentBuilder: {
                SoundCloudView(dialogModel: self.$dialogModel,
                               soundCloudPlayer: self.$soundCloudPlayer,
                               viewModel: viewModel)
                    .eraseToAnyView()
            }, options: DialogOptions(dimBackground: false, transition: .move(edge: .bottom)))
        case .youTube(let url):
            self.application.open(url)
        }
    }
}

private enum ActionSheetItem {
    case fontSize
    case languages([SongResultViewModel])
    case relevant([SongResultViewModel])
    case overflow([BottomBarButton])
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
        case .overflow:
            return 3
        }
    }
}

enum DisplayHymnSheet {
    case share(String)
    case tags
}

extension DisplayHymnSheet: Identifiable {
    var id: Int {
        switch self {
        case .share:
            return 0
        case .tags:
            return 1
        }
    }
}

#if DEBUG
struct DisplayHymnBottomBar_Previews: PreviewProvider {
    static var previews: some View {
        var dialogModel: DialogViewModel<AnyView>?

        let noButtonsViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        let noButtons = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {dialogModel},
            set: {dialogModel = $0}), viewModel: noButtonsViewModel)

        let oneButtonViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        oneButtonViewModel.buttons = [.tags]
        let oneButton = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {dialogModel},
            set: {dialogModel = $0}), viewModel: oneButtonViewModel)

        let twoButtonsViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        twoButtonsViewModel.buttons = [.tags, .fontSize]
        let twoButtons = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {dialogModel},
            set: {dialogModel = $0}), viewModel: twoButtonsViewModel)

        let maximumViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        maximumViewModel.buttons = [
            .soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search?q=query")!)),
            .youTube(URL(string: "https://www.youtube.com/results?search_query=search")!),
            .languages([SongResultViewModel(title: "language", destinationView: EmptyView().eraseToAnyView())]),
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)),
            .relevant([SongResultViewModel(title: "relevant", destinationView: EmptyView().eraseToAnyView())]),
            .songInfo(SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151))
        ]
        let maximum = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {dialogModel},
            set: {dialogModel = $0}), viewModel: maximumViewModel)

        let overflowViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        overflowViewModel.buttons = [
            .share("lyrics"),
            .fontSize,
            .languages([SongResultViewModel(title: "language", destinationView: EmptyView().eraseToAnyView())]),
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)),
            .relevant([SongResultViewModel(title: "relevant", destinationView: EmptyView().eraseToAnyView())]),
            .tags
        ]
        overflowViewModel.overflowButtons = [
            .soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search?q=query")!)),
            .youTube(URL(string: "https://www.youtube.com/results?search_query=search")!),
            .songInfo(SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151))
        ]
        let overflow = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {dialogModel},
            set: {dialogModel = $0}), viewModel: overflowViewModel)

        return Group {
            noButtons.previewDisplayName("0 buttons").previewLayout(.sizeThatFits)
            oneButton.previewDisplayName("one button").previewLayout(.sizeThatFits)
            twoButtons.previewDisplayName("two buttons").previewLayout(.fixed(width: 120, height: 50))
            maximum.previewDisplayName("maximum number of buttons").previewLayout(.sizeThatFits)
            overflow.previewDisplayName("overflow menu").previewLayout(.fixed(width: 600, height: 50))
        }
    }
}
#endif

import Prefire
import Resolver
import SwiftUI

struct DisplayHymnBottomBar: View {

    @Binding var dialogModel: DialogViewModel<AnyView>?
    @State private var actionSheet: ActionSheetItem?
    @State private var sheet: DisplayHymnSheet?

    @State var audioPlayer: AudioPlayerViewModel?
    @State var soundCloudPlayer: SoundCloudPlayerViewModel?
    @State var fontPicker: FontPickerViewModel?

    @ObservedObject var coordinator: NavigationCoordinator = Resolver.resolve()
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

            fontPicker.map { fontPicker in
                FontPicker(viewModel: fontPicker).padding()
            }

            HStack(spacing: 0) {
                ForEach(viewModel.buttons, id: \.self) { button in
                    Spacer()
                    Button<AnyView>(action: {
                        self.performAction(button: button)
                    }, label: {
                        switch button {
                        case .fontSize:
                            return self.fontPicker == nil ?
                            button.unselectedLabel.eraseToAnyView() :
                            button.selectedLabel.eraseToAnyView()
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
                                       a11yLabel: NSLocalizedString("More options", comment: "Bottom bar overflow button."))
                        .foregroundColor(.primary)
                    })
                }
            }
        }.actionSheet(item: $actionSheet) { item -> ActionSheet in
            switch item {
            case .languages(let viewModels):
                return ActionSheet(
                    title: Text("Languages", comment: "Title for the languages action sheet."),
                    message: Text("Change to another language", comment: "Message for the languages action sheet."),
                    buttons: viewModels.map({ viewModel -> Alert.Button in
                            .default(Text(viewModel.title), action: {
                                coordinator.showSongResult(.single(viewModel))
                            })
                    }) + [.cancel()])
            case .relevant(let viewModels):
                return ActionSheet(
                    title: Text("Relevant songs", comment: "Title for the relevant songs action sheet."),
                    message: Text("Change to a relevant hymn", comment: "Message for the relevant songs action sheet."),
                    buttons: viewModels.map({ viewModel -> Alert.Button in
                            .default(Text(viewModel.title), action: {
                                coordinator.showSongResult(.single(viewModel))
                            })
                    }) + [.cancel()])
            case .overflow(let buttons):
                return ActionSheet(
                    title: Text("Additional options", comment: "Title for the overflow menu action sheet."),
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

    // swiftlint:disable:next cyclomatic_complexity
    private func performAction(button: BottomBarButton) {
        switch button {
        case .share(let lyrics):
            self.sheet = .share(lyrics)
        case .fontSize(let fontPicker):
            if self.fontPicker == nil {
                self.fontPicker = fontPicker
            } else {
                self.fontPicker = nil
            }
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
    case languages([SingleSongResultViewModel])
    case relevant([SingleSongResultViewModel])
    case overflow([BottomBarButton])
}

extension ActionSheetItem: Identifiable {
    var id: Int {
        switch self {
        case .languages:
            return 0
        case .relevant:
            return 1
        case .overflow:
            return 2
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
struct DisplayHymnBottomBar_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        var dialogModel: DialogViewModel<AnyView>?
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"),
                                  title: "temp", lyrics: [VerseEntity]())

        let noButtonsViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151, hymn: hymn)
        noButtonsViewModel.buttons = []
        let noButtons = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {dialogModel},
            set: {dialogModel = $0}), viewModel: noButtonsViewModel)

        let oneButtonViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151, hymn: hymn)
        oneButtonViewModel.buttons = [.tags]
        let oneButton = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {dialogModel},
            set: {dialogModel = $0}), viewModel: oneButtonViewModel)

        let twoButtonsViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151, hymn: hymn)
        twoButtonsViewModel.buttons = [.tags, .fontSize(FontPickerViewModel())]
        let twoButtons = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {dialogModel},
            set: {dialogModel = $0}), viewModel: twoButtonsViewModel)

        let maximumViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151, hymn: hymn)
        maximumViewModel.buttons = [
            .soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search?q=query")!)),
            .youTube(URL(string: "https://www.youtube.com/results?search_query=search")!),
            .languages([SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .liedboek, hymnNumber: "1"),
                                                  title: "language",
                                                  destinationView: EmptyView().eraseToAnyView())]),
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)),
            .relevant([SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .liedboek, hymnNumber: "3"),
                                                 title: "relevant",
                                                 destinationView: EmptyView().eraseToAnyView())]),
            .songInfo(SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151,
                                              hymn: UiHymn(hymnIdentifier: PreviewHymnIdentifiers.hymn1151,
                                                           title: "", lyrics: nil, author: "MC"))!)
        ]
        let maximum = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {dialogModel},
            set: {dialogModel = $0}), viewModel: maximumViewModel)

        let overflowViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151, hymn: hymn)
        overflowViewModel.buttons = [
            .share("lyrics"),
            .fontSize(FontPickerViewModel()),
            .languages([SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .liedboek, hymnNumber: "1"),
                                                  title: "language", destinationView: EmptyView().eraseToAnyView())]),
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)),
            .relevant([SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .liedboek, hymnNumber: "3"),
                                                 title: "relevant",
                                                 destinationView: EmptyView().eraseToAnyView())])
        ]
        overflowViewModel.overflowButtons = [
            .tags,
            .soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search?q=query")!)),
            .youTube(URL(string: "https://www.youtube.com/results?search_query=search")!),
            .songInfo(SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151,
                                              hymn: UiHymn(hymnIdentifier: PreviewHymnIdentifiers.hymn1151,
                                                           title: "", lyrics: nil, author: "MC"))!)
        ]
        let overflow = DisplayHymnBottomBar(dialogModel: Binding<DialogViewModel<AnyView>?>(
            get: {dialogModel},
            set: {dialogModel = $0}), viewModel: overflowViewModel)

        return Group {
            noButtons.previewDisplayName("0 buttons")
            oneButton.previewDisplayName("one button")
            twoButtons.previewDisplayName("two buttons")
            maximum.previewDisplayName("maximum number of buttons")
            overflow.previewDisplayName("overflow menu")
        }.previewLayout(.sizeThatFits)
    }
}
#endif

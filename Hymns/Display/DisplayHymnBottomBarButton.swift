import Resolver
import SwiftUI

enum BottomBarButton {
    case share(String)
    case fontSize(FontPickerViewModel)
    case languages([SongResultViewModel])
    case musicPlayback(AudioPlayerViewModel)
    case relevant([SongResultViewModel])
    case tags
    case songInfo(SongInfoDialogViewModel)
    case soundCloud(SoundCloudViewModel)
    case youTube(URL)
}

extension BottomBarButton {

    var label: String {
        switch self {
        case .share:
            return NSLocalizedString("Share lyrics", comment: "Label for sharing lyrics externally to another app.")
        case .fontSize:
            return NSLocalizedString("Change lyrics font size", comment: "Label for changing the lyrics font size.")
        case .languages:
            return NSLocalizedString("Show languages", comment: "Label for showing different languages for this song.")
        case .musicPlayback:
            return NSLocalizedString("Play music", comment: "Label for playing the tune of the song.")
        case .relevant:
            return NSLocalizedString("Relevant songs", comment: "Label for going to relevant song (alternate tunes, etc).")
        case .tags:
            return NSLocalizedString("Tags", comment: "Label for going to the tags of this song.")
        case .songInfo:
            return NSLocalizedString("Song Info", comment: "Label for seeing more information about this song.")
        case .soundCloud:
            return NSLocalizedString("Search in SoundCloud", comment: "Label for searching this song on SoundCloud.")
        case .youTube:
            return NSLocalizedString("Search in YouTube", comment: "Label for searching this song on YouTube.")
        }
    }

    var selectedLabel: some View {
        switch self {
        case .share:
            return BottomBarLabel(image: Image(systemName: "square.and.arrow.up"), a11yLabel: label).foregroundColor(.primary)
        case .fontSize:
            return BottomBarLabel(image: Image(systemName: "textformat.size"), a11yLabel: label).foregroundColor(.accentColor)
        case .languages:
            return BottomBarLabel(image: Image(systemName: "globe"), a11yLabel: label).foregroundColor(.primary)
        case .musicPlayback:
            return BottomBarLabel(image: Image(systemName: "play.fill"), a11yLabel: label).foregroundColor(.accentColor)
        case .relevant:
            return BottomBarLabel(image: Image(systemName: "music.note.list"), a11yLabel: label).foregroundColor(.primary)
        case .tags:
            return BottomBarLabel(image: Image(systemName: "tag"), a11yLabel: label).foregroundColor(.primary)
        case .songInfo:
            return BottomBarLabel(image: Image(systemName: "info.circle"), a11yLabel: label).foregroundColor(.primary)
        case .soundCloud:
            return BottomBarLabel(image: Image("soundcloud"), a11yLabel: label).foregroundColor(.primary)
        case .youTube:
            return BottomBarLabel(image: Image("youtube"), a11yLabel: label).foregroundColor(.primary)
        }
    }

    var unselectedLabel: some View {
        switch self {
        case .share:
            return BottomBarLabel(image: Image(systemName: "square.and.arrow.up"), a11yLabel: label).foregroundColor(.primary)
        case .fontSize:
            return BottomBarLabel(image: Image(systemName: "textformat.size"), a11yLabel: label).foregroundColor(.primary)
        case .languages:
            return BottomBarLabel(image: Image(systemName: "globe"), a11yLabel: label).foregroundColor(.primary)
        case .musicPlayback:
            return BottomBarLabel(image: Image(systemName: "play"), a11yLabel: label).foregroundColor(.primary)
        case .relevant:
            return BottomBarLabel(image: Image(systemName: "music.note.list"), a11yLabel: label).foregroundColor(.primary)
        case .tags:
            return BottomBarLabel(image: Image(systemName: "tag"), a11yLabel: label).foregroundColor(.primary)
        case .songInfo:
            return BottomBarLabel(image: Image(systemName: "info.circle"), a11yLabel: label).foregroundColor(.primary)
        case .soundCloud:
            return BottomBarLabel(image: Image("soundcloud"), a11yLabel: label).foregroundColor(.primary)
        case .youTube:
            return BottomBarLabel(image: Image("youtube"), a11yLabel: label).foregroundColor(.primary)
        }
    }
}

extension BottomBarButton: Identifiable {
    var id: String { self.label }
}

extension BottomBarButton: Hashable {
    static func == (lhs: BottomBarButton, rhs: BottomBarButton) -> Bool {
        switch (lhs, rhs) {
        case (.share(let lyrics1), .share(let lyrics2)):
            return lyrics1 == lyrics2
        case (.fontSize, .fontSize):
            return true
        case (.languages(let viewModels1), .languages(let viewModels2)):
            return viewModels1 == viewModels2
        case (.musicPlayback, .musicPlayback):
            return true
        case (.relevant(let viewModels1), .relevant(let viewModels2)):
            return viewModels1 == viewModels2
        case (.tags, .tags):
            return true
        case (.songInfo(let viewModel1), .songInfo(let viewModel2)):
            return viewModel1.songInfo.count == viewModel2.songInfo.count
        case (.soundCloud(let viewModel1), .soundCloud(let viewModel2)):
            return viewModel1.url == viewModel2.url
        case (.youTube(let url1), .youTube(let url2)):
            return url1 == url2
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .share(let lyrics):
            hasher.combine("share")
            hasher.combine(lyrics)
        case .fontSize:
            hasher.combine("font size")
        case .languages(let viewModels):
            hasher.combine("languages")
            hasher.combine(viewModels)
        case .musicPlayback(let viewModel):
            hasher.combine("music playback")
            hasher.combine(viewModel)
        case .relevant(let viewModels):
            hasher.combine("relevant")
            hasher.combine(viewModels)
        case .tags:
            hasher.combine("tags")
        case .songInfo(let viewModel):
            hasher.combine("song info")
            hasher.combine(viewModel)
        case .soundCloud(let viewModel):
            hasher.combine("soundcloud")
            hasher.combine(viewModel)
        case .youTube(let url):
            hasher.combine("youtube")
            hasher.combine(url)
        }
    }
}

struct BottomBarLabel: View {

    let image: Image
    let a11yLabel: String

    var body: some View {
        image.accessibility(label: Text(a11yLabel)).font(.system(size: smallButtonSize)).padding()
    }
}

#if DEBUG
struct BottomBarLabel_Previews: PreviewProvider {
    static var previews: some View {
        let fontSize = BottomBarButton.fontSize(FontPickerViewModel())
        let soundCloud = BottomBarButton.soundCloud(SoundCloudViewModel(url: URL(string: "http://www.soundcloud.com")!))
        let youtube = BottomBarButton.youTube(URL(string: "http://www.youtube.com")!)
        Group {
            fontSize.selectedLabel.previewDisplayName("fontSize selected")
            soundCloud.selectedLabel.previewDisplayName("soundcloud selected")
            youtube.selectedLabel.previewDisplayName("youtube selected")

            fontSize.unselectedLabel.previewDisplayName("fontSize unselectedLabel")
            soundCloud.unselectedLabel.previewDisplayName("soundcloud unselectedLabel")
            youtube.unselectedLabel.previewDisplayName("youtube unselectedLabel")
        }.previewLayout(.sizeThatFits)
    }
}
#endif

import Foundation
import Resolver
import SwiftUI

#if DEBUG
struct PreviewSongResults {
    static let hymn1151 = SingleSongResultViewModel(
        stableId: "Hymn 1151",
        title: "Hymn 1151",
        destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)).eraseToAnyView())
    static let joyUnspeakable = SingleSongResultViewModel(
        stableId: "Joy Unspekable",
        title: "Joy Unspekable",
        destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: PreviewHymnIdentifiers.joyUnspeakable)).eraseToAnyView())
    static let cupOfChrist = SingleSongResultViewModel(
        stableId: "Cup of Christ",
        title: "Cup of Christ",
        destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: PreviewHymnIdentifiers.cupOfChrist)).eraseToAnyView())
    static let hymn480 = SingleSongResultViewModel(
        stableId: "Hymn 480",
        title: "Hymn 480",
        destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn480)).eraseToAnyView())
    static let sinfulPast = SingleSongResultViewModel(
        stableId: "What about my sinful past?",
        title: "What about my sinful past?",
        destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: PreviewHymnIdentifiers.sinfulPast)).eraseToAnyView())
    static let hymn1334 = SingleSongResultViewModel(
        stableId: "Hymn 1334",
        title: "Hymn 1334",
        destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1334)).eraseToAnyView())
    static let drinkARiver = MultiSongResultViewModel(
        stableId: "Hymn 1151|Be Filled 37",
        title: "Drink! A river pure and clear",
        labels: ["Hymn 1151", "Be Filled 37"],
        destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1334)).eraseToAnyView())
    static let sinfulPastMulti = MultiSongResultViewModel(
        stableId: "What about my sinful past?",
        title: "What about my sinful past?",
        labels: ["Howard Higashi (LB) 76"],
        destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: PreviewHymnIdentifiers.sinfulPast)).eraseToAnyView())
    static let hymn1334Multi = MultiSongResultViewModel(
        stableId: "Hymn 1334",
        title: "Hymn 1334",
        destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1334)).eraseToAnyView())
}
#endif

@testable import Hymns

// swiftlint:disable all
class SongResults{}

let hymn1151_songResult = SingleSongResultViewModel(stableId: "Hymn 1151",
                                                    title: "Hymn 1151",
                                                    destinationView:
                                                        DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: hymn1151_identifier)).eraseToAnyView())
let joyUnspeakable_songResult = SingleSongResultViewModel(stableId: "Joy Unspekable",
                                                          title: "Joy Unspekable",
                                                          destinationView:
                                                            DisplayHymnContainerView(
                                                                viewModel: DisplayHymnContainerViewModel(hymnToDisplay: joyUnspeakable_identifier)).eraseToAnyView())
let cupOfChrist_songResult = SingleSongResultViewModel(stableId: "Cup of Christ",
                                                       title: "Cup of Christ",
                                                       label: "New song 115",
                                                       destinationView:
                                                        DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: cupOfChrist_identifier)).eraseToAnyView())
let hymn480_songResult = SingleSongResultViewModel(stableId: "Hymn 480",
                                                   title: "Joined unto Christ the Conqueror",
                                                   label: "Hymn 480",
                                                   destinationView:
                                                    DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: hymn480_identifier)).eraseToAnyView())
let sinfulPast_songResult = SingleSongResultViewModel(stableId: "What about my sinful past?",
                                                      title: "What about my sinful past?",
                                                      destinationView:
                                                        DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: sinfulPast_identifier)).eraseToAnyView())
let hymn1334_songResult = SingleSongResultViewModel(stableId: "Hymn 1334",
                                                    title: "Thou hast turned my mourning into dancing for me",
                                                    destinationView:
                                                        DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: hymn1334_identifier)).eraseToAnyView())

let drinARiver_songResult = MultiSongResultViewModel(stableId: "h1151|bf37",
                                                     title: "Drink! A river pure and clear",
                                                     labels: ["Hymn 1151", "Be Filled 7"],
                                                     destinationView:
                                                        DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: hymn1151_identifier)).eraseToAnyView())

let sinfulPast_multiSongResult = MultiSongResultViewModel(stableId: "What about my sinful past?",
                                                          title: "What about my sinful past?",
                                                          labels: ["Howard Higashi (LB) 76"],
                                                          destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: PreviewHymnIdentifiers.sinfulPast)).eraseToAnyView())

let hymn1334_multiSongResult = MultiSongResultViewModel(stableId: "Hymn 1334",
                                                        title: "Hymn 1334",
                                                        destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1334)).eraseToAnyView())
// swiftlint:enable all

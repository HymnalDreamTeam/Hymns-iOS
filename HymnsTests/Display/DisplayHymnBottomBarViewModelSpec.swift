import Combine
import Mockingbird
import Nimble
import Quick
import SwiftUI
@testable import Hymns

// swiftlint:disable:next type_name type_body_length
class DisplayHymnBottomBarViewModelSpec: QuickSpec {

    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("DisplayHymnBottomBarViewModel") {
            let hymnIdentifier = HymnIdentifier(hymnType: .classic, hymnNumber: "23")
            let lyrics = [VerseEntity(verseType: .verse, lineStrings: ["verse 1 line 1", "verse 1 line 2"]),
                          VerseEntity(verseType: .chorus, lineStrings: ["chorus line 1", "chorus line 2"]),
                          VerseEntity(verseType: .verse, lineStrings: ["verse 2 line 1", "verse 2 line 2"]),
                          VerseEntity(verseType: .verse, lineStrings: ["verse 3 line 1", "verse 3 line 2"])]
            let pdfSheet = ["Guitar": "https://www.hymnal.net/Hymns/Hymnal/svg/e1151_g.svg"]
            let languages = [HymnIdentifier(hymnType: .tagalog, hymnNumber: "1151"),
                             HymnIdentifier(hymnType: .chineseSupplementSimplified, hymnNumber: "216")]
            let music = ["mp3": "/en/hymn/h/1151/f=mp3"]
            let relevant = [HymnIdentifier(hymnType: .newTune, hymnNumber: "1151"),
                            HymnIdentifier(hymnType: .newSong, hymnNumber: "216")]
            let populatedHymn = UiHymn(hymnIdentifier: hymnIdentifier,
                                       title: "title", lyrics: lyrics, pdfSheet: pdfSheet,
                                       category: "Experience of Christ", subcategory: "As Food and Drink",
                                       languages: languages, music: music, relevant: relevant)
            var systemUtil: SystemUtilMock!
            var target: DisplayHymnBottomBarViewModel!
            beforeEach {
                systemUtil = mock(SystemUtil.self)
            }
            context("no network available") {
                beforeEach {
                    given(systemUtil.isNetworkAvailable()) ~> false
                }
                describe("removes German language if both German and Liederbuch are present") {
                    beforeEach {
                        given(systemUtil.isSmallScreen()) ~> false
                    }
                    context("only German language") {
                        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "title",
                                                  languages: [HymnIdentifier(hymnType: .german, hymnNumber: "2")])
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn, systemUtil: systemUtil)
                        }
                        it("should show the German song result") {
                            expect(target.buttons).to(haveCount(3))
                            expect(target.buttons[1]).to(equal(.languages([SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .german, hymnNumber: "2"),
                                                                                                     title: "German 2",
                                                                                                     destinationView: EmptyView().eraseToAnyView())])))
                        }
                    }
                    context("only Liederbuch language") {
                        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "title",
                                                  languages: [HymnIdentifier(hymnType: .liederbuch, hymnNumber: "2") ])
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn, systemUtil: systemUtil)
                        }
                        it("should show the Liederbuch song result") {
                            expect(target.buttons).to(haveCount(3))
                            expect(target.buttons[1]).to(equal(.languages([SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .liederbuch, hymnNumber: "2"),
                                                                                                     title: "Liederbuch 2",
                                                                                                     destinationView: EmptyView().eraseToAnyView())])))
                        }
                    }
                    context("Liederbuch and German language") {
                        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "title",
                                                  languages: [HymnIdentifier(hymnType: .german, hymnNumber: "2"),
                                                              HymnIdentifier(hymnType: .liederbuch, hymnNumber: "20")])
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn, systemUtil: systemUtil)
                        }
                        it("should show only the Liederbuch song result") {
                            expect(target.buttons).to(haveCount(3))
                            expect(target.buttons[1]).to(equal(.languages([SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .liederbuch, hymnNumber: "20"),
                                                                                                     title: "Liederbuch 20",
                                                                                                     destinationView: EmptyView().eraseToAnyView())])))
                        }
                    }
                }
                context("regular screen") {
                    beforeEach {
                        given(systemUtil.isSmallScreen()) ~> false
                    }
                    context("with nil lyrics") {
                        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "title", lyrics: nil)
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn, systemUtil: systemUtil)
                        }
                        let count = 2
                        it("should have \(count) buttons in the buttons list and nothing in the overflow") {
                            expect(target.buttons).to(haveCount(count))
                            expect(target.buttons[0]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[1]).to(equal(.tags))
                            expect(target.overflowButtons).to(beNil())
                        }
                    }
                    context("with only lyrics") {
                        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"),
                                                  title: "title",
                                                  lyrics: [VerseEntity(verseType: .verse, lineStrings: ["verse 1 line 1", "verse 1 line 2"]),
                                                           VerseEntity(verseType: .chorus, lineStrings: ["chorus line 1", "chorus line 2"]),
                                                           VerseEntity(verseType: .verse, lineStrings: ["verse 2 line 1", "verse 2 line 2"]),
                                                           VerseEntity(verseType: .verse, lineStrings: ["verse 3 line 1", "verse 3 line 2"])])
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn, systemUtil: systemUtil)
                        }
                        let count = 3
                        it("should have \(count) buttons in the buttons list and nothing in the overflow") {
                            expect(target.buttons).to(haveCount(count))
                            expect(target.buttons[0]).to(equal(.share("verse 1 line 1\nverse 1 line 2\nchorus line 1\nchorus line 2\nverse 2 line 1\nverse 2 line 2\nverse 3 line 1\nverse 3 line 2")))
                            expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[2]).to(equal(.tags))
                            expect(target.overflowButtons).to(beNil())
                        }
                    }
                    context("with maximum number of buttons") {
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: populatedHymn, systemUtil: systemUtil)
                        }
                        let count = 6
                        it("should have \(count) buttons in the buttons list and nothing in the overflow") {
                            expect(target.buttons).to(haveCount(count))
                            expect(target.buttons[0]).to(equal(.share("verse 1 line 1\nverse 1 line 2\nchorus line 1\nchorus line 2\nverse 2 line 1\nverse 2 line 2\nverse 3 line 1\nverse 3 line 2")))
                            expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[2]).to(equal(.languages([
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .tagalog, hymnNumber: "1151"), title: "Tagalog 1151",
                                                          destinationView: EmptyView().eraseToAnyView()),
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .chineseSupplementSimplified, hymnNumber: "216"), title: "Chinese Supplement 216 (Simp.)",
                                                          destinationView: EmptyView().eraseToAnyView())])))
                            expect(target.buttons[3]).to(equal(.relevant([
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .newTune, hymnNumber: "1151"), title: "New tune 1151",
                                                          destinationView: EmptyView().eraseToAnyView()),
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .newSong, hymnNumber: "216"), title: "New song 216",
                                                          destinationView: EmptyView().eraseToAnyView())])))
                            expect(target.buttons[4]).to(equal(.tags))
                            expect(target.buttons[5]).to(equal(.songInfo(SongInfoDialogViewModel(hymnToDisplay: classic1151, hymn: populatedHymn)!)))
                            expect(target.overflowButtons).to(beNil())
                        }
                    }
                }
                context("small screen") {
                    beforeEach {
                        given(systemUtil.isSmallScreen()) ~> true
                    }
                    context("with maximum number of buttons") {
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: populatedHymn, systemUtil: systemUtil)
                        }
                        let count = 4
                        it("should have \(count) buttons in the buttons list and the rest in the overflow") {
                            expect(target.buttons).to(haveCount(count))
                            expect(target.buttons[0]).to(equal(.share("verse 1 line 1\nverse 1 line 2\nchorus line 1\nchorus line 2\nverse 2 line 1\nverse 2 line 2\nverse 3 line 1\nverse 3 line 2")))
                            expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[2]).to(equal(.languages([
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .tagalog, hymnNumber: "1151"), title: "Tagalog 1151",
                                                          destinationView: EmptyView().eraseToAnyView()),
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .chineseSupplementSimplified, hymnNumber: "216"),
                                                          title: "Chinese Supplement 216 (Simp.)", destinationView: EmptyView().eraseToAnyView())])))
                            expect(target.buttons[3]).to(equal(.relevant([
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .newTune, hymnNumber: "1151"), title: "New tune 1151",
                                                          destinationView: EmptyView().eraseToAnyView()),
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .newSong, hymnNumber: "216"), title: "New song 216",
                                                          destinationView: EmptyView().eraseToAnyView())])))
                            expect(target.overflowButtons).toNot(beNil())
                            expect(target.overflowButtons!).to(haveCount(2))
                            expect(target.overflowButtons![0]).to(equal(.tags))
                            expect(target.overflowButtons![1]).to(equal(.songInfo(SongInfoDialogViewModel(hymnToDisplay: classic1151, hymn: populatedHymn)!)))
                        }
                    }
                }
            }
            context("network available") {
                beforeEach {
                    given(systemUtil.isNetworkAvailable()) ~> true
                }
                context("regular screen") {
                    beforeEach {
                        given(systemUtil.isSmallScreen()) ~> false
                    }
                    context("with nil lyrics") {
                        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "title", lyrics: nil)
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn, systemUtil: systemUtil)
                        }
                        let count = 4
                        it("should have \(count) buttons in the buttons list and nothing in the overflow") {
                            expect(target.buttons).to(haveCount(count))
                            expect(target.buttons[0]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[1]).to(equal(.tags))
                            expect(target.buttons[2]).to(equal(.soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search/results?q=title")!))))
                            expect(target.buttons[3]).to(equal(.youTube(URL(string: "https://www.youtube.com/results?search_query=title")!)))
                            expect(target.overflowButtons).to(beNil())
                        }
                    }
                    context("with nil title") {
                        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"),
                                                  lyrics: [VerseEntity(verseType: .verse, lineStrings: ["verse 1 line 1", "verse 1 line 2"]),
                                                           VerseEntity(verseType: .chorus, lineStrings: ["chorus line 1", "chorus line 2"]),
                                                           VerseEntity(verseType: .verse, lineStrings: ["verse 2 line 1", "verse 2 line 2"]),
                                                           VerseEntity(verseType: .verse, lineStrings: ["verse 3 line 1", "verse 3 line 2"])])
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn, systemUtil: systemUtil)
                        }
                        let count = 3
                        it("should have \(count) buttons in the buttons list and nothing in the overflow") {
                            expect(target.buttons).to(haveCount(count))
                            expect(target.buttons[0]).to(equal(.share("verse 1 line 1\nverse 1 line 2\nchorus line 1\nchorus line 2\nverse 2 line 1\nverse 2 line 2\nverse 3 line 1\nverse 3 line 2")))
                            expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[2]).to(equal(.tags))
                            expect(target.overflowButtons).to(beNil())
                        }
                    }
                    context("with only lyrics") {
                        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"),
                                                  title: "title",
                                                  lyrics: [VerseEntity(verseType: .verse, lineStrings: ["verse 1 line 1", "verse 1 line 2"]),
                                                           VerseEntity(verseType: .chorus, lineStrings: ["chorus line 1", "chorus line 2"]),
                                                           VerseEntity(verseType: .verse, lineStrings: ["verse 2 line 1", "verse 2 line 2"]),
                                                           VerseEntity(verseType: .verse, lineStrings: ["verse 3 line 1", "verse 3 line 2"])])
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn, systemUtil: systemUtil)
                        }
                        let count = 5
                        it("should have \(count) buttons in the buttons list and nothing in the overflow") {
                            expect(target.buttons).to(haveCount(count))
                            expect(target.buttons[0]).to(equal(.share("verse 1 line 1\nverse 1 line 2\nchorus line 1\nchorus line 2\nverse 2 line 1\nverse 2 line 2\nverse 3 line 1\nverse 3 line 2")))
                            expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[2]).to(equal(.tags))
                            expect(target.buttons[3]).to(equal(.soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search/results?q=title")!))))
                            expect(target.buttons[4]).to(equal(.youTube(URL(string: "https://www.youtube.com/results?search_query=title")!)))
                            expect(target.overflowButtons).to(beNil())
                        }
                    }
                    context("with maximum number of buttons") {
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: populatedHymn, systemUtil: systemUtil)
                        }
                        let count = 5
                        it("should have \(count) buttons in the buttons list and the rest in the overflow") {
                            expect(target.buttons).to(haveCount(count))
                            expect(target.buttons[0]).to(equal(.share("verse 1 line 1\nverse 1 line 2\nchorus line 1\nchorus line 2\nverse 2 line 1\nverse 2 line 2\nverse 3 line 1\nverse 3 line 2")))
                            expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[2]).to(equal(.languages([
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .tagalog, hymnNumber: "1151"), title: "Tagalog 1151",
                                                          destinationView: EmptyView().eraseToAnyView()),
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .chineseSupplementSimplified, hymnNumber: "216"),
                                                          title: "Chinese Supplement 216 (Simp.)",
                                                          destinationView: EmptyView().eraseToAnyView())])))
                            expect(target.buttons[3]).to(equal(.musicPlayback(AudioPlayerViewModel(url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=mp3")!))))
                            expect(target.buttons[4]).to(equal(.relevant([
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .newTune, hymnNumber: "1151"), title: "New tune 1151",
                                                          destinationView: EmptyView().eraseToAnyView()),
                                SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .newSong, hymnNumber: "216"), title: "New song 216",
                                                          destinationView: EmptyView().eraseToAnyView())])))
                            expect(target.overflowButtons!).to(haveCount(4))
                            expect(target.overflowButtons![0]).to(equal(.tags))
                            expect(target.overflowButtons![1]).to(equal(.soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search/results?q=title")!))))
                            expect(target.overflowButtons![2]).to(equal(.youTube(URL(string: "https://www.youtube.com/results?search_query=title")!)))
                            expect(target.overflowButtons![3]).to(equal(.songInfo(SongInfoDialogViewModel(hymnToDisplay: classic1151, hymn: populatedHymn)!)))
                        }
                    }
                }
            }
        }
    }
}

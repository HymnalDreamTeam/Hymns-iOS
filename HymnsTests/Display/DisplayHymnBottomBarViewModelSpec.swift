import Combine
import Mockingbird
import Nimble
import Quick
import SwiftUI
@testable import Hymns

// swiftlint:disable:next type_name
class DisplayHymnBottomBarViewModelSpec: QuickSpec {

    override func spec() {
        describe("DisplayHymnBottomBarViewModel") {

            let hymnIdentifier = HymnIdentifier(hymnType: .classic, hymnNumber: "23")
            let lyrics = [Verse(verseType: .verse, verseContent: ["verse 1 line 1", "verse 1 line 2"]),
                          Verse(verseType: .chorus, verseContent: ["chorus line 1", "chorus line 2"]),
                          Verse(verseType: .verse, verseContent: ["verse 2 line 1", "verse 2 line 2"]),
                          Verse(verseType: .verse, verseContent: ["verse 3 line 1", "verse 3 line 2"])]
            let pdfSheet = MetaDatum(name: "sheet", data: [Datum(value: "Guitar", path: "https://www.hymnal.net/Hymns/Hymnal/svg/e1151_g.svg")])
            let languages = MetaDatum(name: "lang", data: [Datum(value: "Tagalog", path: "/en/hymn/ht/1151"),
                                                           Datum(value: "Missing path", path: ""),
                                                           Datum(value: "Invalid number", path: "/en/hymn/h/13f/f=333/asdf"),
                                                           Datum(value: "诗歌(简)", path: "/en/hymn/ts/216?gb=1")])
            let music = MetaDatum(name: "music", data: [Datum(value: "mp3", path: "/en/hymn/h/1151/f=mp3")])
            let relevant = MetaDatum(name: "relv", data: [Datum(value: "New Tune", path: "/en/hymn/nt/1151"),
                                                          Datum(value: "Missing path", path: ""),
                                                          Datum(value: "Invalid number", path: "/en/hymn/h/13f/f=333/asdf"),
                                                          Datum(value: "Cool other song", path: "/en/hymn/ns/216")])
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
                context("regular screen") {
                    beforeEach {
                        given(systemUtil.isSmallScreen()) ~> false
                    }
                    context("with nil lyrics") {
                        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "title", lyrics: nil)
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn, systemUtil: systemUtil)
                        }
                        it("should have 2 buttons in the buttons list and nothing in the overflow") {
                            expect(target.buttons).to(haveCount(2))
                            expect(target.buttons[0]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[1]).to(equal(.tags))
                            expect(target.overflowButtons).to(beNil())
                        }
                    }
                    context("with only lyrics") {
                        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"),
                                                  title: "title",
                                                  lyrics: [Verse(verseType: .verse, verseContent: ["verse 1 line 1", "verse 1 line 2"]),
                                                           Verse(verseType: .chorus, verseContent: ["chorus line 1", "chorus line 2"]),
                                                           Verse(verseType: .verse, verseContent: ["verse 2 line 1", "verse 2 line 2"]),
                                                           Verse(verseType: .verse, verseContent: ["verse 3 line 1", "verse 3 line 2"])])
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn, systemUtil: systemUtil)
                        }
                        it("should have 3 buttons in the buttons list and nothing in the overflow") {
                            expect(target.buttons).to(haveCount(3))
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
                        it("should have 6 buttons in the buttons list and nothing in the overflow") {
                            expect(target.buttons).to(haveCount(6))
                            expect(target.buttons[0]).to(equal(.share("verse 1 line 1\nverse 1 line 2\nchorus line 1\nchorus line 2\nverse 2 line 1\nverse 2 line 2\nverse 3 line 1\nverse 3 line 2")))
                            expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[2]).to(equal(.languages([
                                SongResultViewModel(stableId: "hymnType: ht, hymnNumber: 1151", title: "Tagalog",
                                                    destinationView: EmptyView().eraseToAnyView()),
                                SongResultViewModel(stableId: "hymnType: tsx, hymnNumber: 216", title: "诗歌(简)",
                                                    destinationView: EmptyView().eraseToAnyView())])))
                            expect(target.buttons[3]).to(equal(.relevant([
                                    SongResultViewModel(stableId: "hymnType: nt, hymnNumber: 1151", title: "New Tune",
                                                        destinationView: EmptyView().eraseToAnyView()),
                                    SongResultViewModel(stableId: "hymnType: ns, hymnNumber: 216", title: "Cool other song",
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
                        it("should have 4 buttons in the buttons list and the rest in the overflow") {
                            expect(target.buttons).to(haveCount(4))
                            expect(target.buttons[0]).to(equal(.share("verse 1 line 1\nverse 1 line 2\nchorus line 1\nchorus line 2\nverse 2 line 1\nverse 2 line 2\nverse 3 line 1\nverse 3 line 2")))
                            expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[2]).to(equal(.languages([
                                SongResultViewModel(stableId: "hymnType: ht, hymnNumber: 1151", title: "Tagalog",
                                                    destinationView: EmptyView().eraseToAnyView()),
                                SongResultViewModel(stableId: "hymnType: tsx, hymnNumber: 216", title: "诗歌(简)",
                                                    destinationView: EmptyView().eraseToAnyView())])))
                            expect(target.buttons[3]).to(equal(.relevant([
                                SongResultViewModel(stableId: "hymnType: nt, hymnNumber: 1151", title: "New Tune",
                                                    destinationView: EmptyView().eraseToAnyView()),
                                SongResultViewModel(stableId: "hymnType: ns, hymnNumber: 216", title: "Cool other song",
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
                        it("should have 4 buttons in the buttons list and nothing in the overflow") {
                            expect(target.buttons).to(haveCount(4))
                            expect(target.buttons[0]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[1]).to(equal(.tags))
                            expect(target.buttons[2]).to(equal(.soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search/results?q=title")!))))
                            expect(target.buttons[3]).to(equal(.youTube(URL(string: "https://www.youtube.com/results?search_query=title")!)))
                            expect(target.overflowButtons).to(beNil())
                        }
                    }
                    context("with only lyrics") {
                        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"),
                                                  title: "title",
                                                  lyrics: [Verse(verseType: .verse, verseContent: ["verse 1 line 1", "verse 1 line 2"]),
                                                           Verse(verseType: .chorus, verseContent: ["chorus line 1", "chorus line 2"]),
                                                           Verse(verseType: .verse, verseContent: ["verse 2 line 1", "verse 2 line 2"]),
                                                           Verse(verseType: .verse, verseContent: ["verse 3 line 1", "verse 3 line 2"])])
                        beforeEach {
                            target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn, systemUtil: systemUtil)
                        }
                        it("should have 3 buttons in the buttons list and nothing in the overflow") {
                            expect(target.buttons).to(haveCount(5))
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
                        it("should have 5 buttons in the buttons list and the rest in the overflow") {
                            expect(target.buttons).to(haveCount(5))
                            expect(target.buttons[0]).to(equal(.share("verse 1 line 1\nverse 1 line 2\nchorus line 1\nchorus line 2\nverse 2 line 1\nverse 2 line 2\nverse 3 line 1\nverse 3 line 2")))
                            expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                            expect(target.buttons[2]).to(equal(.languages([
                                SongResultViewModel(stableId: "hymnType: ht, hymnNumber: 1151", title: "Tagalog",
                                                    destinationView: EmptyView().eraseToAnyView()),
                                SongResultViewModel(stableId: "hymnType: tsx, hymnNumber: 216", title: "诗歌(简)",
                                                    destinationView: EmptyView().eraseToAnyView())])))
                            expect(target.buttons[3]).to(equal(.musicPlayback(AudioPlayerViewModel(url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=mp3")!))))
                            expect(target.buttons[4]).to(equal(.relevant([
                                    SongResultViewModel(stableId: "hymnType: nt, hymnNumber: 1151", title: "New Tune",
                                                        destinationView: EmptyView().eraseToAnyView()),
                                    SongResultViewModel(stableId: "hymnType: ns, hymnNumber: 216", title: "Cool other song",
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

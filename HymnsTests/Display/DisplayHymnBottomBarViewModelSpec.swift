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
            let testQueue = DispatchQueue(label: "test_queue")
            var hymnsRepository: HymnsRepositoryMock!
            var systemUtil: SystemUtilMock!
            var target: DisplayHymnBottomBarViewModel!

            beforeEach {
                hymnsRepository = mock(HymnsRepository.self)
                systemUtil = mock(SystemUtil.self)
                given(systemUtil.isSmallScreen()) ~> false
                target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymnsRepository: hymnsRepository,
                                                       mainQueue: testQueue, backgroundQueue: testQueue, systemUtil: systemUtil)
            }
            describe("init") {
                it("should only contain font size and tags") {
                    expect(target.buttons).to(beEmpty())
                    expect(target.overflowButtons).to(beNil())
                }
                it("should contain 6 tabs") {
                    expect(target.overflowThreshold).to(be(6))
                }
                context("small screen") {
                    beforeEach {
                        given(systemUtil.isSmallScreen()) ~> true
                        target = DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymnsRepository: hymnsRepository,
                                                               mainQueue: testQueue, backgroundQueue: testQueue, systemUtil: systemUtil)
                    }
                    it("should contain 5 tabs") {
                        expect(target.overflowThreshold).to(be(5))
                    }
                }
            }
            context("with nil repository result") {
                beforeEach {
                    given(hymnsRepository.getHymn(classic1151)) ~> { _ in
                        Just(nil).assertNoFailure().eraseToAnyPublisher()
                    }

                    target.fetchHymn()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should call hymnsRepository.getHymn") {
                    verify(hymnsRepository.getHymn(classic1151)).wasCalled(exactly(1))
                }
                it("should only contain font size and tags") {
                    expect(target.buttons).to(beEmpty())
                    expect(target.overflowButtons).to(beNil())
                }
            }
            context("with empty repository result") {
                beforeEach {
                    let emptyLyrics = UiHymn(hymnIdentifier: classic1151, title: "title", lyrics: [Verse]())
                    given(hymnsRepository.getHymn(classic1151)) ~> { _ in
                        Just(emptyLyrics).assertNoFailure().eraseToAnyPublisher()
                    }

                    target.fetchHymn()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should call hymnsRepository.getHymn") {
                    verify(hymnsRepository.getHymn(classic1151)).wasCalled(exactly(1))
                }
                it("should only contain font size and tags") {
                    expect(target.buttons).to(beEmpty())
                    expect(target.overflowButtons).to(beNil())
                }
            }
            context("with all options in repository result") {
                beforeEach {
                    let lyricsWithoutTransliteration = [
                        Verse(verseType: .verse, verseContent: ["Drink! a river pure and clear that's flowing from the throne;", "Eat! the tree of life with fruits abundant, richly grown"], transliteration: nil),
                        Verse(verseType: .chorus, verseContent: ["Do come, oh, do come,", "Says Spirit and the Bride:"], transliteration: nil)
                    ]
                    let languages = MetaDatum(name: "lang", data: [Datum(value: "Tagalog", path: "/en/hymn/ht/1151"),
                                                                   Datum(value: "Missing path", path: ""),
                                                                   Datum(value: "Invalid number", path: "/en/hymn/h/13f/f=333/asdf"),
                                                                   Datum(value: "诗歌(简)", path: "/en/hymn/ts/216?gb=1")])
                    let relevant = MetaDatum(name: "relv", data: [Datum(value: "New Tune", path: "/en/hymn/nt/1151"),
                                                                  Datum(value: "Missing path", path: ""),
                                                                  Datum(value: "Invalid number", path: "/en/hymn/h/13f/f=333/asdf"),
                                                                  Datum(value: "Cool other song", path: "/en/hymn/ns/216?gb=1")])
                    let music = MetaDatum(name: "music", data: [Datum(value: "mp3", path: "/en/hymn/h/1151/f=mp3")])
                    let hymn = UiHymn(hymnIdentifier: classic1151, title: "title", lyrics: lyricsWithoutTransliteration,
                                      category: "category", languages: languages, music: music, relevant: relevant)
                    given(hymnsRepository.getHymn(classic1151)) ~> { _ in
                        Just(hymn).assertNoFailure().eraseToAnyPublisher()
                    }
                    given(systemUtil.isNetworkAvailable()) ~> true

                    target.fetchHymn()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should call hymnsRepository.getHymn") {
                    verify(hymnsRepository.getHymn(classic1151)).wasCalled(exactly(1))
                }
                let mp3Url = URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=mp3")!
                it("should have 5 buttons in the buttons list and the rest in the overflow") {
                    expect(target.buttons).to(haveCount(5))
                    expect(target.buttons[0]).to(equal(.share("Drink! a river pure and clear that's flowing from the throne;\nEat! the tree of life with fruits abundant, richly grown\n\nDo come, oh, do come,\nSays Spirit and the Bride:\n\n")))
                    expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                    expect(target.buttons[2]).to(equal(.languages([
                        SongResultViewModel(title: "Tagalog", destinationView: EmptyView().eraseToAnyView()),
                        SongResultViewModel(title: "诗歌(简)", destinationView: EmptyView().eraseToAnyView())])))
                    expect(target.buttons[3]).to(equal(.musicPlayback(AudioPlayerViewModel(url: mp3Url))))
                    expect(target.buttons[4]).to(equal(.relevant([
                        SongResultViewModel(title: "New Tune", destinationView: EmptyView().eraseToAnyView()),
                        SongResultViewModel(title: "Cool other song", destinationView: EmptyView().eraseToAnyView())])))
                    expect(target.overflowButtons!).to(haveCount(4))
                    expect(target.overflowButtons![0]).to(equal(.tags))
                    expect(target.overflowButtons![1]).to(equal(.soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search/results?q=title")!))))
                    expect(target.overflowButtons![2]).to(equal(.youTube(URL(string: "https://www.youtube.com/results?search_query=title")!)))
                    expect(target.overflowButtons![3]).to(equal(.songInfo(SongInfoDialogViewModel(hymnToDisplay: classic1151))))
                }
                context("while network is unavailable") {
                    beforeEach {
                        given(systemUtil.isNetworkAvailable()) ~> false
                        target.fetchHymn()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should not contain the buttons that require network connectivity") {
                        expect(target.buttons).to(haveCount(6))
                        expect(target.buttons[0]).to(equal(.share("Drink! a river pure and clear that's flowing from the throne;\nEat! the tree of life with fruits abundant, richly grown\n\nDo come, oh, do come,\nSays Spirit and the Bride:\n\n")))
                        expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                        expect(target.buttons[2]).to(equal(.languages([
                            SongResultViewModel(title: "Tagalog", destinationView: EmptyView().eraseToAnyView()),
                            SongResultViewModel(title: "诗歌(简)", destinationView: EmptyView().eraseToAnyView())])))
                        expect(target.buttons[3]).to(equal(.relevant([
                            SongResultViewModel(title: "New Tune", destinationView: EmptyView().eraseToAnyView()),
                            SongResultViewModel(title: "Cool other song", destinationView: EmptyView().eraseToAnyView())])))
                        expect(target.buttons[4]).to(equal(.tags))
                        expect(target.buttons[5]).to(equal(.songInfo(SongInfoDialogViewModel(hymnToDisplay: classic1151))))
                        expect(target.overflowButtons).to(beNil())
                    }
                }
            }
            context("with the least number of options in repository result") {
                beforeEach {
                    let lyricsWithoutTransliteration = [
                        Verse(verseType: .verse, verseContent: ["Drink! a river pure and clear that's flowing from the throne;", "Eat! the tree of life with fruits abundant, richly grown"], transliteration: nil),
                        Verse(verseType: .chorus, verseContent: ["Do come, oh, do come,", "Says Spirit and the Bride:"], transliteration: nil)
                    ]
                    let hymn = UiHymn(hymnIdentifier: classic1151, title: "title", lyrics: lyricsWithoutTransliteration)
                    given(hymnsRepository.getHymn(classic1151)) ~> { _ in
                        Just(hymn).assertNoFailure().eraseToAnyPublisher()
                    }
                    given(systemUtil.isNetworkAvailable()) ~> true

                    target.fetchHymn()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should call hymnsRepository.getHymn") {
                    verify(hymnsRepository.getHymn(classic1151)).wasCalled(exactly(1))
                }
                it("should have all the buttons in the buttons list and nothing in the overflow") {
                    expect(target.buttons).to(haveCount(5))
                    expect(target.buttons[0]).to(equal(.share("Drink! a river pure and clear that's flowing from the throne;\nEat! the tree of life with fruits abundant, richly grown\n\nDo come, oh, do come,\nSays Spirit and the Bride:\n\n")))
                    expect(target.buttons[1]).to(equal(.fontSize(FontPickerViewModel())))
                    expect(target.buttons[2]).to(equal(.tags))
                    expect(target.buttons[3]).to(equal(.soundCloud(SoundCloudViewModel(url: URL(string: "https://soundcloud.com/search/results?q=title")!))))
                    expect(target.buttons[4]).to(equal(.youTube(URL(string: "https://www.youtube.com/results?search_query=title")!)))
                    expect(target.overflowButtons).to(beNil())
                }
            }
        }
    }
}

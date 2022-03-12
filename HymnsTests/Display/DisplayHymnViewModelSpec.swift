import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

// swiftlint:disable type_body_length function_body_length file_length
class DisplayHymnViewModelSpec: QuickSpec {

    override func spec() {
        describe("DisplayHymnViewModel") {
            let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "temp", lyrics: [Verse]())
            let testQueue = DispatchQueue(label: "test_queue")
            var hymnsRepository: HymnsRepositoryMock!
            var favoriteStore: FavoriteStoreMock!
            var historyStore: HistoryStoreMock!
            var pdfLoader: PDFLoaderMock!
            var systemUtil: SystemUtilMock!

            var target: DisplayHymnViewModel!
            beforeEach {
                hymnsRepository = mock(HymnsRepository.self)
                favoriteStore = mock(FavoriteStore.self)
                historyStore = mock(HistoryStore.self)
                pdfLoader = mock(PDFLoader.self)
                systemUtil = mock(SystemUtil.self)
            }
            describe("fetching hymn") {
                context("with nil repository results") {
                    beforeEach {
                        target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore, hymnToDisplay: classic1151, hymnsRepository: hymnsRepository, historyStore: historyStore, pdfPreloader: pdfLoader, systemUtil: systemUtil)
                        given(hymnsRepository.getHymn(classic1151)) ~> { _ in
                            Just(nil).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(hymnsRepository.getSongbase(bookId: 2, bookIndex: 1151)) ~> { _, _ in
                            Just(nil).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(systemUtil.isNetworkAvailable()) ~> true
                        target.fetchHymn()
                    }
                    it("title should be empty") {
                        expect(target.title).to(beEmpty())
                    }
                    it("should not perform any prefetching") {
                        verify(pdfLoader.load(url: any())).wasNeverCalled()
                    }
                    it("should have no tabs") {
                        expect(target.tabItems).to(beEmpty())
                    }
                    it("should have current tab as lyrics") {
                        expect(target.currentTab).to(equal(.lyrics(HymnNotExistsView().maxSize().eraseToAnyView())))
                    }
                    it("should not store any song into the history store") {
                        verify(historyStore.storeRecentSong(hymnToStore: any(), songTitle: any())).wasNeverCalled()
                    }
                    it("should call hymnsRepository.getHymn") {
                        verify(hymnsRepository.getHymn(classic1151)).wasCalled(exactly(1))
                    }
                    it("should call hymnsRepository.getSongbase") {
                        verify(hymnsRepository.getSongbase(bookId: 2, bookIndex: 1151)).wasCalled(exactly(1))
                    }
                }
                context("with valid repository results for data store only") {
                    beforeEach {
                        given(hymnsRepository.getSongbase(bookId: 2, bookIndex: 1151)) ~> { _, _ in
                            Just(nil).assertNoFailure().eraseToAnyPublisher()
                        }
                    }
                    context("for a classic hymn 1151 and store in recent songs") {
                        beforeEach {
                            target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore,
                                                          hymnToDisplay: classic1151, hymnsRepository: hymnsRepository,
                                                          historyStore: historyStore, mainQueue: testQueue,
                                                          pdfPreloader: pdfLoader, systemUtil: systemUtil, storeInHistoryStore: true)
                            let hymn = UiHymn(hymnIdentifier: classic1151, title: "title", lyrics: [Verse(verseType: .verse, verseContent: ["verse line"])],
                                              pdfSheet: Hymns.MetaDatum(name: "Lead Sheet",
                                                                        data: [Hymns.Datum(value: "Piano", path: "/en/hymn/c/1151/f=ppdf"),
                                                                               Hymns.Datum(value: "Guitar", path: "/en/hymn/c/1151/f=pdf"),
                                                                               Hymns.Datum(value: "Text", path: "/en/hymn/c/1151/f=gtpdf")]))
                            given(hymnsRepository.getHymn(classic1151)) ~> { _ in
                                Just(hymn).assertNoFailure().eraseToAnyPublisher()
                            }
                            given(systemUtil.isNetworkAvailable()) ~> true
                        }
                        let expectedTitle = "Hymn 1151"
                        context("is favorited") {
                            beforeEach {
                                given(favoriteStore.isFavorite(hymnIdentifier: classic1151)) ~> { _ in
                                    Just(true).mapError({ _ -> ErrorType in
                                        // This will never be triggered.
                                    }).eraseToAnyPublisher()
                                }

                                expect(target.isLoaded).to(beFalse())
                                target.fetchHymn()
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                            }
                            it("should be done loading") {
                                expect(target.isLoaded).to(beTrue())
                            }
                            it("title should be '\(expectedTitle)'") {
                                expect(target.title).to(equal(expectedTitle))
                            }
                            it("should store the song into the history store") {
                                verify(historyStore.storeRecentSong(hymnToStore: classic1151, songTitle: "title")).wasCalled(exactly(1))
                            }
                            it("should call hymnsRepository.getHymn") {
                                verify(hymnsRepository.getHymn(classic1151)).wasCalled(exactly(1))
                            }
                            it("should call hymnsRepository.getSongbase") {
                                verify(hymnsRepository.getSongbase(bookId: 2, bookIndex: 1151)).wasCalled(exactly(1))
                            }
                            it("should be favorited") {
                                expect(target.isFavorited).to(beTrue())
                            }
                            it("should call favoriteStore.isFavorite") {
                                verify(favoriteStore.isFavorite(hymnIdentifier: classic1151)).wasCalled(exactly(1))
                            }
                            let pianoUrl = URL(string: "http://www.hymnal.net/en/hymn/c/1151/f=ppdf")!
                            it("piano url should be prefetched") {
                                verify(pdfLoader.load(url: pianoUrl)).wasCalled(exactly(1))
                            }
                            let chordsUrl = URL(string: "http://www.hymnal.net/en/hymn/c/1151/f=gtpdf")!
                            it("chords url should be prefetched") {
                                verify(pdfLoader.load(url: chordsUrl)).wasCalled(exactly(1))
                            }
                            it("should have two tabs") {
                                expect(target.tabItems).to(haveCount(2))
                            }
                            it("first tab should be lyrics") {
                                expect(target.tabItems[0].id).to(equal("Lyrics"))
                            }
                            it("second tab should be music") {
                                expect(target.tabItems[1].id).to(equal("Music"))
                            }
                            it("should have a bottom bar") {
                                expect(target.bottomBar).to(equal(DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn)))
                            }
                        }
                        context("is not favorited") {
                            beforeEach {
                                given(favoriteStore.isFavorite(hymnIdentifier: classic1151)) ~> { _ in
                                    Just(false).mapError({ _ -> ErrorType in
                                        // This will never be triggered.
                                    }).eraseToAnyPublisher()
                                }
                                target.fetchHymn()
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                            }
                            it("should not be favorited") {
                                expect(target.isFavorited).to(beFalse())
                            }
                            it("should call favoriteStore.isFavorite") {
                                verify(favoriteStore.isFavorite(hymnIdentifier: classic1151)).wasCalled(exactly(1))
                            }
                        }
                        context("favorited throws error") {
                            beforeEach {
                                given(favoriteStore.isFavorite(hymnIdentifier: classic1151)) ~> { _ in
                                    Just(false).tryMap({ _ -> Bool in
                                        throw URLError(.badServerResponse)
                                    }).mapError({ _ -> ErrorType in
                                            .data(description: "Forced error")
                                    }).eraseToAnyPublisher()
                                }
                                target.fetchHymn()
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                            }
                            it("should not be favorited") {
                                expect(target.isFavorited).to(beNil())
                            }
                            it("should call favoriteStore.isFavorite") {
                                verify(favoriteStore.isFavorite(hymnIdentifier: classic1151)).wasCalled(exactly(1))
                            }
                        }
                    }
                    context("for new song 145") {
                        beforeEach {
                            target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore,
                                                          hymnToDisplay: newSong145, hymnsRepository: hymnsRepository,
                                                          historyStore: historyStore, mainQueue: testQueue,
                                                          pdfPreloader: pdfLoader, systemUtil: systemUtil)
                            given(systemUtil.isNetworkAvailable()) ~> true
                        }
                        context("hymn lacks lyrics but has sheet music") {
                            beforeEach {
                                let hymnWithHymnColonTitle = UiHymn(hymnIdentifier: newSong145, title: "In my spirit, I can see You as You are",
                                                                    lyrics: [Verse](),
                                                                    pdfSheet: Hymns.MetaDatum(name: "Lead Sheet",
                                                                                              data: [Hymns.Datum(value: "Piano", path: "/en/hymn/c/1151/f=ppdf"),
                                                                                                     Hymns.Datum(value: "Guitar", path: "/en/hymn/c/1151/f=pdf"),
                                                                                                     Hymns.Datum(value: "Text", path: "/en/hymn/c/1151/f=gtpdf")]))
                                given(hymnsRepository.getHymn(newSong145)) ~> { _ in
                                    Just(hymnWithHymnColonTitle).assertNoFailure().eraseToAnyPublisher()
                                }
                                given(favoriteStore.isFavorite(hymnIdentifier: newSong145)) ~> { _ in
                                    Just(false).mapError({ _ -> ErrorType in
                                        // This will never be triggered.
                                    }).eraseToAnyPublisher()
                                }

                                target.fetchHymn()
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                            }
                            it("should have one tabs") {
                                expect(target.tabItems).to(haveCount(1))
                            }
                            it("tab should be music") {
                                expect(target.tabItems[0].id).to(equal("Music"))
                            }
                        }
                        context("hymn contains sheet music") {
                            beforeEach {
                                let hymnWithHymnColonTitle = UiHymn(hymnIdentifier: newSong145, title: "In my spirit, I can see You as You are",
                                                                    lyrics: [Verse(verseType: .chorus, verseContent: ["chorus line"])],
                                                                    pdfSheet: Hymns.MetaDatum(name: "Lead Sheet",
                                                                                              data: [Hymns.Datum(value: "Piano", path: "/en/hymn/c/1151/f=ppdf"),
                                                                                                     Hymns.Datum(value: "Guitar", path: "/en/hymn/c/1151/f=pdf"),
                                                                                                     Hymns.Datum(value: "Text", path: "/en/hymn/c/1151/f=gtpdf")]))
                                given(hymnsRepository.getHymn(newSong145)) ~> { _ in
                                    Just(hymnWithHymnColonTitle).assertNoFailure().eraseToAnyPublisher()
                                }
                                given(favoriteStore.isFavorite(hymnIdentifier: newSong145)) ~> { _ in
                                    Just(false).mapError({ _ -> ErrorType in
                                        // This will never be triggered.
                                    }).eraseToAnyPublisher()
                                }

                                target.fetchHymn()
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                            }
                            it("title should be 'In my spirit, I can see You as You are'") {
                                expect(target.title).to(equal("In my spirit, I can see You as You are"))
                            }
                            it("should store the song into the history store") {
                                verify(historyStore.storeRecentSong(hymnToStore: any(), songTitle: any())).wasNeverCalled()
                            }
                            it("should call hymnsRepository.getHymn") {
                                verify(hymnsRepository.getHymn(newSong145)).wasCalled(exactly(1))
                            }
                            it("should not be favorited") {
                                expect(target.isFavorited).to(beFalse())
                            }
                            it("should call favoriteStore.isFavorite") {
                                verify(favoriteStore.isFavorite(hymnIdentifier: newSong145)).wasCalled(exactly(1))
                            }
                            let pianoUrl = URL(string: "http://www.hymnal.net/en/hymn/c/1151/f=ppdf")!
                            it("piano url should be prefetched") {
                                verify(pdfLoader.load(url: pianoUrl)).wasCalled(exactly(1))
                            }
                            let chordsUrl = URL(string: "http://www.hymnal.net/en/hymn/c/1151/f=gtpdf")!
                            it("chords url should be prefetched") {
                                verify(pdfLoader.load(url: chordsUrl)).wasCalled(exactly(1))
                            }
                            it("should have two tabs") {
                                expect(target.tabItems).to(haveCount(2))
                            }
                            it("first tab should be lyrics") {
                                expect(target.tabItems[0].id).to(equal("Lyrics"))
                            }
                            it("second tab should be music") {
                                expect(target.tabItems[1].id).to(equal("Music"))
                            }
                        }
                        context("hymn does not contain sheet music") {
                            beforeEach {
                                let hymnWithoutSheetMusic = UiHymn(hymnIdentifier: newSong145, title: "In my spirit, I can see You as You are",
                                                                   lyrics: [Verse(verseType: .verse, verseContent: ["verse content"])])
                                given(hymnsRepository.getHymn(newSong145)) ~> { _ in
                                    Just(hymnWithoutSheetMusic).assertNoFailure().eraseToAnyPublisher()
                                }
                                given(favoriteStore.isFavorite(hymnIdentifier: newSong145)) ~> { _ in
                                    Just(false).mapError({ _ -> ErrorType in
                                        // This will never be triggered.
                                    }).eraseToAnyPublisher()
                                }
                                target.fetchHymn()
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                            }
                            it("should have one tab") {
                                expect(target.tabItems).to(haveCount(1))
                            }
                            it("tab should be lyrics") {
                                expect(target.tabItems[0].id).to(equal("Lyrics"))
                            }
                        }
                        context("network unavailable") {
                            beforeEach {
                                let hymn = UiHymn(hymnIdentifier: newSong145, title: "title'",
                                                  lyrics: [Verse(verseType: .verse, verseContent: ["verse content"])],
                                                  pdfSheet: Hymns.MetaDatum(name: "Lead Sheet",
                                                                            data: [Hymns.Datum(value: "Piano", path: "/en/hymn/c/1151/f=ppdf"),
                                                                                   Hymns.Datum(value: "Guitar", path: "/en/hymn/c/1151/f=pdf"),
                                                                                   Hymns.Datum(value: "Text", path: "/en/hymn/c/1151/f=gtpdf")]))
                                given(systemUtil.isNetworkAvailable()) ~> false
                                given(hymnsRepository.getHymn(newSong145)) ~> { _ in
                                    Just(hymn).assertNoFailure().eraseToAnyPublisher()
                                }
                                given(favoriteStore.isFavorite(hymnIdentifier: newSong145)) ~> { _ in
                                    Just(false).mapError({ _ -> ErrorType in
                                        // This will never be triggered.
                                    }).eraseToAnyPublisher()
                                }

                                target.fetchHymn()
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                            }
                            it("should have one tab") {
                                expect(target.tabItems).to(haveCount(1))
                            }
                            it("tab should be lyrics") {
                                expect(target.tabItems[0].id).to(equal("Lyrics"))
                            }
                        }
                    }
                }
                context("with valid repository results for songbase only but chords weren't found") {
                    beforeEach {
                        target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore,
                                                      hymnToDisplay: songbase1, hymnsRepository: hymnsRepository,
                                                      historyStore: historyStore, mainQueue: testQueue,
                                                      pdfPreloader: pdfLoader, systemUtil: systemUtil, storeInHistoryStore: true)
                        let songbaseSong = SongbaseSong(bookId: 1, bookIndex: 1, title: "Songbase song", language: "english",
                                                        lyrics: "Songbase lyrics", chords: "Chords not found")
                        given(hymnsRepository.getHymn(songbase1)) ~> { _ in
                            Just(nil).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(hymnsRepository.getSongbase(bookId: 1, bookIndex: 1)) ~> { _, _ in
                            Just(songbaseSong).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(systemUtil.isNetworkAvailable()) ~> true
                    }
                    let expectedTitle = "Songbase 1"
                    context("is favorited") {
                        beforeEach {
                            given(favoriteStore.isFavorite(hymnIdentifier: songbase1)) ~> { _ in
                                Just(true).mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }

                            expect(target.isLoaded).to(beFalse())
                            target.fetchHymn()
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                        }
                        it("should be done loading") {
                            expect(target.isLoaded).to(beTrue())
                        }
                        it("title should be '\(expectedTitle)'") {
                            expect(target.title).to(equal(expectedTitle))
                        }
                        it("should store the song into the history store") {
                            verify(historyStore.storeRecentSong(hymnToStore: songbase1, songTitle: "Songbase song")).wasCalled(exactly(1))
                        }
                        it("should not call hymnsRepository.getHymn") {
                            verify(hymnsRepository.getHymn(any())).wasNeverCalled()
                        }
                        it("should call hymnsRepository.getSongbase") {
                            verify(hymnsRepository.getSongbase(bookId: 1, bookIndex: 1)).wasCalled(exactly(1))
                        }
                        it("should be favorited") {
                            expect(target.isFavorited).to(beTrue())
                        }
                        it("should call favoriteStore.isFavorite") {
                            verify(favoriteStore.isFavorite(hymnIdentifier: songbase1)).wasCalled(exactly(1))
                        }
                        it("no url should be prefetched") {
                            verify(pdfLoader.load(url: any())).wasNeverCalled()
                        }
                        it("should have one tabs") {
                            expect(target.tabItems).to(haveCount(1))
                        }
                        it("first tab should be lyrics") {
                            expect(target.tabItems[0].id).to(equal("Music"))
                        }
                        it("should have a bottom bar") {
                            expect(target.bottomBar).to(equal(DisplayHymnBottomBarViewModel(hymnToDisplay: songbase1, hymn: hymn)))
                        }
                    }
                }
                context("with valid repository results for songbase only and chords were found") {
                    beforeEach {
                        target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore,
                                                      hymnToDisplay: songbase1, hymnsRepository: hymnsRepository,
                                                      historyStore: historyStore, mainQueue: testQueue,
                                                      pdfPreloader: pdfLoader, systemUtil: systemUtil, storeInHistoryStore: true)
                        let songbaseSong = SongbaseSong(bookId: 1, bookIndex: 1, title: "Songbase song", language: "english",
                                                        lyrics: "Songbase lyrics", chords: "[G]Songbase chords")
                        given(hymnsRepository.getHymn(songbase1)) ~> { _ in
                            Just(nil).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(hymnsRepository.getSongbase(bookId: 1, bookIndex: 1)) ~> { _, _ in
                            Just(songbaseSong).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(systemUtil.isNetworkAvailable()) ~> true
                    }
                    let expectedTitle = "Songbase 1"
                    context("is favorited") {
                        beforeEach {
                            given(favoriteStore.isFavorite(hymnIdentifier: songbase1)) ~> { _ in
                                Just(true).mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }

                            expect(target.isLoaded).to(beFalse())
                            target.fetchHymn()
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                        }
                        it("should be done loading") {
                            expect(target.isLoaded).to(beTrue())
                        }
                        it("title should be '\(expectedTitle)'") {
                            expect(target.title).to(equal(expectedTitle))
                        }
                        it("should store the song into the history store") {
                            verify(historyStore.storeRecentSong(hymnToStore: songbase1, songTitle: "Songbase song")).wasCalled(exactly(1))
                        }
                        it("should not call hymnsRepository.getHymn") {
                            verify(hymnsRepository.getHymn(any())).wasNeverCalled()
                        }
                        it("should call hymnsRepository.getSongbase") {
                            verify(hymnsRepository.getSongbase(bookId: 1, bookIndex: 1)).wasCalled(exactly(1))
                        }
                        it("should be favorited") {
                            expect(target.isFavorited).to(beTrue())
                        }
                        it("should call favoriteStore.isFavorite") {
                            verify(favoriteStore.isFavorite(hymnIdentifier: songbase1)).wasCalled(exactly(1))
                        }
                        it("no url should be prefetched") {
                            verify(pdfLoader.load(url: any())).wasNeverCalled()
                        }
                        it("should have one tabs") {
                            expect(target.tabItems).to(haveCount(1))
                        }
                        it("first tab should be lyrics") {
                            expect(target.tabItems[0].id).to(equal("Music"))
                        }
                        it("should have a bottom bar") {
                            expect(target.bottomBar).to(equal(DisplayHymnBottomBarViewModel(hymnToDisplay: songbase1, hymn: hymn)))
                        }
                    }
                }
                context("with valid repository results from data store and songbase and chords were found") {
                    let expectedTitle = "Hymn 1151"
                    beforeEach {
                        target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore,
                                                      hymnToDisplay: classic1151, hymnsRepository: hymnsRepository,
                                                      historyStore: historyStore, mainQueue: testQueue,
                                                      pdfPreloader: pdfLoader, systemUtil: systemUtil, storeInHistoryStore: true)
                        let hymn = UiHymn(hymnIdentifier: classic1151, title: "title", lyrics: [Verse(verseType: .verse, verseContent: ["verse line"])],
                                          pdfSheet: Hymns.MetaDatum(name: "Lead Sheet",
                                                                    data: [Hymns.Datum(value: "Piano", path: "/en/hymn/c/1151/f=ppdf"),
                                                                           Hymns.Datum(value: "Guitar", path: "/en/hymn/c/1151/f=pdf"),
                                                                           Hymns.Datum(value: "Text", path: "/en/hymn/c/1151/f=gtpdf")]))
                        let songbaseSong = SongbaseSong(bookId: 2, bookIndex: 1151, title: "Songbase song", language: "english",
                                                        lyrics: "Songbase lyrics", chords: "[G]Songbase chords")
                        given(hymnsRepository.getHymn(classic1151)) ~> { _ in
                            Just(hymn).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(hymnsRepository.getSongbase(bookId: 2, bookIndex: 1151)) ~> { _, _ in
                            Just(songbaseSong).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(systemUtil.isNetworkAvailable()) ~> true

                        given(favoriteStore.isFavorite(hymnIdentifier: classic1151)) ~> { _ in
                            Just(true).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }

                        expect(target.isLoaded).to(beFalse())
                        target.fetchHymn()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should be done loading") {
                        expect(target.isLoaded).to(beTrue())
                    }
                    it("title should be '\(expectedTitle)'") {
                        expect(target.title).to(equal(expectedTitle))
                    }
                    it("should call hymnsRepository.getHymn") {
                        verify(hymnsRepository.getHymn(classic1151)).wasCalled(exactly(1))
                    }
                    it("should call hymnsRepository.getSongbase") {
                        verify(hymnsRepository.getSongbase(bookId: 2, bookIndex: 1151)).wasCalled(exactly(1))
                    }
                    let pianoUrl = URL(string: "http://www.hymnal.net/en/hymn/c/1151/f=ppdf")!
                    it("piano url should be prefetched") {
                        verify(pdfLoader.load(url: pianoUrl)).wasCalled(exactly(1))
                    }
                    let chordsUrl = URL(string: "http://www.hymnal.net/en/hymn/c/1151/f=gtpdf")!
                    it("chords url should not be prefetched") {
                        verify(pdfLoader.load(url: chordsUrl)).wasNeverCalled()
                    }
                    it("should have two tabs") {
                        expect(target.tabItems).to(haveCount(2))
                    }
                    it("first tab should be lyrics") {
                        expect(target.tabItems[0].id).to(equal("Lyrics"))
                    }
                    it("second tab should be music") {
                        expect(target.tabItems[1].id).to(equal("Music"))
                    }
                    it("should have a bottom bar") {
                        expect(target.bottomBar).to(equal(DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn)))
                    }
                }
                context("with valid repository results from data store and songbase but chords weren't found") {
                    let expectedTitle = "Hymn 1151"
                    beforeEach {
                        target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore,
                                                      hymnToDisplay: classic1151, hymnsRepository: hymnsRepository,
                                                      historyStore: historyStore, mainQueue: testQueue,
                                                      pdfPreloader: pdfLoader, systemUtil: systemUtil, storeInHistoryStore: true)
                        let hymn = UiHymn(hymnIdentifier: classic1151, title: "title", lyrics: [Verse(verseType: .verse, verseContent: ["verse line"])],
                                          pdfSheet: Hymns.MetaDatum(name: "Lead Sheet",
                                                                    data: [Hymns.Datum(value: "Piano", path: "/en/hymn/c/1151/f=ppdf"),
                                                                           Hymns.Datum(value: "Guitar", path: "/en/hymn/c/1151/f=pdf"),
                                                                           Hymns.Datum(value: "Text", path: "/en/hymn/c/1151/f=gtpdf")]))
                        let songbaseSong = SongbaseSong(bookId: 2, bookIndex: 1151, title: "Songbase song", language: "english",
                                                        lyrics: "Songbase lyrics", chords: "Chordsnot found")
                        given(hymnsRepository.getHymn(classic1151)) ~> { _ in
                            Just(hymn).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(hymnsRepository.getSongbase(bookId: 2, bookIndex: 1151)) ~> { _, _ in
                            Just(songbaseSong).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(systemUtil.isNetworkAvailable()) ~> true

                        given(favoriteStore.isFavorite(hymnIdentifier: classic1151)) ~> { _ in
                            Just(true).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }

                        expect(target.isLoaded).to(beFalse())
                        target.fetchHymn()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should be done loading") {
                        expect(target.isLoaded).to(beTrue())
                    }
                    it("title should be '\(expectedTitle)'") {
                        expect(target.title).to(equal(expectedTitle))
                    }
                    it("should call hymnsRepository.getHymn") {
                        verify(hymnsRepository.getHymn(classic1151)).wasCalled(exactly(1))
                    }
                    it("should call hymnsRepository.getSongbase") {
                        verify(hymnsRepository.getSongbase(bookId: 2, bookIndex: 1151)).wasCalled(exactly(1))
                    }
                    let pianoUrl = URL(string: "http://www.hymnal.net/en/hymn/c/1151/f=ppdf")!
                    it("piano url should be prefetched") {
                        verify(pdfLoader.load(url: pianoUrl)).wasCalled(exactly(1))
                    }
                    let chordsUrl = URL(string: "http://www.hymnal.net/en/hymn/c/1151/f=gtpdf")!
                    it("chords url should be prefetched") {
                        verify(pdfLoader.load(url: chordsUrl)).wasCalled(exactly(1))
                    }
                    it("should have two tabs") {
                        expect(target.tabItems).to(haveCount(2))
                    }
                    it("first tab should be lyrics") {
                        expect(target.tabItems[0].id).to(equal("Lyrics"))
                    }
                    it("second tab should be music") {
                        expect(target.tabItems[1].id).to(equal("Music"))
                    }
                    it("should have a bottom bar") {
                        expect(target.bottomBar).to(equal(DisplayHymnBottomBarViewModel(hymnToDisplay: classic1151, hymn: hymn)))
                    }
                }
            }
        }
    }
}

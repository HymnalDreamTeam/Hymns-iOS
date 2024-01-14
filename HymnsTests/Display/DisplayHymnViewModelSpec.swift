import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

// swiftlint:disable type_body_length function_body_length file_length
class DisplayHymnViewModelSpec: QuickSpec {

    override func spec() {
        describe("DisplayHymnViewModel") {
            let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "temp", lyrics: [VerseEntity]())
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
                }
                context("with valid repository results") {
                    context("for a classic hymn 1151 and store in recent songs") {
                        beforeEach {
                            target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore,
                                                          hymnToDisplay: classic1151, hymnsRepository: hymnsRepository,
                                                          historyStore: historyStore, mainQueue: testQueue,
                                                          pdfPreloader: pdfLoader, systemUtil: systemUtil, storeInHistoryStore: true)
                            let hymn = UiHymn(hymnIdentifier: classic1151, title: "title",
                                              lyrics: [VerseEntity(verseType: .verse, lineStrings: ["verse line"])],
                                              pdfSheet: ["Piano": "https://www.hymnal.net/Hymns/Hymnal/pdfs/e0226_p.pdf",
                                                         "Guitar": "https://www.hymnal.net/Hymns/Hymnal/pdfs/e0226_g.pdf",
                                                         "Text": "https://www.hymnal.net/Hymns/Hymnal/pdfs/e0226_gt.pdf"])
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
                            it("should be favorited") {
                                expect(target.isFavorited).to(beTrue())
                            }
                            it("should call favoriteStore.isFavorite") {
                                verify(favoriteStore.isFavorite(hymnIdentifier: classic1151)).wasCalled(exactly(1))
                            }
                            let pianoUrl = URL(string: "https://www.hymnal.net/Hymns/Hymnal/pdfs/e0226_p.pdf")!
                            it("piano url should be prefetched") {
                                verify(pdfLoader.load(url: pianoUrl)).wasCalled(exactly(1))
                            }
                            let chordsUrl = URL(string: "https://www.hymnal.net/Hymns/Hymnal/pdfs/e0226_gt.pdf")!
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
                                                                    lyrics: [VerseEntity](),
                                                                    pdfSheet: ["Piano": "/en/hymn/c/1151/f=ppdf",
                                                                               "Guitar": "/en/hymn/c/1151/f=pdf",
                                                                               "Text": "/en/hymn/c/1151/f=gtpdf"])
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
                            describe("fetch hymn again") {
                                beforeEach {
                                    target.fetchHymn()
                                    testQueue.sync {}
                                    testQueue.sync {}
                                    testQueue.sync {}
                                    testQueue.sync {}
                                }
                                it("should still just have one tabs") {
                                    expect(target.tabItems).to(haveCount(1))
                                }
                                it("tab should still be music") {
                                    expect(target.tabItems[0].id).to(equal("Music"))
                                }
                            }
                        }
                        context("hymn contains sheet music") {
                            beforeEach {
                                let hymnWithHymnColonTitle = UiHymn(hymnIdentifier: newSong145, title: "In my spirit, I can see You as You are",
                                                                    lyrics: [VerseEntity(verseType: .chorus, lineStrings: ["chorus line"])],
                                                                    pdfSheet: ["Piano": "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_p.pdf",
                                                                               "Guitar": "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_g.pdf",
                                                                               "Text": "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_gt.pdf"])
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
                            let pianoUrl = URL(string: "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_p.pdf")!
                            it("piano url should be prefetched") {
                                verify(pdfLoader.load(url: pianoUrl)).wasCalled(exactly(1))
                            }
                            let chordsUrl = URL(string: "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_gt.pdf")!
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
                                                                   lyrics: [VerseEntity(verseType: .verse, lineStrings: ["verse content"])])
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
                                                  lyrics: [VerseEntity(verseType: .verse, lineStrings: ["verse content"])],
                                                  pdfSheet: ["Piano": "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_p.pdf",
                                                             "Guitar": "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_g.pdf",
                                                             "Text": "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_gt.pdf"])
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
                context("with only inline chords") {
                    beforeEach {
                        target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore,
                                                      hymnToDisplay: songbase1, hymnsRepository: hymnsRepository,
                                                      historyStore: historyStore, mainQueue: testQueue,
                                                      pdfPreloader: pdfLoader, systemUtil: systemUtil, storeInHistoryStore: true)
                        let songbaseSong = UiHymn(hymnIdentifier: songbase1, title: "Songbase song",
                                                  inlineChords: [ChordLine("Chords not found")])
                        given(hymnsRepository.getHymn(songbase1)) ~> { _ in
                            Just(songbaseSong).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(systemUtil.isNetworkAvailable()) ~> true
                    }
                    let expectedTitle = "Songbase song"
                    context("is not favorited") {
                        beforeEach {
                            given(favoriteStore.isFavorite(hymnIdentifier: songbase1)) ~> { _ in
                                Just(false).mapError({ _ -> ErrorType in
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
                        it("should not hymnsRepository.getHymn") {
                            verify(hymnsRepository.getHymn(songbase1)).wasCalled(1)
                        }
                        it("should be favorited") {
                            expect(target.isFavorited).to(beFalse())
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
                        it("first tab should be music") {
                            expect(target.tabItems[0].id).to(equal("Music"))
                        }
                        it("should have a bottom bar") {
                            expect(target.bottomBar).to(equal(DisplayHymnBottomBarViewModel(hymnToDisplay: songbase1, hymn: hymn)))
                        }
                    }
                }
                context("with lyrics and inline chords") {
                    beforeEach {
                        target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore,
                                                      hymnToDisplay: songbase1, hymnsRepository: hymnsRepository,
                                                      historyStore: historyStore, mainQueue: testQueue,
                                                      pdfPreloader: pdfLoader, systemUtil: systemUtil, storeInHistoryStore: true)
                        let songbaseSong = UiHymn(hymnIdentifier: songbase1, title: "Songbase song",
                                                  lyrics: [VerseEntity(verseType: .verse, lineStrings: ["Songbase lyrics"])],
                                                  inlineChords: [ChordLine("[G]Songbase chords")])
                        given(hymnsRepository.getHymn(songbase1)) ~> { _ in
                            Just(songbaseSong).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(systemUtil.isNetworkAvailable()) ~> true
                    }
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
                        let expectedTitle = "Songbase song"
                        it("title should be '\(expectedTitle)'") {
                            expect(target.title).to(equal(expectedTitle))
                        }
                        it("should store the song into the history store") {
                            verify(historyStore.storeRecentSong(hymnToStore: songbase1, songTitle: "Songbase song")).wasCalled(exactly(1))
                        }
                        it("should not call hymnsRepository.getHymn") {
                            verify(hymnsRepository.getHymn(songbase1)).wasCalled(1)
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
                            expect(target.tabItems).to(haveCount(2))
                        }
                        it("first tab should be lyrics") {
                            expect(target.tabItems[0].id).to(equal("Lyrics"))
                        }
                        it("second tab should be music") {
                            expect(target.tabItems[1].id).to(equal("Music"))
                        }
                        it("should have a bottom bar") {
                            expect(target.bottomBar).to(equal(DisplayHymnBottomBarViewModel(hymnToDisplay: songbase1, hymn: hymn)))
                        }
                    }
                }
                context("with lyrics and emptyinline chords") {
                    beforeEach {
                        target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore,
                                                      hymnToDisplay: songbase1, hymnsRepository: hymnsRepository,
                                                      historyStore: historyStore, mainQueue: testQueue,
                                                      pdfPreloader: pdfLoader, systemUtil: systemUtil, storeInHistoryStore: true)
                        let songbaseSong = UiHymn(hymnIdentifier: songbase1, title: "Songbase song",
                                                  lyrics: [VerseEntity(verseType: .verse, lineStrings: ["Songbase lyrics"])],
                                                  inlineChords: [ChordLine]())
                        given(hymnsRepository.getHymn(songbase1)) ~> { _ in
                            Just(songbaseSong).assertNoFailure().eraseToAnyPublisher()
                        }
                        given(systemUtil.isNetworkAvailable()) ~> true
                    }
                    let expectedTitle = "Songbase song"
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
                            verify(hymnsRepository.getHymn(songbase1)).wasCalled(1)
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
                            expect(target.tabItems[0].id).to(equal("Lyrics"))
                        }
                        it("should have a bottom bar") {
                            expect(target.bottomBar).to(equal(DisplayHymnBottomBarViewModel(hymnToDisplay: songbase1, hymn: hymn)))
                        }
                    }
                }
                context("with inline chords and sheet music") {
                    let expectedTitle = "Hymn 1151"
                    beforeEach {
                        target = DisplayHymnViewModel(backgroundQueue: testQueue, favoriteStore: favoriteStore,
                                                      hymnToDisplay: classic1151, hymnsRepository: hymnsRepository,
                                                      historyStore: historyStore, mainQueue: testQueue,
                                                      pdfPreloader: pdfLoader, systemUtil: systemUtil, storeInHistoryStore: true)
                        let hymn = UiHymn(hymnIdentifier: classic1151, title: "title",
                                          lyrics: [VerseEntity(verseType: .verse, lineStrings: ["verse line"])],
                                          inlineChords: [ChordLine("[G]Songbase chords")],
                                          pdfSheet: ["Piano": "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_p.pdf",
                                                     "Guitar": "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_g.pdf"])
                        given(hymnsRepository.getHymn(classic1151)) ~> { _ in
                            Just(hymn).assertNoFailure().eraseToAnyPublisher()
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
                    let pianoUrl = URL(string: "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_p.pdf")!
                    it("piano url should be prefetched") {
                        verify(pdfLoader.load(url: pianoUrl)).wasCalled(exactly(1))
                    }
                    let chordsUrl = URL(string: "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_g.pdf")!
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

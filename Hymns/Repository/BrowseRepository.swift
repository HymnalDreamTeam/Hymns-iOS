import Combine
import FirebaseCrashlytics
import Resolver

protocol BrowseRepository {
    func scriptureSongs()  -> AnyPublisher<[ScriptureResult], ErrorType>
}

class BrowseRepositoryImpl: BrowseRepository {

    private let dataStore: HymnDataStore

    init(dataStore: HymnDataStore = Resolver.resolve()) {
        self.dataStore = dataStore
    }

    func scriptureSongs()  -> AnyPublisher<[ScriptureResult], ErrorType> {
        dataStore.getScriptureSongs()
            .map({ scriptureEntities -> [ScriptureResult] in
                let scriptures = [ScriptureResult]()
                return scriptureEntities.reduce(into: scriptures) { (results, entity) in
                    let title = entity.title
                    let scriptureReferences = entity.scriptures.components(separatedBy: ";")
                    let hymnIdentifier = HymnIdentifier(hymnType: entity.hymnType, hymnNumber: entity.hymnNumber, queryParams: entity.queryParams)

                    // Keep track of latest book/chapter because some references don't have any book/chapter, so they
                    // should refer to the previous book/chapter
                    var lastBook: Book?
                    var lastChapter: String?
                    for scriptureReference in scriptureReferences {
                        guard !scriptureReference.isEmpty else {
                            continue
                        }
                        var book = RegexUtil.getBookFromReference(scriptureReference)
                        var chapter: String?
                        let verse: String?

                        defer {
                            lastBook = book
                            lastChapter = chapter
                        }

                        if let book = book {
                            chapter = RegexUtil.getChapterFromReference(scriptureReference)
                            verse = RegexUtil.getVerseFromReference(scriptureReference)
                            results.append(ScriptureResult(hymnIdentifier: hymnIdentifier, title: title, book: book, chapter: chapter, verse: verse))
                            continue
                        }

                        // Book is nil, which means we need to fall back on the previously seen book.
                        if let lastBook = lastBook {
                            book = lastBook
                            chapter = RegexUtil.getChapterFromReference(scriptureReference)
                            if chapter == nil {
                                if lastChapter != nil {
                                    chapter = lastChapter
                                } else {
                                    // This should never happen
                                    var references = ""
                                    for scriptureReference in scriptureReferences {
                                        references.append(scriptureReference)
                                        references.append(" ")
                                    }
                                    Crashlytics.crashlytics().record(error: NonFatal(localizedDescription: "Chapter in reference was nil: \(references)"))
                                    continue
                                }
                            }
                            verse = RegexUtil.getVerseFromReference(scriptureReference)
                            results.append(ScriptureResult(hymnIdentifier: hymnIdentifier, title: title, book: lastBook, chapter: chapter, verse: verse))
                            continue
                        } else {
                            // This should never happen
                            var references = ""
                            for scriptureReference in scriptureReferences {
                                references.append(scriptureReference)
                                references.append(" ")
                            }
                        }
                    }
                }
            }).eraseToAnyPublisher()
    }

    func categories(by hymnType: HymnType?)  -> AnyPublisher<[CategoryEntity], ErrorType> {
        if let hymnType = hymnType {
            return dataStore.getCategories(by: hymnType)
        } else {
            return dataStore.getAllCategories()
        }
    }
}

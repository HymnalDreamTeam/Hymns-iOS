import Collections
import Foundation
import Resolver

protocol Converter {
    func toHymnEntity(hymn: Hymn) throws -> HymnEntity
    func toUiHymn(hymnIdentifier: HymnIdentifier, hymnEntity: HymnEntity?) throws -> UiHymn?
    func toSongResultEntities(songResultsPage: SongResultsPage) -> ([SongResultEntity], Bool)
    func toUiSongResultsPage(songResultEntities: [SongResultEntity], hasMorePages: Bool) -> UiSongResultsPage
    func toSingleSongResultViewModels(songResultEntities: [SongResultEntity]) -> [SingleSongResultViewModel]
    func toSingleSongResultViewModels(songResultEntities: [SongResultEntity], storeInHistoryStore: Bool) -> [SingleSongResultViewModel]
    func toMultiSongResultViewModels(songResultsPage: UiSongResultsPage) -> ([MultiSongResultViewModel], Bool)
    func toMultiSongResultViewModels(songResultEntities: [SongResultEntity], storeInHistoryStore: Bool) -> [MultiSongResultViewModel]
    func toTitle(hymnIdentifier: HymnIdentifier, title: String?) -> String
}

class ConverterImpl: Converter {

    private let firebaseLogger: FirebaseLogger

    init(firebaseLogger: FirebaseLogger = Resolver.resolve()) {
        self.firebaseLogger = firebaseLogger
    }

    // swiftlint:disable:next cyclomatic_complexity
    func toHymnEntity(hymn: Hymn) throws -> HymnEntity {
        return HymnEntity.with { [self] builder in
            builder.id = 0
            builder.title = hymn.title.replacingOccurrences(of: "Hymn: ", with: "")
            if let verses = extractVerseEntities(hymn.lyrics) {
                builder.lyrics = LyricsEntity(verses)
            }
            if let category = getMetadata(hymn: hymn, metaDatumName: .category) {
                builder.category = category
            }
            if let subcategory = getMetadata(hymn: hymn, metaDatumName: .subcategory) {
                builder.subcategory = subcategory
            }
            if let author = getMetadata(hymn: hymn, metaDatumName: .author) {
                builder.author = author
            }
            if let composer = getMetadata(hymn: hymn, metaDatumName: .composer) {
                builder.composer = composer
            }
            if let key = getMetadata(hymn: hymn, metaDatumName: .key) {
                builder.key = key
            }
            if let time = getMetadata(hymn: hymn, metaDatumName: .time) {
                builder.time = time
            }
            if let meter = getMetadata(hymn: hymn, metaDatumName: .meter) {
                builder.meter = meter
            }
            if let hymnCode = getMetadata(hymn: hymn, metaDatumName: .hymnCode) {
                builder.hymnCode = hymnCode
            }
            if let scriptures = getMetadata(hymn: hymn, metaDatumName: .scriptures) {
                builder.scriptures = scriptures
            }
            if let music = extractValues(hymn.getMetaDatum(name: .music)), let entity = MusicEntity(music) {
                builder.music = entity
            }
            if let svgSheet = extractValues(hymn.getMetaDatum(name: .svgSheet)), let entity = SvgSheetEntity(svgSheet) {
                builder.svgSheet = entity
            }
            if let pdfSheet = extractValues(hymn.getMetaDatum(name: .pdfSheet)), let entity = PdfSheetEntity(pdfSheet) {
                builder.pdfSheet = entity
            }
            if let languages = extractHymnIdentifiers(hymn.getMetaDatum(name: .languages)), let entity = LanguagesEntity(languages) {
                builder.languages = entity
            }
            if let relevant = extractHymnIdentifiers(hymn.getMetaDatum(name: .relevant)), let entity = RelevantsEntity(relevant) {
                builder.relevants = entity
            }
        }
    }

    private func getMetadata(hymn: Hymn, metaDatumName: MetaDatumName) -> [String]? {
        guard let metaDatum = hymn.getMetaDatum(name: metaDatumName) else {
            return nil
        }
        return metaDatum.data.compactMap { datum in
            if datum.value.isEmpty {
                return nil
            }
            return datum.value
        }
    }

    private func extractVerseEntities(_ verses: [Verse]) -> [VerseEntity]? {
        return verses.map { verse in
            let verseType = verse.verseType
            if let transliteration = verse.transliteration, transliteration.count != verse.verseContent.count {
                firebaseLogger.logError(TransliterationMisMatchError(errorDescription: "Mismatch in transliteration and verse content size"),
                                        extraParameters: ["verses_json": String(describing: verses)])
                // If there is a mismatch, we have no way of knowing which transliteration line refers to which verse
                // line, so we just skip transliteration altogether.
                return VerseEntity(verseType: verseType, lines: verse.verseContent.map { LineEntity(lineContent: $0) })
            }
            var lines = [LineEntity]()
            for index in 0 ..< verse.verseContent.count {
                lines.append(LineEntity(lineContent: verse.verseContent[index], transliteration: verse.transliteration?[index]))
            }
            return VerseEntity(verseType: verseType, lines: lines)
        }
    }

    private func extractValues(_ metaDatum: MetaDatum?) -> [String: String]? {
        guard let metaDatum = metaDatum else {
            return nil
        }

        let values = metaDatum.data.reduce(into: [String: String]()) { partialResult, datum in
            partialResult[datum.value] = datum.path
        }
        return !values.isEmpty ? values : nil
    }

    private func extractHymnIdentifiers(_ metaDatum: MetaDatum?) -> [HymnIdentifier]? {
        guard let metaDatum = metaDatum else {
            return nil
        }

        let songLinks = metaDatum.data.compactMap { datum -> HymnIdentifier? in
            let hymnType = RegexUtil.getHymnType(path: datum.path)
            let hymnNumber = RegexUtil.getHymnNumber(path: datum.path)

            guard let hymnType = hymnType, let hymnNumber = hymnNumber else {
                firebaseLogger.logError(SongLinkParsingError(errorDescription: "Unable to parse metadata into valid song link"),
                                        extraParameters: ["datum": String(describing: datum)])
                return nil
            }
            return HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber)
        }
        return !songLinks.isEmpty ? songLinks : nil
    }

    func toTitle(hymnIdentifier: HymnIdentifier, title: String?) -> String {
        let defaultTitle = hymnIdentifier.displayTitle
        guard let title = title else {
            return defaultTitle
        }
        switch hymnIdentifier.hymnType {
        case .newTune, .newSong, .children, .howardHigashi, .beFilled, .blueSongbook, .songbaseOther:
            return title
        default:
            return defaultTitle
        }
    }

    func toUiHymn(hymnIdentifier: HymnIdentifier, hymnEntity: HymnEntity?) throws -> UiHymn? {
        guard let hymnEntity = hymnEntity else {
            return nil
        }

        let title = hymnEntity.hasTitle ? hymnEntity.title : nil
        let lyrics = hymnEntity.lyrics.verses.isEmpty ? nil : hymnEntity.lyrics.verses

        let inlineChords: [ChordLineEntity]? = if hymnEntity.inlineChords.chordLines.map({ $0.hasChords }).contains(true) {
            hymnEntity.inlineChords.chordLines
        } else {
            nil
        }
        let category = hymnEntity.category.isEmpty ? nil : hymnEntity.category.joined(separator: ",")
        let subcategory = hymnEntity.subcategory.isEmpty ? nil : hymnEntity.subcategory.joined(separator: ",")
        let author = hymnEntity.author.isEmpty ? nil : hymnEntity.author.joined(separator: ",")
        let composer = hymnEntity.composer.isEmpty ? nil : hymnEntity.composer.joined(separator: ",")
        let key = hymnEntity.key.isEmpty ? nil : hymnEntity.key.joined(separator: ",")
        let time = hymnEntity.time.isEmpty ? nil : hymnEntity.time.joined(separator: ",")
        let meter = hymnEntity.meter.isEmpty ? nil : hymnEntity.meter.joined(separator: ",")
        let scriptures = hymnEntity.scriptures.isEmpty ? nil : hymnEntity.scriptures.joined(separator: ",")
        let hymnCode = hymnEntity.hymnCode.isEmpty ? nil : hymnEntity.hymnCode.joined(separator: ",")
        let pdfSheet = hymnEntity.pdfSheet.pdfSheet.isEmpty ? nil : hymnEntity.pdfSheet.pdfSheet
        let music = hymnEntity.music.music.isEmpty ? nil : hymnEntity.music.music
        let languages = hymnEntity.languages.languages.isEmpty ? nil : hymnEntity.languages.languages.map { entity -> HymnIdentifier in
            return entity.toHymnIdentifier
        }
        let relevant = hymnEntity.relevants.relevants.isEmpty ? nil : hymnEntity.relevants.relevants.map { entity -> HymnIdentifier in
            return entity.toHymnIdentifier
        }
        return UiHymn(hymnIdentifier: hymnIdentifier, title: title, lyrics: lyrics, inlineChords: inlineChords,
                      pdfSheet: pdfSheet, category: category, subcategory: subcategory, author: author, composer: composer,
                      key: key, time: time, meter: meter, scriptures: scriptures, hymnCode: hymnCode,
                      languages: languages, music: music, relevant: relevant)
    }

    func toSongResultEntities(songResultsPage: SongResultsPage) -> ([SongResultEntity], Bool) {
        let songResultEntities = songResultsPage.results.compactMap { songResult -> SongResultEntity? in
            guard let hymnType = RegexUtil.getHymnType(path: songResult.path), let hymnNumber = RegexUtil.getHymnNumber(path: songResult.path) else {
                firebaseLogger.logError(SongResultParsingError(errorDescription: "error happened when trying to parse song result"),
                                        extraParameters: ["path": songResult.path, "name": songResult.name])
                return nil
            }
            let title = songResult.name
            return SongResultEntity(hymnType: hymnType, hymnNumber: hymnNumber, title: title)
        }
        return (songResultEntities, songResultsPage.hasMorePages ?? false)
    }

    private func groupSongResultEntities(_ songResultEntities: [SongResultEntity]) -> [[SongResultEntity]] {
        var groupedEntities = [[SongResultEntity]()]
        var songIdToIndexMap = OrderedDictionary<Int64, Int>()

        for songResultEntity in songResultEntities {
            // If song id doesn't exist, then treat it as a unique song and don't group it with anything.
            guard let songId = songResultEntity.songId else {
                groupedEntities.append([songResultEntity])
                continue
            }
            if let index = songIdToIndexMap[songId] {
                // Find the correct grouping and append to that grouping
                groupedEntities[index].append(songResultEntity)
            } else {
                // Create new grouping
                songIdToIndexMap[songId] = groupedEntities.count
                groupedEntities.append([songResultEntity])
            }
        }
        return groupedEntities
    }

    func toUiSongResultsPage(songResultEntities: [SongResultEntity], hasMorePages: Bool) -> UiSongResultsPage {
        let groupedResults = groupSongResultEntities(songResultEntities)
            .compactMap({ songResultEntities -> UiSongResult? in
                if songResultEntities.isEmpty {
                    return nil
                }
                let hymnIdentifiers = songResultEntities.map { songResultEntity in
                    songResultEntity.hymnIdentifier
                }
                let title = songResultEntities[0].title
                return UiSongResult(name: title, identifiers: hymnIdentifiers)
            })
        return UiSongResultsPage(results: groupedResults, hasMorePages: hasMorePages)
    }

    func toSingleSongResultViewModels(songResultEntities: [SongResultEntity]) -> [SingleSongResultViewModel] {
        toSingleSongResultViewModels(songResultEntities: songResultEntities, storeInHistoryStore: false)
    }

    func toSingleSongResultViewModels(songResultEntities: [SongResultEntity], storeInHistoryStore: Bool) -> [SingleSongResultViewModel] {
        songResultEntities.map { entity in
            let destination =
            DisplayHymnContainerView(
                viewModel: DisplayHymnContainerViewModel(hymnToDisplay: entity.hymnIdentifier, storeInHistoryStore: storeInHistoryStore)).eraseToAnyView()
            if let title = entity.title {
                return SingleSongResultViewModel(stableId: entity.hymnIdentifier, title: title,
                                                 label: entity.hymnIdentifier.displayTitle,
                                                 destinationView: destination)
            } else {
                return SingleSongResultViewModel(stableId: entity.hymnIdentifier, title: entity.hymnIdentifier.displayTitle,
                                                 destinationView: destination)
            }
        }
    }

    func toMultiSongResultViewModels(songResultsPage: UiSongResultsPage) -> ([MultiSongResultViewModel], Bool) {
        let hasMorePages = songResultsPage.hasMorePages ?? false
        let songResults = songResultsPage.results.compactMap { songResult -> MultiSongResultViewModel? in
            let title = songResult.name ?? songResult.identifiers.first?.displayTitle
            guard let title = title else { return nil }
            let labels = songResult.name != nil ? songResult.identifiers.prefix(3).map(\.displayTitle) : nil
            let destination = DisplayHymnContainerView(viewModel:
                                                        DisplayHymnContainerViewModel(hymnToDisplay: songResult.identifiers[0],
                                                                                      storeInHistoryStore: true)).eraseToAnyView()
            return MultiSongResultViewModel(stableId: songResult.identifiers,
                                            title: title,
                                            labels: labels,
                                            destinationView: destination)
        }
        return (songResults, hasMorePages)
    }

    func toMultiSongResultViewModels(songResultEntities: [SongResultEntity], storeInHistoryStore: Bool) -> [MultiSongResultViewModel] {
        groupSongResultEntities(songResultEntities).compactMap { groupedSongResultEntities -> MultiSongResultViewModel? in
            guard
                let firstEntity = groupedSongResultEntities.first,
                let firstTitle = groupedSongResultEntities.compactMap({$0.title}).first else {
                    return nil
                }
            let identifiers = groupedSongResultEntities.map { songResultEntity in
                songResultEntity.hymnIdentifier
            }
            let labels = identifiers.prefix(3).map({ identifier in
                identifier.displayTitle
            })
            let destination = DisplayHymnContainerView(viewModel:
                                                        DisplayHymnContainerViewModel(hymnToDisplay: firstEntity.hymnIdentifier,
                                                                                      storeInHistoryStore: true)).eraseToAnyView()
            return MultiSongResultViewModel(stableId: identifiers, title: firstTitle, labels: labels, destinationView: destination)
        }
    }
}

extension Resolver {
    static func registerConverters() {
        register {ConverterImpl() as Converter}.scope(.application)
    }
}

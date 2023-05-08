import Foundation
import Resolver

protocol Converter {
    func toHymnEntity(hymn: Hymn) throws -> HymnEntity
    func toUiHymn(hymnIdentifier: HymnIdentifier, hymnEntity: HymnEntity?) throws -> UiHymn?
    func toSongResultEntities(songResultsPage: SongResultsPage) -> ([SongResultEntity], Bool)
    func toUiSongResultsPage(songResultsEntities: [SongResultEntity], hasMorePages: Bool) -> UiSongResultsPage
}

class ConverterImpl: Converter {

    private let firebaseLogger: FirebaseLogger

    init(firebaseLogger: FirebaseLogger = Resolver.resolve()) {
        self.firebaseLogger = firebaseLogger
    }

    func toHymnEntity(hymn: Hymn) throws -> HymnEntity {
        HymnEntityBuilder()
            .title(hymn.title)
            .lyrics(extractVerseEntities(hymn.lyrics))
            .category(getMetadata(hymn: hymn, metaDatumName: .category))
            .subcategory(getMetadata(hymn: hymn, metaDatumName: .subcategory))
            .author(getMetadata(hymn: hymn, metaDatumName: .author))
            .composer(getMetadata(hymn: hymn, metaDatumName: .composer))
            .key(getMetadata(hymn: hymn, metaDatumName: .key))
            .time(getMetadata(hymn: hymn, metaDatumName: .time))
            .meter(getMetadata(hymn: hymn, metaDatumName: .meter))
            .hymnCode(getMetadata(hymn: hymn, metaDatumName: .hymnCode))
            .scriptures(getMetadata(hymn: hymn, metaDatumName: .scriptures))
            .music(extractValues(hymn.getMetaDatum(name: .music)))
            .svgSheet(extractValues(hymn.getMetaDatum(name: .svgSheet)))
            .pdfSheet(extractValues(hymn.getMetaDatum(name: .pdfSheet)))
            .languages(extractSongLinks(hymn.getMetaDatum(name: .languages)))
            .relevant(extractSongLinks(hymn.getMetaDatum(name: .relevant)))
            .build()
    }

    private func getMetadata(hymn: Hymn, metaDatumName: MetaDatumName) -> String? {
        guard let metaDatum = hymn.getMetaDatum(name: metaDatumName) else {
            return nil
        }

        var databaseValue = ""
        for (index, datum) in metaDatum.data.enumerated() {
            if datum.value.isEmpty {
                continue
            }
            databaseValue += datum.value
            if index < metaDatum.data.count - 1 {
                databaseValue += ""
            }
        }
        return databaseValue.trim()
    }

    private func extractVerseEntities(_ verses: [Verse]) -> [VerseEntity]? {
        return verses.map { verse in
            let verseType = verse.verseType
            if let transliteration = verse.transliteration, transliteration.count != verse.verseContent.count {
                firebaseLogger.logError(message: "Mismatch in transliteration and verse content size",
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

    private func extractSongLinks(_ metaDatum: MetaDatum?) -> [SongLink]? {
        guard let metaDatum = metaDatum else {
            return nil
        }

        let songLinks = metaDatum.data.compactMap { datum -> SongLink? in
            let value = datum.value
            let hymnType = RegexUtil.getHymnType(path: datum.path)
            let hymnNumber = RegexUtil.getHymnNumber(path: datum.path)

            guard let hymnType = hymnType, let hymnNumber = hymnNumber else {
                firebaseLogger.logError(message: "Unable to parse metadata into valid song link",
                                        extraParameters: ["datum": String(describing: datum)])
                return nil
            }
            return SongLink(reference: HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber), name: value)
        }
        return !songLinks.isEmpty ? songLinks : nil
    }

    func toUiHymn(hymnIdentifier: HymnIdentifier, hymnEntity: HymnEntity?) throws -> UiHymn? {
        guard let hymnEntity = hymnEntity else {
            return nil
        }

        // Many hymn titles prepend "Hymn: " to the title. It is unnecessary and takes up screen space, so  we
        // strip it out whenever possible.
        guard let title = hymnEntity.title?.replacingOccurrences(of: "Hymn: ", with: ""), !title.isEmpty else {
            throw TypeConversionError(triggeringError: ErrorType.parsing(description: "title was empty"))
        }

        let lyrics = hymnEntity.lyrics
        let category = hymnEntity.category
        let subcategory = hymnEntity.subcategory
        let author = hymnEntity.author
        let composer = hymnEntity.composer
        let key = hymnEntity.key
        let time = hymnEntity.time
        let meter = hymnEntity.meter
        let scriptures = hymnEntity.scriptures
        let hymnCode = hymnEntity.hymnCode
        let pdfSheet = hymnEntity.pdfSheet
        let music = hymnEntity.music
        let languages = hymnEntity.languages
        let relevant = hymnEntity.relevant
        return UiHymn(hymnIdentifier: hymnIdentifier, title: title, lyrics: lyrics, pdfSheet: pdfSheet,
                      category: category, subcategory: subcategory, author: author, composer: composer,
                      key: key, time: time, meter: meter, scriptures: scriptures, hymnCode: hymnCode,
                      languages: languages, music: music, relevant: relevant)
    }

    func toSongResultEntities(songResultsPage: SongResultsPage) -> ([SongResultEntity], Bool) {
        let songResultEntities = songResultsPage.results.compactMap { songResult -> SongResultEntity? in
            guard let hymnType = RegexUtil.getHymnType(path: songResult.path), let hymnNumber = RegexUtil.getHymnNumber(path: songResult.path) else {
                firebaseLogger.logError(message: "error happened when trying to parse song result",
                                        extraParameters: ["path": songResult.path, "name": songResult.name])
                return nil
            }
            let title = songResult.name
            return SongResultEntity(hymnType: hymnType, hymnNumber: hymnNumber, title: title)
        }
        return (songResultEntities, songResultsPage.hasMorePages ?? false)
    }

    func toUiSongResultsPage(songResultsEntities: [SongResultEntity], hasMorePages: Bool) -> UiSongResultsPage {
        let songResults = songResultsEntities.map { songResultsEntity -> UiSongResult in
            let title = songResultsEntity.title
            let hymnType = songResultsEntity.hymnType
            let hymnNumber = songResultsEntity.hymnNumber
            let hymnIdentifier = HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber)
            return UiSongResult(name: title, identifier: hymnIdentifier)
        }
        return UiSongResultsPage(results: songResults, hasMorePages: hasMorePages)
    }
}

extension Resolver {
    static func registerConverters() {
        register {ConverterImpl() as Converter}.scope(.application)
    }
}

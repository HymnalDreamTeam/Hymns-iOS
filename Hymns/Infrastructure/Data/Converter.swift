import Foundation
import Resolver

protocol Converter {
    func toHymnEntity(hymnIdentifier: HymnIdentifier, hymn: Hymn) throws -> HymnEntity
    func toUiHymn(hymnIdentifier: HymnIdentifier, hymnEntity: HymnEntity?) throws -> UiHymn?
    func toSongResultEntities(songResultsPage: SongResultsPage) -> ([SongResultEntity], Bool)
    func toUiSongResultsPage(songResultsEntities: [SongResultEntity], hasMorePages: Bool) -> UiSongResultsPage
}

class ConverterImpl: Converter {

    private let analytics: AnalyticsLogger
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    init(analytics: AnalyticsLogger = Resolver.resolve(),
         jsonDecoder: JSONDecoder = Resolver.resolve(),
         jsonEncoder: JSONEncoder = Resolver.resolve()) {
        self.analytics = analytics
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
    }

    func toHymnEntity(hymnIdentifier: HymnIdentifier, hymn: Hymn) throws -> HymnEntity {
        HymnEntityBuilder(hymnIdentifier: hymnIdentifier)
            .title(hymn.title)
            .lyricsJson(try jsonEncoder.encode(hymn.lyrics).toString)
            .category(getMetadata(hymn: hymn, metaDatumName: .category))
            .subcategory(getMetadata(hymn: hymn, metaDatumName: .subcategory))
            .author(getMetadata(hymn: hymn, metaDatumName: .author))
            .composer(getMetadata(hymn: hymn, metaDatumName: .composer))
            .key(getMetadata(hymn: hymn, metaDatumName: .key))
            .time(getMetadata(hymn: hymn, metaDatumName: .time))
            .meter(getMetadata(hymn: hymn, metaDatumName: .meter))
            .hymnCode(getMetadata(hymn: hymn, metaDatumName: .hymnCode))
            .scriptures(getMetadata(hymn: hymn, metaDatumName: .scriptures))
            .musicJson(hymn.getMetaDatum(name: .music) != nil ? try? jsonEncoder.encode(hymn.getMetaDatum(name: .music)).toString : nil)
            .svgSheetJson(hymn.getMetaDatum(name: .svgSheet) != nil ? try? jsonEncoder.encode(hymn.getMetaDatum(name: .svgSheet)).toString : nil)
            .pdfSheetJson(hymn.getMetaDatum(name: .pdfSheet) != nil ? try? jsonEncoder.encode(hymn.getMetaDatum(name: .pdfSheet)).toString : nil)
            .languagesJson(hymn.getMetaDatum(name: .languages) != nil ? try? jsonEncoder.encode(hymn.getMetaDatum(name: .languages)).toString : nil)
            .relevantJson(hymn.getMetaDatum(name: .relevant) != nil ? try? jsonEncoder.encode(hymn.getMetaDatum(name: .relevant)).toString : nil)
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

    func toUiHymn(hymnIdentifier: HymnIdentifier, hymnEntity: HymnEntity?) throws -> UiHymn? {
        guard let hymnEntity = hymnEntity else {
            return nil
        }

        guard let lyrics = hymnEntity.lyricsJson, !lyrics.isEmpty, let lyricsData = lyrics.data(using: .utf8) else {
            throw TypeConversionError(triggeringError: ErrorType.parsing(description: "lyrics json was empty"))
        }

        // Many hymn titles prepend "Hymn: " to the title. It is unnecessary and takes up screen space, so  we
        // strip it out whenever possible.
        guard let title = hymnEntity.title?.replacingOccurrences(of: "Hymn: ", with: ""), !title.isEmpty else {
            throw TypeConversionError(triggeringError: ErrorType.parsing(description: "title was empty"))
        }

        let category = hymnEntity.category
        let subcategory = hymnEntity.subcategory
        let author = hymnEntity.author
        let composer = hymnEntity.composer
        let key = hymnEntity.key
        let time = hymnEntity.time
        let meter = hymnEntity.meter
        let scriptures = hymnEntity.scriptures
        let hymnCode = hymnEntity.hymnCode

        let pdfSheet: MetaDatum?
        if let pdfData = hymnEntity.pdfSheetJson?.data(using: .utf8) {
            pdfSheet = try? jsonDecoder.decode(MetaDatum.self, from: pdfData)
        } else {
            pdfSheet = nil
        }

        let music: MetaDatum?
         if let musicData = hymnEntity.musicJson?.data(using: .utf8) {
             music = try? jsonDecoder.decode(MetaDatum.self, from: musicData)
         } else {
             music = nil
         }

        let languages: MetaDatum?
        if let languagesData = hymnEntity.languagesJson?.data(using: .utf8) {
            languages = try? jsonDecoder.decode(MetaDatum.self, from: languagesData)
        } else {
            languages = nil
        }

        let relevant: MetaDatum?
        if let relevantData = hymnEntity.relevantJson?.data(using: .utf8) {
            relevant = try? jsonDecoder.decode(MetaDatum.self, from: relevantData)
        } else {
            relevant = nil
        }

        do {
            let verses = try jsonDecoder.decode([Verse].self, from: lyricsData)
            return UiHymn(hymnIdentifier: hymnIdentifier, title: title, lyrics: verses, pdfSheet: pdfSheet,
                          category: category, subcategory: subcategory, author: author, composer: composer,
                          key: key, time: time, meter: meter, scriptures: scriptures, hymnCode: hymnCode,
                          languages: languages, music: music, relevant: relevant)
        } catch {
            throw TypeConversionError(triggeringError: error)
        }
    }

    func toSongResultEntities(songResultsPage: SongResultsPage) -> ([SongResultEntity], Bool) {
        let songResultEntities = songResultsPage.results.compactMap { songResult -> SongResultEntity? in
            guard let hymnType = RegexUtil.getHymnType(path: songResult.path), let hymnNumber = RegexUtil.getHymnNumber(path: songResult.path) else {
                self.analytics.logError(message: "error happened when trying to parse song result", extraParameters: ["path": songResult.path, "name": songResult.name])
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

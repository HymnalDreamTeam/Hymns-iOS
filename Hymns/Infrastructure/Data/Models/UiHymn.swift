import Foundation

/**
 * Structure of a Hymn object to be consumed by the UI.
 */
struct UiHymn: Equatable {
    let hymnIdentifier: HymnIdentifier
    let title: String
    let lyrics: [Verse]?
    let chords: [ChordLine]?
    let pdfSheet: [String: String]?
    let category: String?
    let subcategory: String?
    let author: String?
    let composer: String?
    let key: String?
    let time: String?
    let meter: String?
    let scriptures: String?
    let hymnCode: String?
    let languages: [SongLink]?
    let music: [String: String]?
    let relevant: [SongLink]?
    // add more fields as needed

    init(hymnIdentifier: HymnIdentifier, title: String, lyrics: [Verse]? = nil, chords: [ChordLine]? = nil,
         pdfSheet: [String: String]? = nil, category: String? = nil, subcategory: String? = nil, author: String? = nil,
         composer: String? = nil, key: String? = nil, time: String? = nil, meter: String? = nil, scriptures: String? = nil,
         hymnCode: String? = nil, languages: [SongLink]? = nil, music: [String: String]? = nil, relevant: [SongLink]? = nil) {
        self.hymnIdentifier = hymnIdentifier
        self.title = title
        self.lyrics = lyrics
        self.chords = chords
        self.pdfSheet = pdfSheet
        self.category = category
        self.subcategory = subcategory
        self.author = author
        self.composer = composer
        self.key = key
        self.time = time
        self.meter = meter
        self.scriptures = scriptures
        self.hymnCode = hymnCode
        self.languages = languages
        self.music = music
        self.relevant = relevant
    }

    var builder: UiHymnBuilder {
        UiHymnBuilder(hymnIdentifier: hymnIdentifier, title: title)
            .lyrics(lyrics)
            .chords(chords)
            .pdfSheet(pdfSheet)
            .category(category)
            .subcategory(subcategory)
            .author(author)
            .composer(composer)
            .key(key)
            .time(time)
            .meter(meter)
            .scriptures(scriptures)
            .hymnCode(hymnCode)
            .languages(languages)
            .music(music)
            .relevant(relevant)
    }
}

class UiHymnBuilder {

    private (set) var hymnIdentifier: HymnIdentifier
    private (set) var title: String
    private (set) var lyrics: [Verse]?
    private (set) var chords: [ChordLine]?
    private (set) var pdfSheet: [String: String]?
    private (set) var category: String?
    private (set) var subcategory: String?
    private (set) var author: String?
    private (set) var composer: String?
    private (set) var key: String?
    private (set) var time: String?
    private (set) var meter: String?
    private (set) var scriptures: String?
    private (set) var hymnCode: String?
    private (set) var languages: [SongLink]?
    private (set) var music: [String: String]?
    private (set) var relevant: [SongLink]?

    init(hymnIdentifier: HymnIdentifier, title: String) {
        self.hymnIdentifier = hymnIdentifier
        self.title = title
    }

    public func lyrics(_ lyrics: [Verse]?) -> UiHymnBuilder {
        self.lyrics = lyrics
        return self
    }

    public func chords(_ chords: [ChordLine]?) -> UiHymnBuilder {
        self.chords = chords
        return self
    }

    public func pdfSheet(_ pdfSheet: [String: String]?) -> UiHymnBuilder {
        self.pdfSheet = pdfSheet
        return self
    }

    public func category(_ category: String?) -> UiHymnBuilder {
        self.category = category
        return self
    }

    public func subcategory(_ subcategory: String?) -> UiHymnBuilder {
        self.subcategory = subcategory
        return self
    }

    public func author(_ author: String?) -> UiHymnBuilder {
        self.author = author
        return self
    }

    public func composer(_ composer: String?) -> UiHymnBuilder {
        self.composer = composer
        return self
    }

    public func key(_ key: String?) -> UiHymnBuilder {
        self.key = key
        return self
    }

    public func time(_ time: String?) -> UiHymnBuilder {
        self.time = time
        return self
    }

    public func meter(_ meter: String?) -> UiHymnBuilder {
        self.meter = meter
        return self
    }

    public func scriptures(_ scriptures: String?) -> UiHymnBuilder {
        self.scriptures = scriptures
        return self
    }

    public func hymnCode(_ hymnCode: String?) -> UiHymnBuilder {
        self.hymnCode = hymnCode
        return self
    }

    public func languages(_ languages: [SongLink]?) -> UiHymnBuilder {
        self.languages = languages
        return self
    }

    public func music(_ music: [String: String]?) -> UiHymnBuilder {
        self.music = music
        return self
    }

    public func relevant(_ relevant: [SongLink]?) -> UiHymnBuilder {
        self.relevant = relevant
        return self
    }

    public func build() -> UiHymn {
        UiHymn(hymnIdentifier: hymnIdentifier, title: title, lyrics: lyrics, chords: chords, pdfSheet: pdfSheet, category: category, subcategory: subcategory,
               author: author, composer: composer, key: key, time: time, meter: meter, scriptures: scriptures, hymnCode: hymnCode, languages: languages,
               music: music, relevant: relevant)
    }
}

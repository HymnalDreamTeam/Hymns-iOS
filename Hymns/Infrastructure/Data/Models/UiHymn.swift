import Foundation

/**
 * Structure of a Hymn object to be consumed by the UI.
 */
struct UiHymn: Equatable {
    let hymnIdentifier: HymnIdentifier
    let title: String
    let lyrics: [Verse]?
    let pdfSheet: MetaDatum?
    let category: String?
    let subcategory: String?
    let author: String?
    let composer: String?
    let key: String?
    let time: String?
    let meter: String?
    let scriptures: String?
    let hymnCode: String?
    let languages: MetaDatum?
    let music: MetaDatum?
    let relevant: MetaDatum?
    // add more fields as needed

    init(hymnIdentifier: HymnIdentifier, title: String, lyrics: [Verse]?, pdfSheet: MetaDatum? = nil,
         category: String? = nil, subcategory: String? = nil, author: String? = nil, composer: String? = nil,
         key: String? = nil, time: String? = nil, meter: String? = nil, scriptures: String? = nil,
         hymnCode: String? = nil, languages: MetaDatum? = nil, music: MetaDatum? = nil, relevant: MetaDatum? = nil) {
        self.hymnIdentifier = hymnIdentifier
        self.title = title
        self.lyrics = lyrics
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
}

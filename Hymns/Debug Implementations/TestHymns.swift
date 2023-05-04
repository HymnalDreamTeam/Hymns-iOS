#if DEBUG
import Foundation
let classic1151 = HymnIdentifier(hymnType: .classic, hymnNumber: "1151")
let classic1152 = HymnIdentifier(hymnType: .classic, hymnNumber: "1152")
let chineseSupplement216 = HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "216")
let classic40 = HymnIdentifier(hymnType: .classic, hymnNumber: "40")
let classic2 = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
let classic3 = HymnIdentifier(hymnType: .classic, hymnNumber: "3")
let classic4 = HymnIdentifier(hymnType: .classic, hymnNumber: "4")
let howardiHigsashi2 = HymnIdentifier(hymnType: .howardHigashi, hymnNumber: "2")
let classic1151Entity = HymnEntityBuilder(hymnIdentifier: classic1151)
    .title(Optional("Hymn: Minoru\'s song"))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "verse 1 line 1"),
                                                    LineEntity(lineContent: "verse 1 line 2"),
                                                    LineEntity(lineContent: "verse 1 really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really long line 3"),
                                                    LineEntity(lineContent: "verse 1 line 4")]),
             VerseEntity(verseType: .chorus, lines: [LineEntity(lineContent: "chorus line 1"),
                                                     LineEntity(lineContent: "chorus line 2"),
                                                     LineEntity(lineContent: "chorus line 3"),
                                                     LineEntity(lineContent: "chorus line 4"),
                                                     LineEntity(lineContent: "chorus line 5"),
                                                     LineEntity(lineContent: "chorus line 6"),
                                                     LineEntity(lineContent: "chorus line 7")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "verse 3 line 1"),
                                                    LineEntity(lineContent: "verse 3 line 2"),
                                                    LineEntity(lineContent: "verse 3 line 3"),
                                                    LineEntity(lineContent: "verse 3 line 4")])])
    .category("song's category")
    .subcategory("song's subcategory")
    .music(["mp3": "/en/hymn/h/1151/f=mp3", "MIDI": "/en/hymn/h/1151/f=mid", "Tune (MIDI)": "/en/hymn/h/1151/f=tune"])
    .pdfSheet(["Piano": "/en/hymn/h/1151/f=ppdf"])
    .languages([SongLink(reference: HymnIdentifier(hymnType: .cebuano, hymnNumber: "1151"), name: "Cebuano"),
                SongLink(reference: HymnIdentifier(hymnType: .chineseSupplementSimplified, hymnNumber: "216"), name: "\u{8bd7}\u{6b4c}(\u{7b80})"),
                SongLink(reference: HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "216"), name: "\u{8a69}\u{6b4c}(\u{7e41})"),
                SongLink(reference: HymnIdentifier(hymnType: .tagalog, hymnNumber: "1151"), name: "Tagalog")])
    .relevant([SongLink(reference: HymnIdentifier(hymnType: .classic, hymnNumber: "2"), name: "New Tune")])
    .build()
let classic1152Entity = HymnEntityBuilder(hymnIdentifier: classic1152)
    .title(Optional("Classic 1152"))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 1152")])])
    .build()
let classic2Entity = HymnEntityBuilder(hymnIdentifier: classic2)
    .title(Optional("Classic 2"))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 2 verse 1")]),
             VerseEntity(verseType: .chorus, lines: [LineEntity(lineContent: "classic hymn 2 chorus")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 2 verse 2")])])
    .build()
let classic3Entity = HymnEntityBuilder(hymnIdentifier: classic3)
    .title(Optional("Classic 3"))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 3 verse 1")]),
             VerseEntity(verseType: .chorus, lines: [LineEntity(lineContent: "classic hymn 3 chorus")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 3 verse 2")])])
    .pdfSheet(["Piano": "/en/hymn/h/1151/f=ppdf", "Text": "/en/hymn/h/3/f=gtpdf"])
    .build()
let classic40Entity = HymnEntityBuilder(hymnIdentifier: classic40)
    .title(Optional("Classic 40"))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 40 verse 1")]),
             VerseEntity(verseType: .chorus, lines: [LineEntity(lineContent: "classic hymn 40 chorus")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 40 verse 2")])])
    .pdfSheet(["Piano": "/en/hymn/h/40/f=ppdf", "Guitar": "/en/hymn/h/40/f=gpdf"])
    .build()
let chineseSupplement216Entity = HymnEntityBuilder(hymnIdentifier: chineseSupplement216)
    .title(Optional("Hymn: Minoru\'s song in Chinese"))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "chinese verse 1 chinese line 1")])])
    .build()
let howardHigashi2Entity = HymnEntityBuilder(hymnIdentifier: howardiHigsashi2)
    .title(Optional("Hymn: Howard Higashi\'s  second "))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "howard higashi verse 1 line 2")])])
    .languages([SongLink(reference: HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "216"), name: "ZhongWen")])
    .build()
#endif

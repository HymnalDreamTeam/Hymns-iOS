// Hymns used by the various test implementations
#if DEBUG
import Foundation
let classic1151 = HymnIdEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1151"), songId: 1).build()
let classic1152 = HymnIdEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1152"), songId: 2).build()
let chineseSupplement216 = HymnIdEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "216"), songId: 3).build()
let classic40 = HymnIdEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "40"), songId: 4).build()
let classic2 = HymnIdEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "2"), songId: 5).build()
let classic3 = HymnIdEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "3"), songId: 6).build()
let classic4 = HymnIdEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "4"), songId: 7).build()
let howardiHigsashi2 = HymnIdEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .howardHigashi, hymnNumber: "2"), songId: 8).build()
let blueSongbook2 = HymnIdEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .blueSongbook, hymnNumber: "2"), songId: 9).build()
let classic1151Entity = HymnEntityBuilder(id: classic1151.songId)
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
                                                    LineEntity(lineContent: "verse 3 line 4")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "verse 4 line 1"),
                                                    LineEntity(lineContent: "verse 4 line 2"),
                                                    LineEntity(lineContent: "verse 4 line 3"),
                                                    LineEntity(lineContent: "verse 4 line 4")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "verse 5 line 1"),
                                                    LineEntity(lineContent: "verse 5 line 2"),
                                                    LineEntity(lineContent: "verse 5 line 3"),
                                                    LineEntity(lineContent: "verse 5 line 4")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "verse 6 line 1"),
                                                    LineEntity(lineContent: "verse 6 line 2"),
                                                    LineEntity(lineContent: "verse 6 line 3"),
                                                    LineEntity(lineContent: "verse 6 line 4")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "verse 7 line 1"),
                                                    LineEntity(lineContent: "verse 7 line 2"),
                                                    LineEntity(lineContent: "verse 7 line 3"),
                                                    LineEntity(lineContent: "verse 7 line 4")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "verse 8 line 1"),
                                                    LineEntity(lineContent: "verse 8 line 2"),
                                                    LineEntity(lineContent: "verse 8 line 3"),
                                                    LineEntity(lineContent: "verse 8 line 4")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "verse 9 line 1"),
                                                    LineEntity(lineContent: "verse 9 line 2"),
                                                    LineEntity(lineContent: "verse 9 line 3"),
                                                    LineEntity(lineContent: "verse 9 line 4")])])
    .inlineChords("[G]Songbase version of Hymn 1151 chords")
    .category("song's category")
    .subcategory("song's subcategory")
    .music(["mp3": "/en/hymn/h/1151/f=mp3", "MIDI": "/en/hymn/h/1151/f=mid", "Tune (MIDI)": "/en/hymn/h/1151/f=tune"])
    .pdfSheet(["Piano": "/en/hymn/h/1151/f=ppdf"])
    .languages([HymnIdentifier(hymnType: .cebuano, hymnNumber: "1151"),
                HymnIdentifier(hymnType: .chineseSupplementSimplified, hymnNumber: "216"),
                HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "216"),
                HymnIdentifier(hymnType: .dutch, hymnNumber: "35"),
                HymnIdentifier(hymnType: .tagalog, hymnNumber: "1151")])
    .relevant([HymnIdentifier(hymnType: .classic, hymnNumber: "2")])
    .build()
let classic1152Entity = HymnEntityBuilder(id: classic1152.songId)
    .title(Optional("Classic 1152"))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 1152")])])
    .build()
let classic2Entity = HymnEntityBuilder(id: classic2.songId)
    .title(Optional("Classic 2"))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 2 verse 1")]),
             VerseEntity(verseType: .chorus, lines: [LineEntity(lineContent: "classic hymn 2 chorus")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 2 verse 2")])])
    .build()
let classic3Entity = HymnEntityBuilder(id: classic3.songId)
    .title(Optional("Classic 3"))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 3 verse 1")]),
             VerseEntity(verseType: .chorus, lines: [LineEntity(lineContent: "classic hymn 3 chorus")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 3 verse 2")])])
    .pdfSheet(["Piano": "/en/hymn/h/3/f=ppdf", "Text": "/en/hymn/h/3/f=gtpdf"])
    .build()
let classic40Entity = HymnEntityBuilder(id: classic40.songId)
    .title(Optional("Classic 40"))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 40 verse 1")]),
             VerseEntity(verseType: .chorus, lines: [LineEntity(lineContent: "classic hymn 40 chorus")]),
             VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 40 verse 2")])])
    .pdfSheet(["Piano": "/en/hymn/h/40/f=ppdf", "Guitar": "/en/hymn/h/40/f=gpdf"])
    .build()
let chineseSupplement216Entity = HymnEntityBuilder(id: chineseSupplement216.songId)
    .title(Optional("Hymn: Minoru\'s song in Chinese"))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "chinese verse 1 chinese line 1")])])
    .build()
let howardHigashi2Entity = HymnEntityBuilder(id: howardiHigsashi2.songId)
    .title(Optional("Hymn: Howard Higashi\'s  second "))
    .lyrics([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "howard higashi verse 1 line 2")])])
    .languages([HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "216")])
    .build()
let blueSongbook2Entity = HymnEntityBuilder(id: blueSongbook2.songId)
    .title("Songbase version of Hymn 1151 title")
    .lyrics([VerseEntity(verseType: .doNotDisplay, lineStrings: ["Songbase version of Hymn 1151 lyrics"])])
    .inlineChords("[G]Songbase version of Hymn 1151 chords")
    .build()

#endif

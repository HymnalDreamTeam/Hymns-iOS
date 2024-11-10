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
let classic1151Entity = HymnEntity.with { builder in
    builder.title = "Hymn: Minoru\'s song"
    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse,
                                               lines: [LineEntity(lineContent: "verse 1 line 1"),
                                                       LineEntity(lineContent: "verse 1 line 2"),
                                                       LineEntity(lineContent: "verse 1 really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really long line 3"),
                                                       LineEntity(lineContent: "verse 1 line 4")]),
                                   VerseEntity(verseType: .chorus,
                                               lines: [LineEntity(lineContent: "chorus line 1"),
                                                       LineEntity(lineContent: "chorus line 2"),
                                                       LineEntity(lineContent: "chorus line 3"),
                                                       LineEntity(lineContent: "chorus line 4"),
                                                       LineEntity(lineContent: "chorus line 5"),
                                                       LineEntity(lineContent: "chorus line 6"),
                                                       LineEntity(lineContent: "chorus line 7")]),
                                   VerseEntity(verseType: .verse,
                                               lines: [LineEntity(lineContent: "verse 3 line 1"),
                                                       LineEntity(lineContent: "verse 3 line 2"),
                                                       LineEntity(lineContent: "verse 3 line 3"),
                                                       LineEntity(lineContent: "verse 3 line 4")]),
                                   VerseEntity(verseType: .verse,
                                               lines: [LineEntity(lineContent: "verse 4 line 1"),
                                                       LineEntity(lineContent: "verse 4 line 2"),
                                                       LineEntity(lineContent: "verse 4 line 3"),
                                                       LineEntity(lineContent: "verse 4 line 4")]),
                                   VerseEntity(verseType: .verse,
                                               lines: [LineEntity(lineContent: "verse 5 line 1"),
                                                       LineEntity(lineContent: "verse 5 line 2"),
                                                       LineEntity(lineContent: "verse 5 line 3"),
                                                       LineEntity(lineContent: "verse 5 line 4")]),
                                   VerseEntity(verseType: .verse,
                                               lines: [LineEntity(lineContent: "verse 6 line 1"),
                                                       LineEntity(lineContent: "verse 6 line 2"),
                                                       LineEntity(lineContent: "verse 6 line 3"),
                                                       LineEntity(lineContent: "verse 6 line 4")]),
                                   VerseEntity(verseType: .verse,
                                               lines: [LineEntity(lineContent: "verse 7 line 1"),
                                                       LineEntity(lineContent: "verse 7 line 2"),
                                                       LineEntity(lineContent: "verse 7 line 3"),
                                                       LineEntity(lineContent: "verse 7 line 4")]),
                                   VerseEntity(verseType: .verse,
                                               lines: [LineEntity(lineContent: "verse 8 line 1"),
                                                       LineEntity(lineContent: "verse 8 line 2"),
                                                       LineEntity(lineContent: "verse 8 line 3"),
                                                       LineEntity(lineContent: "verse 8 line 4")]),
                                   VerseEntity(verseType: .verse,
                                               lines: [LineEntity(lineContent: "verse 9 line 2"),
                                                       LineEntity(lineContent: "verse 9 line 3"),
                                                       LineEntity(lineContent: "verse 9 line 4")])])
    builder.inlineChords = InlineChordsEntity([ChordLineEntity(createChordLine("[G]Songbase version of Hymn 1151 chords"))])!
    builder.category = ["song's category"]
    builder.subcategory = ["song's subcategory"]
    builder.music = MusicEntity(["mp3": "/en/hymn/h/1151/f=mp3", "MIDI": "/en/hymn/h/1151/f=mid", "Tune (MIDI)": "/en/hymn/h/1151/f=tune"])!
    builder.pdfSheet = PdfSheetEntity(["Piano": "/en/hymn/h/1151/f=ppdf"])!
    builder.languages = LanguagesEntity([HymnIdentifier(hymnType: .cebuano, hymnNumber: "1151"),
                                         HymnIdentifier(hymnType: .chineseSupplementSimplified, hymnNumber: "216"),
                                         HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "216"),
                                         HymnIdentifier(hymnType: .dutch, hymnNumber: "35"),
                                         HymnIdentifier(hymnType: .tagalog, hymnNumber: "1151")])!
    builder.relevants = RelevantsEntity([HymnIdentifier(hymnType: .classic, hymnNumber: "2")])!
}
let classic1152Entity = HymnEntity.with { builder in
    builder.id = classic1152.songId
    builder.title = "Classic 1152"
    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 1152")])])
}
let classic2Entity = HymnEntity.with { builder in
    builder.id = classic2.songId
    builder.title = "Classic 2"
    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 2 verse 1")]),
                                   VerseEntity(verseType: .chorus, lines: [LineEntity(lineContent: "classic hymn 2 chorus")]),
                                   VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 2 verse 2")])])
}
let classic3Entity = HymnEntity.with { builder in
    builder.id = classic3.songId
    builder.title = "Classic 3"
    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 3 verse 1")]),
                                   VerseEntity(verseType: .chorus, lines: [LineEntity(lineContent: "classic hymn 3 chorus")]),
                                   VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 3 verse 2")])])
    builder.pdfSheet = PdfSheetEntity(["Piano": "/en/hymn/h/3/f=ppdf", "Text": "/en/hymn/h/3/f=gtpdf"])!
}
let classic40Entity = HymnEntity.with { builder in
    builder.id = classic40.songId
    builder.title = "Classic 40"
    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 40 verse 1")]),
                                   VerseEntity(verseType: .chorus, lines: [LineEntity(lineContent: "classic hymn 40 chorus")]),
                                   VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "classic hymn 40 verse 2")])])
    builder.pdfSheet = PdfSheetEntity(["Piano": "/en/hymn/h/40/f=ppdf", "Guitar": "/en/hymn/h/40/f=gpdf"])!
}
let chineseSupplement216Entity = HymnEntity.with { builder in
    builder.id = chineseSupplement216.songId
    builder.title = "Hymn: Minoru\'s song in Chinese"
    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "chinese verse 1 chinese line 1")])])
}
let howardHigashi2Entity = HymnEntity.with { builder in
    builder.id = howardiHigsashi2.songId
    builder.title = "Hymn: Howard Higashi\'s  second "
    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lines: [LineEntity(lineContent: "howard higashi verse 1 line 2")])])
    builder.languages = LanguagesEntity([HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "216")])!
}
let blueSongbook2Entity = HymnEntity.with { builder in
    builder.id = blueSongbook2.songId
    builder.title = "Songbase version of Hymn 1151 title"
    builder.lyrics = LyricsEntity([VerseEntity(verseType: .doNotDisplay, lineStrings: ["Songbase version of Hymn 1151 lyrics"])])
    builder.inlineChords = InlineChordsEntity([ChordLineEntity(createChordLine("[G]Songbase version of Hymn 1151 chords"))])!
}

// Separates chord line out into words.
// Note: ?: represents a non-matching group. i.e. the regex matches, but the range isn't extracted.
private let separatorPattern = "(\\S*(?:\\[.*?])\\S*|\\S+)"
private let chordsPattern = "\\[(.*?)]"

func createChordLine(_ line: String) -> [ChordWordEntity] {
    if line.isEmpty {
        return [ChordWordEntity("")]
    }
    
    let range = NSRange(line.startIndex..<line.endIndex, in: line)
    let pattern = NSRegularExpression(separatorPattern, options: [])
    let matches = pattern.matches(in: line, range: range)
    
    let chordWords = matches.compactMap { match -> String? in
        if match.numberOfRanges < 1 {
            return nil
        }
        let matchedRange = match.range(at: 0)
        if let substringRange = Range(matchedRange, in: line) {
            return String(line[substringRange])
        }
        return nil
    }
    // If there is no chord pattern found
    let chordPatternFound = line.range(of: chordsPattern, options: .regularExpression) != nil
    if !chordPatternFound {
        return chordWords.map { word in
            ChordWordEntity(String(word))
        }
    }
    
    return chordWords.map { chordWord in
        let chordPattern = NSRegularExpression(chordsPattern, options: [])
        
        var word = chordWord
        var chords = ""
        var match = chordPattern.firstMatch(in: word, range: NSRange(word.startIndex..<word.endIndex, in: word))
        while match != nil {
            if match!.numberOfRanges < 2 {
                continue
            }
            let matchedRange = Range(match!.range(at: 0), in: word) // Entire match (e.g.: [G])
            let chordRange = Range(match!.range(at: 1), in: word) // Only the chord portion (e.g.: G)
            guard let matchedRange = matchedRange, let chordRange = chordRange else {
                continue
            }
            let chord = String(word[chordRange])
            let index = matchedRange.lowerBound.utf16Offset(in: word)
            while chords.count < index {
                chords.append(" ")
            }
            chords.append(chord)
            word = word.replacingCharacters(in: matchedRange, with: "")
            match = chordPattern.firstMatch(in: word, range: NSRange(word.startIndex..<word.endIndex, in: word))
        }
        return ChordWordEntity(word, chords: chords)
    }
}

#endif

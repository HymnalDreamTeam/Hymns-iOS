import PDFKit
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class DisplayHymnSongbaseSnapshots: XCTestCase {

    var preloader: PDFLoader!

    override func setUp() {
        super.setUp()
    }

    func test_songWithChords() {
        let hymn1151Chords = [
            // Verse 1
            ChordLine("1"),
            ChordLine("[G]Drink! A river pure and clear"),
            ChordLine("That’s [G7]flowing from the throne;"),
            ChordLine("[C]Eat! The tree of life with fruits"),
            ChordLine("[G]Here there [D7]is no [G-C-G]night!"),
            ChordLine(""),
            // Chorus
            ChordLine(""),
            ChordLine("  Do come, oh, do come,"),
            ChordLine("  Says [G7]Spirit and the Bride:"),
            ChordLine("  []Do come, oh, do come,"),
            ChordLine("  Let [B7]him who thirsts and [Em]will"),
            ChordLine("  Take [G]freely the [D]water of [G]l[C]i[G]fe!"),
            ChordLine(""),
            // Verse 3
            ChordLine("2"),
            ChordLine("Christ, our river, Christ, our water,"),
            ChordLine("Springing from within;"),
            ChordLine("Christ, our tree, and Christ, the fruits,"),
            ChordLine("To be enjoyed therein,"),
            ChordLine("Christ, our day, and Christ, our light,"),
            ChordLine("and Christ, our morningstar:"),
            ChordLine("Christ, our everything!")
        ]

        let viewModel = DisplaySongbaseViewModel(chords: hymn1151Chords, guitarUrl: nil)
        let view = DisplaySongbaseView(viewModel: viewModel)
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_songWithChords_withGuitarUrl() {
        let hymn1151Chords = [
            // Verse 1
            ChordLine("1"),
            ChordLine("[G]Drink! A river pure and clear"),
            ChordLine("That’s [G7]flowing from the throne;"),
            ChordLine("[C]Eat! The tree of life with fruits"),
            ChordLine("[G]Here there [D7]is no [G-C-G]night!"),
            ChordLine(""),
            // Chorus
            ChordLine(""),
            ChordLine("  Do come, oh, do come,"),
            ChordLine("  Says [G7]Spirit and the Bride:"),
            ChordLine("  []Do come, oh, do come,"),
            ChordLine("  Let [B7]him who thirsts and [Em]will"),
            ChordLine("  Take [G]freely the [D]water of [G]l[C]i[G]fe!"),
            ChordLine(""),
            // Verse 3
            ChordLine("2"),
            ChordLine("Christ, our river, Christ, our water,"),
            ChordLine("Springing from within;"),
            ChordLine("Christ, our tree, and Christ, the fruits,"),
            ChordLine("To be enjoyed therein,"),
            ChordLine("Christ, our day, and Christ, our light,"),
            ChordLine("and Christ, our morningstar:"),
            ChordLine("Christ, our everything!")
        ]

        let viewModel = DisplaySongbaseViewModel(chords: hymn1151Chords,
                                                 guitarUrl: URL(string: "http://www.google.com")!)
        let view = DisplaySongbaseView(viewModel: viewModel)
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }
}

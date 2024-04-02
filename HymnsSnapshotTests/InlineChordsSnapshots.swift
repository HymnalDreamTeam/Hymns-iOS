import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class InlineChordsSnapshots: XCTestCase {

    func test_songWithChords() {
        let lyrics = [
            // Verse 1
            ChordLine("1"),
            ChordLine("[G]Drink! A river pure and clear[C]"),
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
        let viewModel = InlineChordsViewModel(chords: lyrics)
        let view = InlineChordsView(viewModel: viewModel)
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_songTransposed_longLine() {
        let lyrics = [
            ChordLine("[G]Drink! A river pure and clear[C] That’s [G7]flowing from the throne; [C]Eat! The tree of life with fruits [G]Here there [D7]is no [G-C-G]night!")
        ]
        let viewModel = InlineChordsViewModel(chords: lyrics)
        viewModel.transpose(10)
        let view = InlineChordsView(viewModel: viewModel)
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_songWithOutChords() {
        let lyrics = [
            // Verse 1
            ChordLine("1"),
            ChordLine("Drink! A river pure and clear"),
            ChordLine("That’s flowing from the throne;"),
            ChordLine("Eat! The tree of life with fruits"),
            ChordLine("Here there is no night!"),
            ChordLine(""),
            // Chorus
            ChordLine(""),
            ChordLine("  Do come, oh, do come,"),
            ChordLine("  Says Spirit and the Bride:"),
            ChordLine("  []Do come, oh, do come,"),
            ChordLine("  Let him who thirsts and will"),
            ChordLine("  Take []freely the []water of []l[]i[]fe!"),
            ChordLine("")
        ]
        let viewModel = InlineChordsViewModel(chords: lyrics)
        let view = InlineChordsView(viewModel: viewModel)
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }
}

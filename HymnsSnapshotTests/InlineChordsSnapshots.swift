import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class InlineChordsSnapshots: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_songWithChords() {
        let lyrics = [
            // Verse 1
            ChordLineEntity(createChordLine("1")),
            ChordLineEntity(createChordLine("[G]Drink! A river pure and clear[C]")),
            ChordLineEntity(createChordLine("That’s [G7]flowing from the throne;")),
            ChordLineEntity(createChordLine("[C]Eat! The tree of life with fruits")),
            ChordLineEntity(createChordLine("[G]Here there [D7]is no [G-C-G]night!")),
            ChordLineEntity(createChordLine("")),
            // Chorus
            ChordLineEntity(createChordLine("")),
            ChordLineEntity(createChordLine("  Do come, oh, do come,")),
            ChordLineEntity(createChordLine("  Says [G7]Spirit and the Bride:")),
            ChordLineEntity(createChordLine("  []Do come, oh, do come,")),
            ChordLineEntity(createChordLine("  Let [B7]him who thirsts and [Em]will")),
            ChordLineEntity(createChordLine("  Take [G]freely the [D]water of [G]l[C]i[G]fe!")),
            ChordLineEntity(createChordLine("")),
            // Verse 3
            ChordLineEntity(createChordLine("2")),
            ChordLineEntity(createChordLine("Christ, our river, Christ, our water,")),
            ChordLineEntity(createChordLine("Springing from within;")),
            ChordLineEntity(createChordLine("Christ, our tree, and Christ, the fruits,")),
            ChordLineEntity(createChordLine("To be enjoyed therein,")),
            ChordLineEntity(createChordLine("Christ, our day, and Christ, our light,")),
            ChordLineEntity(createChordLine("and Christ, our morningstar:")),
            ChordLineEntity(createChordLine("Christ, our everything!"))
        ]
        let viewModel = InlineChordsViewModel(chordLines: lyrics)
        let view = ScrollView(showsIndicators: false) {
            InlineChordsView(viewModel: viewModel)
        }
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_songTransposed_longLine() {
        let lyrics = [
            ChordLineEntity(createChordLine("[G]Drink! A river pure and clear[C] That’s [G7]flowing from the throne; [C]Eat! The tree of life with fruits [G]Here there [D7]is no [G-C-G]night!"))
        ]
                      let viewModel = InlineChordsViewModel(chordLines: lyrics)
        viewModel.transpose(10)
        let view = ScrollView(showsIndicators: false) {
            InlineChordsView(viewModel: viewModel)
        }
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_songWithOutChords() {
        let lyrics = [
            // Verse 1
            ChordLineEntity(createChordLine("1")),
            ChordLineEntity(createChordLine("Drink! A river pure and clear")),
            ChordLineEntity(createChordLine("That’s flowing from the throne;")),
            ChordLineEntity(createChordLine("Eat! The tree of life with fruits")),
            ChordLineEntity(createChordLine("Here there is no night!")),
            ChordLineEntity(createChordLine("")),
            // Chorus
            ChordLineEntity(createChordLine("")),
            ChordLineEntity(createChordLine("  Do come, oh, do come,")),
            ChordLineEntity(createChordLine("  Says Spirit and the Bride:")),
            ChordLineEntity(createChordLine("  []Do come, oh, do come,")),
            ChordLineEntity(createChordLine("  Let him who thirsts and will")),
            ChordLineEntity(createChordLine("  Take []freely the []water of []l[]i[]fe!")),
            ChordLineEntity(createChordLine(""))
        ]
        let viewModel = InlineChordsViewModel(chordLines: lyrics)
        let view = ScrollView(showsIndicators: false) {
            InlineChordsView(viewModel: viewModel)
        }
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }
}

import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class ChordsSnapshots: XCTestCase {

    var viewModel: ChordWordViewModel!

    func test_chordWord_nilChords() {
        viewModel = ChordWordViewModel(word: "word", chords: nil)
        assertVersionedSnapshot(
            matching: ChordWordView(viewModel),
            as: .swiftUiImage())
    }

    func test_chordWord_emptyChords() {
        viewModel = ChordWordViewModel(word: "word", chords: "")
        assertVersionedSnapshot(
            matching: ChordWordView(viewModel),
            as: .swiftUiImage())
    }

    func test_chordWord_blankChords() {
        viewModel = ChordWordViewModel(word: "word", chords: "")
        assertVersionedSnapshot(
            matching: ChordWordView(viewModel),
            as: .swiftUiImage())
    }

    func test_chordWord_chords() {
        viewModel = ChordWordViewModel(word: "word", chords: "D#")
        assertVersionedSnapshot(
            matching: ChordWordView(viewModel),
            as: .swiftUiImage())
    }
}

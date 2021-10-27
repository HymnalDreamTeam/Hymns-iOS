import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class SoundCloudSnapshots: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_soundCloudPlayer() {
        var published = Published<String?>(initialValue: nil)
        let viewModel = SoundCloudPlayerViewModel(dialogModel: .constant(nil), title: published.projectedValue)
        viewModel.showPlayer = true
        assertVersionedSnapshot(matching: SoundCloudPlayer(viewModel: viewModel).ignoresSafeArea(), as: .image(layout: .fixed(width: 400, height: 200)))
    }

    func test_soundCloudPlayer_a11ySize() {
        var published = Published<String?>(initialValue: nil)
        let viewModel = SoundCloudPlayerViewModel(dialogModel: .constant(nil), title: published.projectedValue)
        viewModel.showPlayer = true
        let player = SoundCloudPlayer(viewModel: viewModel).ignoresSafeArea().environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        assertVersionedSnapshot(matching: player, as: .image(layout: .fixed(width: 600, height: 200)))
    }

    func test_defaultState() {
        let viewModel = SoundCloudViewModel(url: URL(string: "http://www.example.com")!)
        assertVersionedSnapshot(matching: SoundCloudView(dialogModel: .constant(nil), soundCloudPlayer: .constant(nil), viewModel: viewModel).ignoresSafeArea(),
                                as: .swiftUiImage(precision: 0.99), timeout: 30)
    }

    func test_minimizeCaret() {
        let viewModel = SoundCloudViewModel(url: URL(string: "https://www.example.com")!)
        viewModel.showMinimizeCaret = true
        // Set the timer connection to nil or else it causes the caret to be flaky
        viewModel.timerConnection = nil
        assertVersionedSnapshot(matching: SoundCloudView(dialogModel: .constant(nil), soundCloudPlayer: .constant(nil), viewModel: viewModel).ignoresSafeArea(),
                                as: .swiftUiImage(precision: 0.99), timeout: 30)
    }

    func test_minimizeCaretAndToolTip() {
        let viewModel = SoundCloudViewModel(url: URL(string: "https://www.example.com")!)
        viewModel.showMinimizeCaret = true
        viewModel.showMinimizeToolTip = true
        // Set the timer connection to nil or else it causes the caret/tooltip to be flaky
        viewModel.timerConnection = nil
        assertVersionedSnapshot(matching: SoundCloudView(dialogModel: .constant(nil), soundCloudPlayer: .constant(nil), viewModel: viewModel).ignoresSafeArea(),
                                as: .swiftUiImage(precision: 0.99), timeout: 30)
    }
}

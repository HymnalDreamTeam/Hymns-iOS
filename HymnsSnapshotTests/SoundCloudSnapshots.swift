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
        let viewModel = SoundCloudPlayerViewModel(dialogModel: .constant(nil))
        viewModel.showPlayer = true
        assertSnapshot(matching: SoundCloudPlayer(viewModel: viewModel), as: .image(layout: .fixed(width: 400, height: 200)))
    }

    func test_soundCloudView() {
        let viewModel = SoundCloudViewModel()
        viewModel.showSoundCloudMinimizeTooltip = false
        assertSnapshot(matching: SoundCloudView(dialogModel: .constant(nil),
                                                soundCloudPlayer: .constant(nil),
                                                viewModel: viewModel,
                                                url: URL(string: "http://www.example.com")!),
                       as: .swiftUiImage(precision: 0.99))
    }

    func test_soundCloudView_withToolTip() {
        let viewModel = SoundCloudViewModel()
        viewModel.showSoundCloudMinimizeTooltip = true
        assertSnapshot(matching: SoundCloudView(dialogModel: .constant(nil),
                                                soundCloudPlayer: .constant(nil),
                                                viewModel: viewModel,
                                                url: URL(string: "http://www.example.com")!),
                       as: .swiftUiImage(precision: 0.99))
    }
}

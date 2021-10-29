import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class ToolTipSnapshots: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_toolTipShape_filled() {
        assertVersionedSnapshot(
            matching: ToolTipShape(cornerRadius: 15, toolTipMidX: 300).fill().ignoresSafeArea(),
            as: .image())
    }

    func test_toolTipShape_oulined() {
        assertVersionedSnapshot(
            matching: ToolTipShape(cornerRadius: 15, toolTipMidX: 300).stroke().ignoresSafeArea(),
            as: .image())
    }

    func test_toolTipView_offset() {
        let toolTip = ToolTipView(tapAction: {}, label: {
            Text("tool tip text").padding()
        }, configuration:
            ToolTipConfiguration(cornerRadius: 10,
                                 arrowPosition: ToolTipConfiguration.ArrowPosition(midX: 30, alignmentType: .offset),
                                 arrowHeight: 7)).ignoresSafeArea()
        assertVersionedSnapshot(matching: toolTip, as: .image(layout: .fixed(width: 250, height: 100)))
    }

    func test_toolTipView_percentage() {
        let toolTip =             ToolTipView(tapAction: {}, label: {
            Text("tool tip text").padding()
        }, configuration:
            ToolTipConfiguration(cornerRadius: 10,
                                 arrowPosition: ToolTipConfiguration.ArrowPosition(midX: 0.7, alignmentType: .percentage),
                                 arrowHeight: 7)).ignoresSafeArea()
        assertVersionedSnapshot(matching: toolTip, as: .image(layout: .fixed(width: 250, height: 100)))
    }
}

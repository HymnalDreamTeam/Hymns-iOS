import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class ToolTipSnapshots: XCTestCase {

    func test_toolTipShape_filled() {
        assertVersionedSnapshot(
            matching: ToolTipShape(cornerRadius: 15, direction: .up, toolTipMidX: 300).fill().ignoresSafeArea(),
            as: .image())
    }

    func test_toolTipShape_oulined() {
        assertVersionedSnapshot(
            matching: ToolTipShape(cornerRadius: 15, direction: .up, toolTipMidX: 300).stroke().ignoresSafeArea(),
            as: .image())
    }

    func test_toolTipView_offset() {
        let toolTip = ToolTipView(tapAction: {}, label: {
            Text("tool tip text").padding()
        }, configuration:
            ToolTipConfiguration(arrowConfiguration:
                                    ToolTipConfiguration.ArrowConfiguration(
                                        height: 7,
                                        position:
                                            ToolTipConfiguration.ArrowConfiguration.Position(
                                                midX: 30, alignmentType: .offset)),
                                 bodyConfiguration: ToolTipConfiguration.BodyConfiguration(cornerRadius: 10))).ignoresSafeArea()
        assertVersionedSnapshot(matching: toolTip, as: .image(layout: .fixed(width: 250, height: 100)))
    }

    func test_toolTipView_percentage() {
        let toolTip = ToolTipView(tapAction: {}, label: {
            Text("tool tip text").padding()
        }, configuration:
            ToolTipConfiguration(arrowConfiguration:
                                    ToolTipConfiguration.ArrowConfiguration(
                                        height: 7,
                                        position:
                                            ToolTipConfiguration.ArrowConfiguration.Position(
                                                midX: 0.7, alignmentType: .percentage)),
                                 bodyConfiguration: ToolTipConfiguration.BodyConfiguration(cornerRadius: 10))).ignoresSafeArea()
        assertVersionedSnapshot(matching: toolTip, as: .image(layout: .fixed(width: 250, height: 100)))
    }

    func test_toolTipView_topAlignment() {
        let toolTip = ToolTipView(tapAction: {}, label: {
            Text("tool tip text").padding()
        }, configuration:
            ToolTipConfiguration(
                alignment: ToolTipConfiguration.Alignment(horizontal: .leading, vertical: .top),
                arrowConfiguration:
                    ToolTipConfiguration.ArrowConfiguration(
                        height: 7,
                        position:
                            ToolTipConfiguration.ArrowConfiguration.Position(
                                midX: 0.7, alignmentType: .percentage)),
                bodyConfiguration: ToolTipConfiguration.BodyConfiguration(cornerRadius: 10))).ignoresSafeArea()
        assertVersionedSnapshot(matching: toolTip, as: .image(layout: .fixed(width: 250, height: 100)))
    }
}

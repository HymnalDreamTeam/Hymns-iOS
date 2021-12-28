import SnapshotTesting
import SwiftUI
import XCTest

extension Snapshotting where Value: SwiftUI.View, Format == UIImage {

    /**
     * Allows for Snapshot testing for SwiftUI views.
     * https://github.com/V8tr/SnapshotTestingSwiftUI/blob/master/SnapshotTestingSwiftUITests/SnapshotTesting%2BSwiftUI.swift
     */
    static func swiftUiImage(
        drawHierarchyInKeyWindow: Bool = false,
        precision: Float = 1,
        size: CGSize? = nil,
        traits: UITraitCollection = .init()) -> Snapshotting {
        Snapshotting<UIViewController, UIImage>.image(
            drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
            precision: precision,
            size: size,
            traits: traits)
            .pullback(UIHostingController.init(rootView:))
    }
}

/**
 * Asserts a snapshot based on the current OS system version.
 */
public func assertVersionedSnapshot<Value, Format>(
    matching value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String? = nil,
    record recording: Bool = false,
    snapshotDirectory: String? = nil,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line) {

    let osVersion = UIDevice.current.systemVersion
    let fileUrl = URL(string: "\(file)")!
    let fileName = fileUrl.deletingPathExtension().lastPathComponent
    let defaultSnapshotDirectory = fileUrl
        .deletingLastPathComponent()
        .appendingPathComponent("__Snapshots__")
        .appendingPathComponent(osVersion)
        .appendingPathComponent(fileName)
        .absoluteString

    let failure = verifySnapshot(
        matching: try value(),
        as: snapshotting,
        named: name,
        record: recording,
        snapshotDirectory: snapshotDirectory ?? defaultSnapshotDirectory,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )
    guard let message = failure else { return }
    XCTFail(message, file: file, line: line)
}

extension SwiftUI.View {
    func referenceFrame(width: CGFloat, height: CGFloat) -> some View {
        self.frame(width: width, height: height)
    }
}

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
public func assertVersionedSnapshot<Value, Format>(matching value: @autoclosure () throws -> Value,
                                                   as snapshotting: Snapshotting<Value, Format>,
                                                   record recording: Bool = false,
                                                   timeout: TimeInterval = 5,
                                                   file: StaticString = #file,
                                                   testName: String = #function,
                                                   line: UInt = #line) {
    let osVersion = UIDevice.current.systemVersion
    let fileUrl = URL(string: "\(file)")!
    let fileName = fileUrl.deletingPathExtension().lastPathComponent

    let locales = [Locale(identifier: "en_US")]
    for locale in locales {
        let snapshotDirectory: String
        // Check bundled snapshot so it will work with Xcode Cloud
        // https://jaanus.com/snapshot-testing-xcode-cloud/
        // https://gist.github.com/jaanus/7e14b31f7f445435aadac09d24397da8
        if !recording,
           let bundledSnapshotDirectory = Bundle.main.resourceURL?
            .appendingPathComponent("PlugIns")
            .appendingPathComponent("HymnsSnapshotTests.xctest")
            .appendingPathComponent("__Snapshots__")
            .appendingPathComponent(osVersion)
            .appendingPathComponent(fileName)
            .path(percentEncoded: false),
           case let bundledSnapshot = "\(bundledSnapshotDirectory)\(sanitizePathComponent(testName)).\(locale.identifier).png",
           FileManager.default.fileExists(atPath: bundledSnapshot) {
            snapshotDirectory = bundledSnapshotDirectory
        } else {
            snapshotDirectory = fileUrl
                .deletingLastPathComponent()
                .appendingPathComponent("__Snapshots__")
                .appendingPathComponent(osVersion)
                .appendingPathComponent(fileName)
                .absoluteString
        }
        if let failureMessage = verifySnapshot(
            of: try value(),
            as: snapshotting,
            named: locale.identifier,
            record: recording,
            snapshotDirectory: snapshotDirectory,
            timeout: timeout,
            file: file,
            testName: testName,
            line: line) {
            XCTFail(failureMessage, file: file, line: line)
        }
    }
}

// Copied from swift-snapshot-testing
func sanitizePathComponent(_ string: String) -> String {
  return string
    .replacingOccurrences(of: "\\W+", with: "-", options: .regularExpression)
    .replacingOccurrences(of: "^-|-$", with: "", options: .regularExpression)
}

extension SwiftUI.View {
    func referenceFrame(width: CGFloat, height: CGFloat) -> some View {
        self.frame(width: width, height: height)
    }
}

extension SwiftUI.View {
    func toViewController() -> UIViewController {
        let viewController = UIHostingController(rootView: self)
        viewController.view.frame = UIScreen.main.bounds
        return viewController
    }
}

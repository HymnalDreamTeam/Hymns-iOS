import PreviewSnapshots
import PreviewSnapshotsTesting
import SwiftUI
import XCTest

extension PreviewSnapshots {

    public func assertVersionedSnapshots<Format>(
        as snapshotting: Snapshotting<AnyView, Format>,
        named name: String? = nil,
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
                for configuration in configurations {
                    let snapshotName = configuration.versionedSnapshotName(locale: locale)
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
                       case let bundledSnapshot = "\(bundledSnapshotDirectory)\(testName)",
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
                        of: configure(configuration.state),
                        as: snapshotting,
                        named: snapshotName,
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
        }
}

extension PreviewSnapshots.Configuration {
    /// Construct a snapshot name based on the configuration name and an optional prefix.
    func versionedSnapshotName(locale: Locale) -> String {
        "\(sanitizePathComponent(name)).\(locale.identifier)"
    }
}

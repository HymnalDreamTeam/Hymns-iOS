import Foundation

extension Bundle {

    var releaseVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Not found"
    }

    var buildVersion: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Not found"
    }
}

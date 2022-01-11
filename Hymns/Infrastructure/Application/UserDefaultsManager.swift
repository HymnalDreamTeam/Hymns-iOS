import Combine
import Foundation
import SwiftUI

/**
 * Wrapper class for managing `UserDefaults`
 */
class UserDefaultsManager {

    let fontSizeSubject: CurrentValueSubject<Float, Never>

    var fontSize: Float {
        didSet {
            fontSizeSubject.send(fontSize)
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }

    @UserDefault("show_splash_animation", defaultValue: true) var showSplashAnimation: Bool
    @UserDefault("repeat_chorus", defaultValue: false) var shouldRepeatChorus: Bool

    init() {
        // Migrate font size to be a float instead of a string
        let initialFontSize: Float
        switch UserDefaults.standard.string(forKey: "fontSize") {
        case "Normal":
            initialFontSize = 17.0
        case "Large":
            initialFontSize = 20.0
        case "Extra Large":
            initialFontSize = 24.0
        default:
            // "Normal" falls into this case.
            if UserDefaults.standard.float(forKey: "fontSize") != 0.0 {
                initialFontSize = UserDefaults.standard.float(forKey: "fontSize")
            } else {
                initialFontSize = 15.0
            }
        }
        UserDefaults.standard.set(initialFontSize, forKey: "fontSize")

        self.fontSize = initialFontSize
        self.fontSizeSubject = CurrentValueSubject<Float, Never>(initialFontSize)
    }
}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

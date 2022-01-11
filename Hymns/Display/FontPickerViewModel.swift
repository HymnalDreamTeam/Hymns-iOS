import AVFoundation
import Combine
import RealmSwift
import Resolver
import SwiftUI

class FontPickerViewModel: ObservableObject {

    @Published var fontSize: Float {
        willSet {
            userDefaultsManager.fontSize = fontSize
        }
    }

    private let userDefaultsManager: UserDefaultsManager

    init(userDefaultsManager: UserDefaultsManager = Resolver.resolve()) {
        self.fontSize = userDefaultsManager.fontSize
        self.userDefaultsManager = userDefaultsManager
    }

    func updateFontSize(_ fontSize: Float) {
        userDefaultsManager.fontSize = fontSize
    }
}

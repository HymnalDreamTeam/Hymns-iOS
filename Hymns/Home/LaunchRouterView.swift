import Resolver
import SwiftUI

struct LaunchRouterView: View {

    private let userDefaultsManager: UserDefaultsManager

    @State var showSplashAnimation: Bool {
        willSet {
            userDefaultsManager.showSplashAnimation = newValue
        }
    }

    init(userDefaultsManager: UserDefaultsManager = Resolver.resolve()) {
        self.userDefaultsManager = userDefaultsManager
        self._showSplashAnimation = .init(initialValue: userDefaultsManager.showSplashAnimation)
    }

    var body: some View {
        Group { () -> AnyView in
            if showSplashAnimation {
                return LottieView(fileName: "firstLaunchAnimation")
                    .onAppear {
                        // inspiration: https://www.raywenderlich.com/4503153-how-to-create-a-splash-screen-with-swiftui
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                            self.showSplashAnimation = false
                        }
                }.eraseToAnyView()
            } else {
                if #available(iOS 16, *) {
                    return HomeContainerView().eraseToAnyView()
                } else {
                    return HomeContainerView15().eraseToAnyView()
                }
            }
        }
    }
}

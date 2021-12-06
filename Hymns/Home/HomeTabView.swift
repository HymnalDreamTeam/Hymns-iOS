import SwiftUI

struct HomeTabView: View {

    @Binding var selectedTab: HomeTab

    var body: some View {
        HStack {
            Button(action: {
                self.selectedTab = .home
            }, label: {
                HomeTab.home.getImage(selectedTab == HomeTab.home)
                    .padding()
                    .foregroundColor(self.selectedTab == .home ? .accentColor : .secondary)
                    .font(.system(size: buttonSize))
                    .accessibility(label: Text(NSLocalizedString("Home tab", comment: "Home tab description")))
            })
            Spacer()
            Button(action: {
                self.selectedTab = .browse
            }, label: {
                HomeTab.browse.getImage(selectedTab == HomeTab.browse)
                    .padding()
                    .foregroundColor(self.selectedTab == .browse ? .accentColor : .secondary)
                    .font(.system(size: buttonSize))
                    .accessibility(label: Text(NSLocalizedString("Browse tab", comment: "Browse tab description")))
            })
            Spacer()
            Button(action: {
                self.selectedTab = .favorites
            }, label: {
                HomeTab.favorites.getImage(selectedTab == HomeTab.favorites)
                    .padding()
                    .foregroundColor(self.selectedTab == .favorites ? .accentColor : .secondary)
                    .font(.system(size: buttonSize))
                    .accessibility(label: Text(NSLocalizedString("Favorites tab", comment: "Favorites tab description")))
            })
            Spacer()
            Button(action: {
                self.selectedTab = .settings
            }, label: {
                HomeTab.settings.getImage(selectedTab == HomeTab.settings)
                    .padding()
                    .foregroundColor(self.selectedTab == .settings ? .accentColor : .secondary)
                    .font(.system(size: buttonSize))
                    .accessibility(label: Text(NSLocalizedString("Settings tab", comment: "Settings tab description")))
            })
        }
    }
}

#if DEBUG
struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeTabView(selectedTab: .constant(.home))
        }
    }
}
#endif

import SwiftUI

struct CustomTitle: View {
    var title: String

    init(title: String) {
        self.title = title
    }

    var body: some View {
        HStack {
            Text(self.title).customTitleLayout()
            Spacer()
        }
    }
}

#if DEBUG
struct CustomTitle_Previews: PreviewProvider {
    static var previews: some View {
        CustomTitle(title: NSLocalizedString("Favorites", comment: "")).previewLayout(.fixed(width: 200, height: 50))
    }
}
#endif

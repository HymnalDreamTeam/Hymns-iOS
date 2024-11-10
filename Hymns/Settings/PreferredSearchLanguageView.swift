import Foundation
import Resolver
import SwiftUI

struct PreferredSearchLanguageView: View {

    @AppStorage("preferred_search_language") var preferredSearchLanguage: Language = .english
    @AppStorage("show_preferred_search_language_announcement") var showPreferredSearchLanguageAnnouncement = true

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Preferred search language", comment: "Title for the settings item to change the preferred search language.")
                Text("Language of hymns displayed when only a number is entered into the search bar.",
                     comment: "Subtitle for the settings item to change the preferred search language.")
                .font(.caption)
            }
            Spacer()
            Picker("Preferred search language", selection: $preferredSearchLanguage) {
                ForEach(Language.allCases) { language in
                    Text(language.displayTitle).tag(language)
                }
            }
        }.toolTip(tapAction: {
            showPreferredSearchLanguageAnnouncement = false
        }, label: {
            HStack(alignment: .center, spacing: CGFloat.zero) {
                Image(systemName: "xmark").padding()
                Text("You can change your preferred search language!",
                     comment: "Text of the tool tip announcing the preferred search language feature.")
                .font(.caption).padding(.trailing)
            }
        }, configuration: ToolTipConfiguration(
            alignment: ToolTipConfiguration.Alignment(
                horizontal: .trailing, vertical: .top),
            arrowConfiguration:
                ToolTipConfiguration.ArrowConfiguration(
                    height: 10,
                    position:
                        ToolTipConfiguration.ArrowConfiguration.Position(
                            midX: 0.9, alignmentType: .percentage)),
            bodyConfiguration:
                ToolTipConfiguration.BodyConfiguration(
                    cornerRadius: 10,
                    size: ToolTipConfiguration.BodyConfiguration.Size(height: 0.9, width: 0.9, sizeType: .relative))),
                  shouldShow: $showPreferredSearchLanguageAnnouncement)
        .padding()
    }
}

#if DEBUG
struct PreferredSearchLanguageView_Previews: PreviewProvider {
    static var previews: some View {
        return PreferredSearchLanguageView()
    }
}
#endif

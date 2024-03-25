
import Foundation
import Resolver
import SwiftUI

enum DefaultSearchType: Int {
    case english
    case chinese
    case chineseSimplified
    case cebuano
    case tagalog
    case dutch
    case german
    case french
    case spanish
    case portuguese
    case korean
    case japanese
    case indonesian
    case farsi
    case russian

    static let allValues = [
        english, chinese, chineseSimplified, cebuano,
        tagalog, dutch, german, french, spanish, portuguese,
        korean, japanese, indonesian, farsi, russian
    ]

    var displayValue: String {
        hymnType.displayTitle
    }

    var hymnType: HymnType {
        switch self {
        case .english:
            return .classic
        case .chinese:
            return .chinese
        case .chineseSimplified:
            return .chineseSimplified
        case .cebuano:
            return .cebuano
        case .tagalog:
            return .tagalog
        case .dutch:
            return .dutch
        case .german:
            return .liederbuch
        case .french:
            return .french
        case .spanish:
            return .spanish
        case .portuguese:
            return .portuguese
        case .korean:
            return .korean
        case .japanese:
            return .japanese
        case .indonesian:
            return .indonesian
        case .farsi:
            return .farsi
        case .russian:
            return .russian
        }
    }

    var language: Language {
        switch self {
        case .english:
            return .english
        case .chinese:
            return .chinese
        case .chineseSimplified:
            return .chineseSimplified
        case .cebuano:
            return .cebuano
        case .tagalog:
            return .tagalog
        case .dutch:
            return .dutch
        case .german:
            return .german
        case .french:
            return .french
        case .spanish:
            return .spanish
        case .portuguese:
            return .portuguese
        case .korean:
            return .korean
        case .japanese:
            return .japanese
        case .indonesian:
            return .indonesian
        case .farsi:
            return .farsi
        case .russian:
            return .russian
        }
    }
}

extension DefaultSearchType: Identifiable {
    var id: String { String(rawValue) }
}

struct DefaultSearchTypeView: View {

    @AppStorage("default_search_type") var defaultSearchType: DefaultSearchType = .english
    @AppStorage("show_default_search_type_announcement") var showDefaultSearchTypeAnnouncement = true

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Default search language", comment: "Title for the settings item to change the default search language.")
                Text("Language to search by when only a number is entered into the search bar", comment: "Subtitle for the settings item to change the default search language.")
                    .font(.caption)
            }
            Spacer()
            Picker("Default search type", selection: $defaultSearchType) {
                ForEach(DefaultSearchType.allValues) { defaultSearchType in
                    Text(defaultSearchType.language.displayTitle).tag(defaultSearchType)
                }
            }
        }.toolTip(tapAction: {
            showDefaultSearchTypeAnnouncement = false
        }, label: {
            HStack(alignment: .center, spacing: CGFloat.zero) {
                Image(systemName: "xmark").padding()
                Text("You can change the default language in search!",
                     comment: "Text of the tool tip announcing the default search language feature")
                .font(.caption).padding(.trailing)
            }
        }, configuration: ToolTipConfiguration(arrowConfiguration:
                                                ToolTipConfiguration.ArrowConfiguration(
                                                    height: 10,
                                                    position:
                                                        ToolTipConfiguration.ArrowConfiguration.Position(
                                                            midX: 0.9, alignmentType: .percentage)),
                                               bodyConfiguration:
                                                ToolTipConfiguration.BodyConfiguration(
                                                    cornerRadius: 10)),
                            shouldShow: $showDefaultSearchTypeAnnouncement)
        .padding()
    }
}

#if DEBUG
struct DefaultSearchTypeView_Previews: PreviewProvider {
    static var previews: some View {
        return DefaultSearchTypeView()
    }
}
#endif

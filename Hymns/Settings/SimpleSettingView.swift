import Prefire
import SwiftUI

struct SimpleSettingView: View {

    let viewModel: SimpleSettingViewModel

    var body: some View {
        Button(action: viewModel.action, label: {
            VStack(alignment: .leading, spacing: 5) {
                Text(viewModel.title).font(.callout)
                viewModel.subtitle.map { Text($0).font(.caption) }
            }
        }).padding().foregroundColor(.primary)
    }
}

#if DEBUG
struct SimpleSettingView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let theme = SimpleSettingViewModel(title: "Theme", subtitle: "Using system theme", action: {})
        let privacyPolicy = SimpleSettingViewModel(title: "Privacy policy", action: {})
        return Group {
            SimpleSettingView(viewModel: privacyPolicy).previewDisplayName("no subtitle")
            SimpleSettingView(viewModel: theme).previewDisplayName("with subtitle")
        }.previewLayout(.sizeThatFits)
    }
}
#endif

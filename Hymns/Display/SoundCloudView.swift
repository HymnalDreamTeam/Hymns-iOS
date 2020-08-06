import SwiftUI

struct SoundCloudView: View {
    @Binding var showSoundCloud: Bool
    @Binding var soundCloudinitiated: Bool
    var searchTitle: String

    var body: some View {
        Group<AnyView> {
            guard let url =
                "https://soundcloud.com/search?q=\(self.searchTitle)".toEncodedUrl else {
                    return ErrorView().eraseToAnyView()
            }
            return VStack {
                HStack(spacing: 10) {
                    Button(action: {
                        self.showSoundCloud = false
                        self.soundCloudinitiated = false
                    }, label: {
                        Image(systemName: "xmark.square.fill").accentColor(.red)
                    })
                    Button(action: {
                        self.showSoundCloud.toggle()
                    }, label: {
                        Image(systemName: "minus.square.fill").accentColor(.accentColor)
                    })
                    Spacer()
                }.padding()
                ZStack {
                    SoundCloudWebView(url: url).eraseToAnyView()
                }
            }
            .eraseToAnyView()
        }
    }
}

struct SoundCloudView_Previews: PreviewProvider {
    static var previews: some View {
        SoundCloudView(showSoundCloud: .constant(true), soundCloudinitiated: .constant(true), searchTitle: "Jesus is Lord")
    }
}

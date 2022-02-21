import SwiftUI

/// Search Bar for devices running earlier than iOS 15. This is a workaround because of https://developer.apple.com/forums/thread/688678, where @FocusState causes
/// iOS 14 devices to crash even though it's wrapped with @available. Delete this class when the minimum supported iOS version is iOS 15+.
struct OldSearchBar: View {

    @Binding var searchText: String
    @Binding var searchActive: Bool
    let placeholderText: String

    var body: some View {
        HStack {
            HStack {
                TextField(placeholderText, text: $searchText).foregroundColor(.primary).padding(.leading, 6)
                if !self.searchText.isEmpty {
                    Button(action: {
                        self.searchText = ""
                    }, label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: smallButtonSize))
                    })
                }
            }.onTapGesture {
                if !self.searchActive {
                    withAnimation {
                        self.searchActive = true
                    }
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(Color("darkModeSearchSymbol"))
            .background(Color("darkModeSearchBackgrouund"))
            .cornerRadius(CGFloat(integerLiteral: 10))

            if searchActive {
                Button(NSLocalizedString("Cancel", comment: "Button to cancel active search.")) {
                    // this must be placed before the other commands here
                    UIApplication.shared.endEditing(true)
                    if !self.searchText.isEmpty {
                        self.searchText = ""
                    }
                    withAnimation {
                        self.searchActive = false
                    }
                }.font(.system(size: smallButtonSize))
                .foregroundColor(Color(.systemBlue))
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .trailing)))
                .animation(.easeOut(duration: 0.2))
            }
        }
    }
}

#if DEBUG
struct OldSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        let placeholderText = "Search by numbers or words"
        var emptySearchText = ""
        let emptySearchTextBinding = Binding<String>(
            get: {emptySearchText},
            set: {emptySearchText = $0})
        var searchInactive = false
        let searchInactiveBinding = Binding<Bool>(
            get: {searchInactive},
            set: {searchInactive = $0})
        let searchInactiveBar = OldSearchBar(searchText: emptySearchTextBinding, searchActive: searchInactiveBinding,
                                             placeholderText: placeholderText)
        var searchActive = true
        let searchActiveBinding = Binding<Bool>(
            get: {searchActive},
            set: {searchActive = $0})
        let searchActiveBar = OldSearchBar(searchText: emptySearchTextBinding, searchActive: searchActiveBinding,
                                           placeholderText: placeholderText)
        var searchText = "Who let the dogs out?"
        let searchTextBinding = Binding<String>(
            get: {searchText},
            set: {searchText = $0})
        let searchTextBar = OldSearchBar(searchText: searchTextBinding, searchActive: searchActiveBinding,
                                         placeholderText: placeholderText)
        return
            Group {
                searchInactiveBar.previewDisplayName("inactive")
                searchActiveBar.previewDisplayName("active")
                searchTextBar.previewDisplayName("with search text")
            }.previewLayout(.sizeThatFits)
    }
}
#endif

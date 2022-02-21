import SwiftUI

/**
 * Custom search bar that will animate in a `Cancel` button when activated/selected.
 * https://stackoverflow.com/questions/56490963/how-to-display-a-search-bar-with-swiftui
 */
@available(iOS 15, *)
struct SearchBar: View {

    @Binding var searchText: String
    @Binding var searchActive: Bool
    let placeholderText: String

    @State var searchMode: SearchMode = SearchMode(rawValue: UserDefaults.standard.integer(forKey: "search_mode")) ?? .keyword {
        willSet {
            UserDefaults.standard.set(newValue.rawValue, forKey: "search_mode")
        }
    }
    // Use FocusState here as a workaround since SwiftUI doesn't yet provide a way to reload the keyboard on a keyboard type change.
    // https://stackoverflow.com/questions/70934381/reload-textfield-keyboard-in-swiftui
    @FocusState var focused

    var body: some View {
        HStack {
            HStack {
                if searchActive {
                    Button(action: {
                        focused = false
                        if searchMode == .keyword {
                            searchMode = .number
                        } else {
                            searchMode = .keyword
                        }
                        focused = true
                    }, label: {
                        if searchMode == .keyword {
                            Image(systemName: "textformat.abc").foregroundColor(.accentColor)
                        } else {
                            Image(systemName: "textformat.123").foregroundColor(.accentColor)
                        }
                    }).font(.system(size: smallButtonSize)).padding(.leading, 6)
                }
                TextField(placeholderText, text: $searchText)
                    .padding(.leading, searchActive ? 0 : 6)
                    .keyboardType(searchMode == .keyword ? .asciiCapable : .asciiCapableNumberPad)
                    .foregroundColor(.primary)
                    .focused($focused)
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

@available(iOS 15, *)
enum SearchMode: Int {
    case keyword
    case number
}

#if DEBUG
@available(iOS 15, *)
struct SearchBar_Previews: PreviewProvider {
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
        let searchInactiveBar = SearchBar(searchText: emptySearchTextBinding, searchActive: searchInactiveBinding, placeholderText: placeholderText)
        var searchActive = true
        let searchActiveBinding = Binding<Bool>(
            get: {searchActive},
            set: {searchActive = $0})
        let searchActiveBar = SearchBar(searchText: emptySearchTextBinding, searchActive: searchActiveBinding, placeholderText: placeholderText)
        var searchText = "Who let the dogs out?"
        let searchTextBinding = Binding<String>(
            get: {searchText},
            set: {searchText = $0})
        let searchTextBar = SearchBar(searchText: searchTextBinding, searchActive: searchActiveBinding, placeholderText: placeholderText)
        return
            Group {
                searchInactiveBar.previewDisplayName("inactive")
                searchActiveBar.previewDisplayName("active")
                searchTextBar.previewDisplayName("with search text")
            }.previewLayout(.sizeThatFits)
    }
}
#endif

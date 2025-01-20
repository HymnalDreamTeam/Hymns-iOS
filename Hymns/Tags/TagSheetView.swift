import Prefire
import Resolver
import SwiftUI

struct TagSheetView: View {

    @ObservedObject private var viewModel: TagSheetViewModel
    @State private var tagName: String
    @State private var tagColor: TagColor
    var sheet: Binding<DisplayHymnSheet?>

    init(viewModel: TagSheetViewModel, sheet: Binding<DisplayHymnSheet?>,
         tagName: String = "", tagColor: TagColor = .none) {
        self.viewModel = viewModel
        self.sheet = sheet
        self.tagName = tagName
        self.tagColor = tagColor
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Button(action: {
                        self.sheet.wrappedValue = nil
                    }, label: {
                        Image(systemName: "xmark").foregroundColor(.primary).padding([.horizontal, .bottom])
                    })
                }
                Image("empty tag illustration").maxWidth()
                TextField(NSLocalizedString("Name your tag", comment: "Hint text for the tag name."), text: self.$tagName)
                Divider()
                ColorSelectorView(tagColor: self.$tagColor).padding(.vertical)
                if !self.viewModel.tags.isEmpty {
                    Text("Tags").font(.body).fontWeight(.bold)
                }
                WrappedHStack(items: self.$viewModel.tags) { tag in
                    Button(action: {
                        self.viewModel.deleteTag(tagTitle: tag.title, tagColor: tag.color)
                    }, label: {
                        HStack {
                            Text(tag.title).font(.body).fontWeight(.bold).multilineTextAlignment(.leading)
                            Image(systemName: "xmark.circle")
                        }.accessibilityLabel(Text("Delete tag: \(tag.title)", comment: "A11y label for button to delete a tag."))
                            .tagPill(backgroundColor: tag.color.background, foregroundColor: tag.color.foreground)
                    })
                }
                HStack {
                    Spacer()
                    Button(action: {
                        self.sheet.wrappedValue = nil
                    }, label: {
                        Text("Close", comment: "Close the tag sheet.").foregroundColor(.primary).fontWeight(.light)
                    })
                    Button(NSLocalizedString("Add", comment: "Button to save the inputted tag.")) {
                        self.viewModel.addTag(tagTitle: self.tagName, tagColor: self.tagColor)
                        self.tagName = ""
                    }.padding(.horizontal).disabled(self.tagName.isEmpty)
                }.padding(.top)
                Spacer()
            }
        }.onAppear {
            self.viewModel.fetchHymn()
            self.viewModel.fetchTags()
        }.padding()
    }
}

#if DEBUG
struct TagSheetView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let noTagsViewModel = NoOpTagSheetViewModel(hymnToDisplay: PreviewHymnIdentifiers.cupOfChrist)
        let noTags = TagSheetView(viewModel: noTagsViewModel, sheet: Binding.constant(.tags))

        let oneTagViewModel = NoOpTagSheetViewModel(hymnToDisplay: PreviewHymnIdentifiers.cupOfChrist)
        oneTagViewModel.tags = [UiTag(title: "Lord's table", color: .green)]
        let oneTag = TagSheetView(viewModel: oneTagViewModel, sheet: Binding.constant(.tags))

        let manyTagsViewModel = NoOpTagSheetViewModel(hymnToDisplay: PreviewHymnIdentifiers.cupOfChrist)
        manyTagsViewModel.tags = [UiTag(title: "Long tag name", color: .none),
                                  UiTag(title: "Tag 1", color: .green),
                                  UiTag(title: "Tag 1", color: .red),
                                  UiTag(title: "Tag 1", color: .yellow),
                                  UiTag(title: "Tag 2", color: .blue),
                                  UiTag(title: "Tag 3", color: .blue)]
        let manyTags = TagSheetView(viewModel: manyTagsViewModel, sheet: Binding.constant(.tags),
                                    tagName: "new tag", tagColor: .yellow)
        return Group {
            noTags.previewDisplayName("no tags")
            oneTag.previewDisplayName("one tag")
            manyTags.previewDisplayName("many tags")
        }
    }
}

class NoOpTagSheetViewModel: TagSheetViewModel {
    override func fetchHymn() {
        // no op
    }

    override func fetchTags() {
        // no op
    }
}
#endif

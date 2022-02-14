import SwiftUI
import Resolver

struct TagSheetView: View {

    @ObservedObject private var viewModel: TagSheetViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var tagName = ""
    @State private var tagColor = TagColor.none
    var sheet: Binding<DisplayHymnSheet?>

    init(viewModel: TagSheetViewModel, sheet: Binding<DisplayHymnSheet?>) {
        self.viewModel = viewModel
        self.sheet = sheet
    }

    var body: some View {
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
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        WrappedHStack(items: self.$viewModel.tags, geometry: geometry) { tag in
                            Button(action: {
                                self.viewModel.deleteTag(tagTitle: tag.title, tagColor: tag.color)
                            }, label: {
                                HStack {
                                    Text(tag.title).font(.body).fontWeight(.bold)
                                    Image(systemName: "xmark.circle")
                                }
                                .tagPill(backgroundColor: tag.color.background, foregroundColor: tag.color.foreground)
                            }).padding(2)
                        }
                        HStack {
                            Spacer()
                            Button(action: {
                                self.sheet.wrappedValue = nil
                            }, label: {
                                Text("Close", comment: "Close the tag sheet.").foregroundColor(.primary).fontWeight(.light)
                            })
                            Button("Add") {
                                self.viewModel.addTag(tagTitle: self.tagName, tagColor: self.tagColor)
                            }.padding(.horizontal).disabled(self.tagName.isEmpty)
                        }.padding(.top)
                        Spacer()
                    }
                }
            }
            Spacer()
        }.onAppear {
            self.viewModel.fetchHymn()
            self.viewModel.fetchTags()
        }.padding()
    }
}

#if DEBUG
struct TagSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let noTagsViewModel = TagSheetViewModel(hymnToDisplay: PreviewHymnIdentifiers.cupOfChrist)
        let noTags = TagSheetView(viewModel: noTagsViewModel, sheet: Binding.constant(.tags))

        let oneTagViewModel = TagSheetViewModel(hymnToDisplay: PreviewHymnIdentifiers.cupOfChrist)
        oneTagViewModel.tags = [UiTag(title: "Lord's table", color: .green)]
        let oneTag = TagSheetView(viewModel: oneTagViewModel, sheet: Binding.constant(.tags))

        let manyTagsViewModel = TagSheetViewModel(hymnToDisplay: PreviewHymnIdentifiers.cupOfChrist)
        manyTagsViewModel.tags = [UiTag(title: "Long tag name", color: .none),
                                  UiTag(title: "Tag 1", color: .green),
                                  UiTag(title: "Tag 1", color: .red),
                                  UiTag(title: "Tag 1", color: .yellow),
                                  UiTag(title: "Tag 2", color: .blue),
                                  UiTag(title: "Tag 3", color: .blue)]
        let manyTags = TagSheetView(viewModel: manyTagsViewModel, sheet: Binding.constant(.tags))
        return Group {
            noTags.previewDisplayName("no tags")
            oneTag.previewDisplayName("one tag")
            manyTags.previewDisplayName("many tags")
        }.previewLayout(.sizeThatFits)
    }
}
#endif

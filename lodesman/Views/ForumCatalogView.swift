//
//  ForumCatalogView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 24.01.2022.
//

import SwiftUI



struct ForumCatalogView: View
{
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var model: ViewModel
    private let action: ([(section: ForumTitle, forumId: ForumId, title: ForumTitle)]) -> Void

    init(fetcher: ForumCatalogFetching,
         onCompletion: @escaping ([(section: ForumTitle, forumId: ForumId, title: ForumTitle)]) -> Void)
    {
        self.model = ViewModel(fetcher: fetcher)
        self.action = onCompletion
    }

    var body: some View {
        Form {
            switch model.fetchedResult {
            case .success(let catalog):
                CatalogView(catalog: catalog, selection: $model.selection)
            case .failure(let error):
                VStack {
                    Text("An error accured:")
                    Text(error.localizedDescription)
                        .italic()
                }
            case .none:
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
        .onAppear(perform: model.fetchCatalog)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { doneButton }
            ToolbarItem(placement: .cancellationAction) { cancelButton }
        }
    }

    private var doneButton: some View {
        Button("Done") {
            action(model.selectedItems)
            presentationMode.wrappedValue.dismiss()
        }
        .disabled(model.selection.isEmpty)
    }

    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
}


#if DEBUG
struct ForumCatalogView_Previews: PreviewProvider {
    static var previews: some View {
        ForumCatalogView(fetcher: ForumCatalogFetcherStub()) {_ in}
            .frame(width: 500, height: 400)
    }
}
#endif

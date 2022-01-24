//
//  CatalogRow.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 24.01.2022.
//

import SwiftUI



extension CatalogItemKind
{
    var systemImage: String {
        switch self {
        case .section:  return "folder"
        case .forum:    return "dot.radiowaves.left.and.right"
        }
    }
}


struct CatalogRow: View
{
    let item: CatalogItem

    var body: some View {
        HStack {
            Image(systemName: item.kind.systemImage)
                .foregroundColor(.accentColor)
            Text(item.title)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}


#if DEBUG
struct CatalogRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CatalogRow(item: CatalogStub.preview.root[0])
            CatalogRow(item: CatalogStub.preview.root[0].children![0])
        }
        .frame(width: 200)
    }
}
#endif

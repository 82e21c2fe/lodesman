//
//  CatalogView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 24.01.2022.
//

import SwiftUI



struct CatalogView: View
{
    let catalog: Catalog
    @Binding var selection: Set<Int>

    var body: some View {
        List(catalog.root, id: \.id, children: \.children, selection: $selection) { item in
            CatalogRow(item: item)
        }
    }
}


#if DEBUG
struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView(catalog: CatalogStub.preview, selection: .constant([]))
            .frame(width: 400)
    }
}
#endif

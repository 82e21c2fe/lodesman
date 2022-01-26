//
//  AttachmentView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 26.01.2022.
//

import SwiftUI



struct AttachmentView: View
{
    private let model: ViewModel

    init (_ attachment: Attachment) {
        model = .init(attachment)
    }

    var body: some View {
        VStack(alignment: .trailing) {
            Text(model.contentSize)
                .foregroundColor(.secondary)
                .font(.title3)
            Text(model.availability)
                .foregroundColor(.yellow)
        }
    }
}


#if DEBUG
struct AttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentView(AttachmentStub())
            .padding()
    }
}
#endif

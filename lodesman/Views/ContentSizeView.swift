//
//  ContentSizeView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 26.01.2022.
//

import SwiftUI



struct ContentSizeView: View
{
    private let model: ViewModel

    init (_ size: ContentSize) {
        model = .init(size)
    }

    var body: some View {
        VStack(alignment: .trailing) {
            Text(model.contentSize)
                .foregroundColor(.secondary)
                .font(.title3)
                .accessibilityLabel("Content size")
        }
    }
}

extension ContentSizeView
{
    struct ViewModel
    {
        let contentSize: String

        init(_ size: ContentSize) {
            self.contentSize = sizeFmt.string(from: size.measurement)
        }
    }
}


fileprivate let sizeFmt: ByteCountFormatter = {
    let result = ByteCountFormatter()
    result.countStyle = .file
    return result
}()


#if DEBUG
struct AttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentSizeView(127.5)
            .padding()
    }
}
#endif

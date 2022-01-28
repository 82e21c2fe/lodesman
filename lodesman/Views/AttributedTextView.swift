//
//  AttributedTextView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 26.01.2022.
//

import SwiftUI



struct AttributedTextView: NSViewRepresentable
{
    let text: NSAttributedString

    func makeNSView(context: Context) -> some NSScrollView {
        let textView = NSTextView()
        textView.isEditable = false
        textView.autoresizingMask = [.width]
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false

        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.documentView = textView
        scroll.drawsBackground = false

        return scroll
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        (nsView.documentView as? NSTextView)?.textStorage?.setAttributedString(text)
    }
    
}


#if DEBUG
struct AttributedTextView_Previews: PreviewProvider {
    static let text: NSAttributedString = {
        let attr1: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 23, weight: .light),
            .foregroundColor: NSColor.systemYellow
        ]
        let attr2: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 23, weight: .regular),
            .foregroundColor: NSColor.systemRed,
            .kern: 5,
            .baselineOffset: 10
        ]
        let text = NSMutableAttributedString(string: "Hello, ", attributes: attr1)
        text.append(NSAttributedString(string: " world!", attributes: attr2))
        return text
    }()

    static var previews: some View {
        return AttributedTextView(text: text)
            .padding()
            .frame(width: 450)
    }
}
#endif

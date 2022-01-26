//
//  AttributedTextView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 26.01.2022.
//

import SwiftUI



struct AttributedTextView: View
{
    private let text: NSAttributedString
    private let pageWidth: CGFloat
    @State private var frameHeight: CGFloat = .zero

    init(_ text: NSAttributedString, pageWidth: CGFloat = .greatestFiniteMagnitude) {
        self.text = text
        self.pageWidth = pageWidth
    }

    var body: some View {
        TextRepresentable(text, pageWidth: pageWidth, frameHeight: $frameHeight)
            .frame(width: pageWidth, height: frameHeight)
    }
}


extension AttributedTextView
{
    private struct TextRepresentable: NSViewRepresentable
    {
        private let text: NSAttributedString
        private let pageSize: CGSize
        @Binding private var frameHeight: CGFloat

        init(_ text: NSAttributedString, pageWidth: CGFloat, frameHeight: Binding<CGFloat>) {
            self.text = text
            self.pageSize = CGSize(width: pageWidth, height: .greatestFiniteMagnitude)
            self._frameHeight = frameHeight
        }

        func makeNSView(context: Context) -> NSTextView {
            let textView = NSTextView()
            textView.textContainer!.widthTracksTextView = false
            textView.textContainer!.size = pageSize
            textView.drawsBackground = false
            textView.isEditable = false
            return textView
        }

        func updateNSView(_ nsView: NSTextView, context: Context) {
            nsView.textStorage?.setAttributedString(text)
            DispatchQueue.main.async {
                let rect = nsView.textStorage!.boundingRect(with: pageSize,
                                                            options: .usesLineFragmentOrigin)
                frameHeight = ceil(rect.height)
            }
        }
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
        return AttributedTextView(text, pageWidth: 300)
            .padding()
            .frame(width: 350, height: 100)
    }
}
#endif

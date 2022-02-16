//
//  UpdationStateModifier.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 16.02.2022.
//

import SwiftUI



struct UpdationStateModifier: ViewModifier
{
    let state: UpdationState?

    func body(content: Content) -> some View {
        switch state {
        case .waiting:
            Image(systemName: "clock.arrow.2.circlepath")
                .foregroundColor(.secondary)
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.small)
                .alignmentGuide(.firstTextBaseline) { x in x.height - 3 }
                .padding(.horizontal, 1)
        case .failure:
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
        default:
            content
        }
    }
}


extension View
{
    func updationState(_ state: UpdationState?) -> some View {
        return ModifiedContent(content: self, modifier: UpdationStateModifier(state: state))
    }
}

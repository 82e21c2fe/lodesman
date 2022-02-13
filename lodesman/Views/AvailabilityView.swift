//
//  AvailabilityView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 06.02.2022.
//

import SwiftUI
import DomainPrimitives



struct AvailabilityView: View
{
    private let model: ViewModel

    init(_ availability: Availability) {
        model = .init(availability)
    }

    var body: some View {
        Text(verbatim: model.text)
            .foregroundColor(.yellow)
            .accessibilityLabel("Availability")
            .accessibilityValue("\(model.points) points")
    }
}


extension AvailabilityView
{
    struct ViewModel: Equatable
    {
        let text: String
        let points: Int

        init(_ availability: Availability) {
            self.points = Int(availability.rawValue)
            self.text = repeatElement("✦", count: points).joined()
        }

        static func == (_ lhs: ViewModel, _ rhs: ViewModel) -> Bool {
            return lhs.points == rhs.points
        }
    }
}


#if DEBUG
struct AvailabilityView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AvailabilityView(5)
        }
    }
}
#endif

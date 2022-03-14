//
//  PlanOptionView.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 09.03.2022.
//

import SwiftUI

struct PlanOptionView: View {
    private let model: PlanOptionViewModel
    private let action: () -> Void

    init(model: PlanOptionViewModel, action: @escaping () -> Void) {
        self.model = model
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(model.isSubscribed ? L10n.Plans.Item.subscribed : L10n.Plans.Item.available)
                        .applyTextStyle(.lightGrayMain(ofSize: 10, weight: .light))

                    HStack(alignment: .bottom, spacing: 5) {
                        Text("#\(model.id)")
                            .applyTextStyle(.lightGrayMain(ofSize: 10, weight: .light))
                            .padding(.bottom, 2)

                        Text(model.validity)
                            .applyTextStyle(.whiteMain(ofSize: 15, weight: .bold))
                    }

                    Text(model.price)
                        .applyTextStyle(.whiteMain(ofSize: 18, weight: .bold))

                    Text(model.bandwidth)
                        .applyTextStyle(.lightGrayMain(ofSize: 10, weight: .light))

                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Asset.Colors.purple.color.asColor)
        .cornerRadius(5)
    }
}

//struct PlanOptionView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlanOptionView(
//            model: .init(
//                id: 2,
//                price: "25 DVPN",
//                bandwidth: "250 GB",
//                validity: "25 days",
//                isSubscribed: true
//            ),
//            action: {}
//        )
//    }
//}

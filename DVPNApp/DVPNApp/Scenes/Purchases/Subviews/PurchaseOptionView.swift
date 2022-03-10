//
//  PurchaseOptionView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 22.11.2021.
//

import SwiftUI
import SentinelWallet

struct PurchaseOptionView: View {
    private let model: PurchaseOptionViewModel
    private let action: () -> Void

    init(model: PurchaseOptionViewModel, action: @escaping () -> Void) {
        self.model = model
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Image(uiImage: Asset.Navigation.sentinel.image)

                    HStack(alignment: .bottom, spacing: 5) {
                        Text("\(model.amount)")
                            .applyTextStyle(.whiteMain(ofSize: 20, weight: .bold))
                        Text(L10n.Common.Points.title)
                            .applyTextStyle(.whiteMain(ofSize: 10))
                            .padding(.bottom, 2)
                        Text(model.bandwidth)
                            .applyTextStyle(.lightGrayMain(ofSize: 10, weight: .light))
                            .padding(.bottom, 2)
                    }

                    Text(model.price)
                        .applyTextStyle(.whiteMain(ofSize: 18, weight: .bold))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            model.isSelected ? Asset.Colors.cardPurple.color.asColor : Asset.Colors.purple.color.asColor
        )
        .cornerRadius(5)
    }
}

//struct PurchaseOptionView_Previews: PreviewProvider {
//    static var previews: some View {
//        PurchaseOptionView(
//            model: .init(
//                package: <#Package#>, amount: 50,
//                price: "$19.99",
//                isSelected: true
//            ),
//            action: {}
//        )
//    }
//}

//
//  CounterView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 05.10.2021.
//

import SwiftUI

/// The union of all layout constants, colors, font sizes etc.

private struct Constants {
    let navyColor = Asset.Colors.navyBlue.color.asColor
    let borderColor = Asset.Colors.lightBlue.color.asColor
}

private let constants = Constants()

struct CounterView: View {
    @Binding var text: String
    var togglePlus: () -> Void
    var toggleMinus: () -> Void

    init(text: Binding<String>, togglePlus: @escaping () -> Void, toggleMinus: @escaping () -> Void) {
        self._text = text
        self.togglePlus = togglePlus
        self.toggleMinus = toggleMinus
    }

    var icon: some View {
        Image(uiImage: Asset.Tokens.dvpnBlue.image)
            .resizable()
            .frame(width: 24, height: 26)
            .aspectRatio(contentMode: .fit)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            icon
                .padding(.vertical, 30)
                .padding(.leading, 40)
                .padding(.trailing, 10)
            
            Spacer()
            
            HStack(spacing: 0) {
                Text(text)
                    .applyTextStyle(.whiteMain(ofSize: 22, weight: .light))
                    .padding(.trailing, 30)
            }
            
            Spacer()

            Rectangle()
                .fill(constants.borderColor)
                .frame(width: 1)
                .edgesIgnoringSafeArea(.horizontal)

            VStack(spacing: 15) {
                Button(action: togglePlus) {
                    Image(uiImage: Asset.Counter.plus.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .foregroundColor(constants.navyColor)
                }
                .padding(.horizontal, 20)

                Rectangle()
                    .fill(constants.borderColor)
                    .frame(height: 1)
                    .edgesIgnoringSafeArea(.horizontal)

                Button(action: toggleMinus) {
                    Image(uiImage: Asset.Counter.minus.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .foregroundColor(constants.navyColor)
                }
                .padding(.horizontal, 20)
            }
            .fixedSize()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(constants.borderColor, lineWidth: 1)
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(text: .constant("50 points"), togglePlus: {}, toggleMinus: {})
    }
}

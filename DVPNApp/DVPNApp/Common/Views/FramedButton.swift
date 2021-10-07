//
//  FramedButton.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 07.10.2021.
//

import SwiftUI

struct FramedButton: View {
    var title: String
    var clicked: (() -> Void)
    
    var body: some View {
        Button(action: clicked) {
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Asset.Colors.Redesign.navyBlue.color.asColor, lineWidth: 1)
        )
    }
}

//
//  NodeSubscriptionView.swift
//  DVPNApp
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import SwiftUI

struct NodeSubscriptionView: View {
    
    @ObservedObject private var viewModel: NodeSubscriptionViewModel

    init(viewModel: NodeSubscriptionViewModel) {
        self.viewModel = viewModel
    }
    
    var bandwidthView: some View {
        VStack(spacing: 0) {
            Text("\(viewModel.gbToBuy)")
                .applyTextStyle(.whiteMain(ofSize: 44, weight: .bold))
            
            Text(L10n.Common.gb)
                .applyTextStyle(.lightGrayMain(ofSize: 18, weight: .regular))
        }
        .frame(width: 140, height: 140)
        .overlay(
            RoundedRectangle(cornerRadius: 70)
                .stroke(Asset.Colors.navyBlue.color.asColor, lineWidth: 6)
        )
    }
    
    var mainButton: some View {
        Button(action: viewModel.didTapSubscribe) {
            ZStack(alignment: .leading) {
                if viewModel.isLoading {
                    ActivityIndicator(isAnimating: $viewModel.isLoading, style: .medium)
                        .frame(width: 15, height: 15)
                }
                HStack {
                    Text(L10n.Plans.subscribe)
                        .applyTextStyle(.mainButton)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Asset.Colors.navyBlue.color.asColor)
        .cornerRadius(5)
        .disabled(viewModel.isLoading)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Button(action: viewModel.didTapCrossButton) {
                Image(systemName: "multiply")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
            }

            VStack(spacing: 0) {
                VStack {
                    Text(L10n.Plans.title)
                        .applyTextStyle(.whiteMain(ofSize: 18, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()

                    bandwidthView
                }
                .padding()

                VStack {
                    CounterView(
                        text: $viewModel.prettyTokesToSpend,
                        togglePlus: viewModel.togglePlus,
                        toggleMinus: viewModel.toggleMinus
                    )

                    mainButton
                        .padding()
                }
                .padding()
            }
            .background(Asset.Colors.accentColor.color.asColor)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Asset.Colors.lightBlue.color.asColor, lineWidth: 1)
            )
            .padding(.all, 28)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(Asset.Colors.accentColor.color.asColor.opacity(0.85))
        .edgesIgnoringSafeArea(.bottom)
    }
}

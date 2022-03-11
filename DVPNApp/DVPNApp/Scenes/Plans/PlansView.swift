//
//  PlansView.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 09.03.2022.
//

import Foundation
import SwiftUI
import UIKit
import FlagKit

struct PlansView: View {
    @ObservedObject private var viewModel: PlansViewModel

    init(viewModel: PlansViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if !viewModel.isLoading && viewModel.options.isEmpty {
                Spacer()

                Text(L10n.Plans.empty)
                    .applyTextStyle(.whiteMain(ofSize: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            plansView

            Spacer()
        }
        .background(Asset.Colors.accentColor.color.asColor)
        .onAppear(perform: viewModel.viewWillAppear)
    }
}

extension PlansView {
    var plansView: some View {
        ScrollView {
            if viewModel.isLoading {
                ActivityIndicator(isAnimating: $viewModel.isLoading, style: .medium)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding()
            }

            VStack(alignment: .leading, spacing: 15) {
                ForEach(Array(zip(viewModel.options.chunked(into: 2).indices, viewModel.options.chunked(into: 2))), id: \.0) { index, models in
                    HStack(spacing: 15) {
                        ForEach(models, id: \.self) { model in
                            PlanOptionView(
                                model: model,
                                action: { viewModel.togglePlan(vm: model) }
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct PlansView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getPlansScene()
    }
}

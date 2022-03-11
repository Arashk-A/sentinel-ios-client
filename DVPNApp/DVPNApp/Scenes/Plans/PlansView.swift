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
        ScrollView {
            ActivityIndicator(isAnimating: $viewModel.isLoading, style: .medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

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

            Spacer()
        }
        .background(Asset.Colors.accentColor.color.asColor)
        .onAppear(perform: viewModel.viewWillAppear)
    }
}

struct PlansView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getPlansScene()
    }
}

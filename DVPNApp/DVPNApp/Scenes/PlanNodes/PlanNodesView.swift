//
//  PlanNodesView.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 09.03.2022.
//

import SwiftUI

struct PlanNodesView: View {
    @ObservedObject private var viewModel: PlanNodesViewModel

    init(viewModel: PlanNodesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.locations.isEmpty {
                if viewModel.isLoadingNodes {
                    ActivityIndicator(isAnimating: $viewModel.isLoadingNodes, style: .medium)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Asset.Colors.accentColor.color.asColor)
                } else {
                    Text(L10n.Home.Node.All.notFound)
                        .applyTextStyle(.whiteMain(ofSize: 18, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                List {
                    ForEach(Array(zip(viewModel.locations.indices, viewModel.locations)), id: \.0) { index, vm in
                        NodeSelectionRowView(
                            viewModel: vm,
                            openDetails: {
                                viewModel.openDetails(for: vm.id)
                            }
                        )
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .background(Asset.Colors.accentColor.color.asColor)
    }
}

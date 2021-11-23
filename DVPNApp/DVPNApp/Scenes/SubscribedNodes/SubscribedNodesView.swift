//
//  SubscribedNodesView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 22.11.2021.
//

import SwiftUI

struct SubscribedNodesView: View {
    @ObservedObject private var viewModel: SubscribedNodesViewModel

    init(viewModel: SubscribedNodesViewModel) {
        self.viewModel = viewModel

        customize()
    }

    var body: some View {
        VStack {
            if !viewModel.isLoadingSubscriptions && viewModel.subscriptions.isEmpty {
                HStack {
                    Text(viewModel.subscriptionsState.title)
                        .applyTextStyle(.whiteMain(ofSize: 18, weight: .semibold))
                        .padding()
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.subscriptions, id: \.self) { vm in
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

            ActivityIndicator(
                isAnimating: $viewModel.isLoadingSubscriptions,
                style: .medium
            )
        }
        .background(Asset.Colors.accentColor.color.asColor)
    }
}

extension SubscribedNodesView {
    private func customize() {
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
    }
}

struct SubscribedNodesView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getSubscribedNodesScene()
    }
}
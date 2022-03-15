//
//  SubscribedNodesView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 22.11.2021.
//

import SwiftUI

private struct Constants {
    let coordinateSpaceName = "pullToRefresh1"
}

private let constants = Constants()

struct SubscribedNodesView: View {
    @ObservedObject private var viewModel: SubscribedNodesViewModel

    init(viewModel: SubscribedNodesViewModel) {
        self.viewModel = viewModel

        customize()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if !viewModel.isLoadingSubscriptions && viewModel.subscriptions.isEmpty {
                noSubscriptionsView
            } else {
                subscriptionsView
            }
            
            ActivityIndicator(
                isAnimating: $viewModel.isLoadingSubscriptions,
                style: .medium
            )
        }
        .background(Asset.Colors.accentColor.color.asColor)
    }
}

// MARK: - Subviews

extension SubscribedNodesView {
    var noSubscriptionsView: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                PullToRefresh(coordinateSpaceName: constants.coordinateSpaceName) {
                    viewModel.refresh()
                }
                
                Text(viewModel.subscriptionsState.title)
                    .applyTextStyle(.whiteMain(ofSize: 18, weight: .semibold))
                    .padding()
                    .multilineTextAlignment(.center)
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
            }
            .coordinateSpace(name: constants.coordinateSpaceName)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var subscriptionsView: some View {
        List {
            ForEach(viewModel.subscriptions, id: \.self) { vm in
                NodeSelectionRowView(
                    viewModel: vm,
                    openDetails: {
                        viewModel.openDetails(for: vm.id)
                    }
                )
                .listRowBackground(Color.clear)
                .alert(isPresented: $viewModel.alertContent.isShown) {
                    viewModel.alertContent.alert
                }
            }
            .onDelete(perform: viewModel.delete)
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Private func

extension SubscribedNodesView {
    private func customize() {
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
    }
}

// MARK: - Preview

struct SubscribedNodesView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getSubscribedNodesScene()
    }
}

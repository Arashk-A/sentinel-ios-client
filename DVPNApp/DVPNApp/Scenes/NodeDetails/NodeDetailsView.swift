//
//  NodeDetailsView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import SwiftUI

struct NodeDetailsView: View {
    
    @ObservedObject private var viewModel: NodeDetailsViewModel
    
    init(viewModel: NodeDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var locationSelector: some View {
        CountryTileView(
            viewModel: .init(
                id: viewModel.countryTileModel?.id ?? "",
                icon: viewModel.countryTileModel?.icon ?? UIImage(),
                title: viewModel.countryTileModel?.title ?? "",
                subtitle: viewModel.countryTileModel?.subtitle ?? "",
                speed: viewModel.countryTileModel?.speedImage ?? UIImage()
            )
        )
        .padding(.horizontal, 16)
    }
    
    var gridView: some View {
        GridView(models: viewModel.gridViewModels)
    }
    
    var mainButton: some View {
        Button(action: viewModel.didTapConnect) {
            HStack {
                Spacer()
                Text(L10n.NodeDetails.connect)
                    .foregroundColor(Asset.Colors.accentColor.color.asColor)
                    .applyTextStyle(.mainButton)

                Spacer()
            }
        }
        .padding()
        .background(Asset.Colors.navyBlue.color.asColor)
        .cornerRadius(5)
    }
    
    var body: some View {
        VStack {
            locationSelector
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            
            ScrollView {
                gridView
            }
            
            Spacer()

            if viewModel.connectionAllowed {
                mainButton
                    .padding(20)
            }
        }
        .background(Asset.Colors.accentColor.color.asColor)
        .edgesIgnoringSafeArea(.bottom)
    }
}

//
//  ContinentsView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

struct ContinentsView: View {
    @ObservedObject private var viewModel: ContinentsViewModel

    init(viewModel: ContinentsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ScrollView {
                Spacer()
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(zip(viewModel.chunkedModels.indices, viewModel.chunkedModels)), id: \.0) { index, models in
                        HStack(spacing: 6) {
                            ForEach(models, id: \.0) { model in
                                ContinentsRowView(
                                    type: model.key,
                                    count: .constant(model.value),
                                    action: {
                                        viewModel.openNodes(for: model.key)
                                    })
                            }
                        }
                    }
                }
            }
            
            Button(action: viewModel.toggleRandomLocation) {
                HStack {
                    Spacer()
                    
                    VStack {
                        Image(uiImage: Asset.Connection.power.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                        
                        Text(viewModel.connectionStatus == .disconnected ? L10n.Continents.Button.connect : L10n.Continents.Button.disconnect)
                            .applyTextStyle(.whiteMain(ofSize: 12, weight: .bold))
                    }
                    .padding(.vertical, 10)
                    
                    Spacer()
                }
            }
            .background(Asset.Colors.navyBlue.color.asColor)
            .cornerRadius(5)
        }
        .onAppear { viewModel.viewWillAppear() }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(Asset.Colors.accentColor.color.asColor)
    }
}

struct ContinentsView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getContinentsScene()
    }
}

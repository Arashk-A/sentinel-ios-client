//
//  NodeSelectionRowView.swift
//  DVPNApp
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import SwiftUI
import FlagKit

struct NodeSelectionRowView: View {
    private let viewModel: NodeSelectionRowViewModel
    private let openDetails: () -> Void
    
    init(
        viewModel: NodeSelectionRowViewModel,
        openDetails: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.openDetails = openDetails
    }

    var body: some View {
        Button(action: openDetails) {
            VStack {
                HStack(alignment: .center) {
                    Image(uiImage: viewModel.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 41)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(viewModel.title)
                            .applyTextStyle(.whiteMain(ofSize: 16, weight: .medium))
                        Text(viewModel.subtitle)
                            .applyTextStyle(.grayMain(ofSize: 10))
                    }

                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.white)
                }
                .padding(.vertical)
            }
        }
    }
}

// swiftlint:disable force_unwrapping

//struct HomeRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        NodeSelectionRowView(
//            viewModel:
//                    .init(
//                        id: "id",
//                        icon: Flag(countryCode: "EE")!.image(style: .roundedRect),
//                        title: "Test",
//                        subtitle: "mfq9rph",
//                        latency: 3
//                    ),
//            openDetails: {}
//        )
//    }
//}

// swiftlint:enable force_unwrapping

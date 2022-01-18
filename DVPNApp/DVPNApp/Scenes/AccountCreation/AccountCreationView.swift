//
//  AccountCreationView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.10.2021.
//

import Foundation
import SwiftUI

struct AccountCreationView: View {

    @ObservedObject private var viewModel: AccountCreationViewModel

    init(viewModel: AccountCreationViewModel) {
        self.viewModel = viewModel
    }

    var walletAddress: some View {
        Button(action: viewModel.didTapCopyAddress) {
            ZStack(alignment: .topLeading) {
                Text(viewModel.address ?? "")
                    .applyTextStyle(.whitePoppins(ofSize: 11, weight: .medium))
                    .padding(.bottom, 10)
                    .padding([.horizontal, .top], 8)
                    .border(Asset.Colors.borderGray.color.asColor, width: 1)
                    .cornerRadius(2)
                    .padding(.top, 5)
                
                HStack {
                    Spacer().frame(width: 10, height: 10)
                    Text(L10n.AccountCreation.walletAddress)
                        .applyTextStyle(.textBody)
                        .padding(.horizontal, 5)
                        .background(Asset.Colors.accentColor.color.asColor)
                }
            }
        }
    }

    var mnemonicFields: some View {
        VStack {
            ForEach(Array(viewModel.mnemonic.indices).chunked(into: 4), id: \.self) { range in
                MnemonicLineView(range: range, mnemonic: $viewModel.mnemonic, isEnabled: $viewModel.isEnabled)
            }
        }
    }

    var mainButton: some View {
        Button(action: viewModel.didTapMainButton) {
            HStack {
                Spacer()
                Text(viewModel.mode.buttonTitle.uppercased())
                    .applyTextStyle(.mainButton)

                Spacer()
            }
        }
        .padding()
        .background(Asset.Colors.navyBlue.color.asColor)
        .cornerRadius(5)
    }

    var termsView: some View {
        HStack(spacing: 2) {
            Button(action: viewModel.didCheckTerms) {
                if viewModel.isTermsChecked {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(Asset.Colors.navyBlue.color.asColor)
                } else {
                    Image(systemName: "square")
                        .foregroundColor(Asset.Colors.borderGray.color.asColor)
                }
            }
            
            HStack(alignment: .top, spacing: 5) {
                Text(L10n.AccountCreation.Terms.text)
                    .applyTextStyle(.lightGrayPoppins(ofSize: 12, weight: .light))
                
                Button(action: viewModel.didTapTerms) {
                    Text(L10n.AccountCreation.Terms.button)
                        .applyTextStyle(.whitePoppins(ofSize: 12, weight: .semibold))
                }
            }

            Spacer()
        }
    }

    var importView: some View {
        HStack(spacing: 2) {
            Text(L10n.AccountCreation.Button.ImportNow.text)
                .applyTextStyle(.lightGrayPoppins(ofSize: 12, weight: .light))

            Button(action: viewModel.didTapChangeMode) {
                Text(L10n.AccountCreation.Button.ImportNow.action)
                    .applyTextStyle(.navyBluePoppins(ofSize: 12, weight: .semibold))
                    .underline()
            }
        }
    }

    var body: some View {
        ScrollView {
            if viewModel.mode == .create {
                walletAddress
            }

            mnemonicFields
            
            HStack {
                Button(action: viewModel.didTapMnemonicActionButton) {
                    Text(
                        viewModel.mode == .restore ?
                        L10n.AccountCreation.Import.Button.paste : L10n.AccountCreation.Create.Button.copy)
                        .applyTextStyle(.whitePoppins(ofSize: 12))
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .border(Asset.Colors.navyBlue.color.asColor, width: 1)
                        .cornerRadius(2)
                }
                
                Spacer()
            }
            .padding(.vertical, 10)
            
            if viewModel.mode == .restore && viewModel.address != nil {
                walletAddress
            }

            if viewModel.mode == .create {
                HStack {
                    Text(L10n.AccountCreation.warning)
                        .applyTextStyle(.textBody)
                        .padding(.all, 10)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .border(Asset.Colors.borderGray.color.asColor, width: 1)
                .cornerRadius(2)
            }

            Spacer()

            if viewModel.mode == .create {
                termsView
                    .padding()

                mainButton
                    .padding(.horizontal)

                importView
                    .padding()
            } else {
                mainButton
                    .padding()
                    .padding(.top, 50)
            }
        }
        .padding()
        .background(Asset.Colors.accentColor.color.asColor)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct AccountCreationView_Previews_Restore: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getAccountCreationScene(mode: .restore)
    }
}

struct AccountCreationView_Previews_Create: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getAccountCreationScene(mode: .create)
    }
}

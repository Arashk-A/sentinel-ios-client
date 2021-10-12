import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel

        customize()
    }

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            ExtraView(
                openServers: viewModel.openDNSServersSelection,
                openMore: viewModel.openMore,
                servers: $viewModel.servers
            )
                .rotationEffect(.degrees(-180))
                .tag(HomeViewModel.PageType.extra)

            NodeSelectionView(viewModel: viewModel)
                .rotationEffect(.degrees(-180))
                .tag(HomeViewModel.PageType.selector)
        }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .background(Asset.Colors.accentColor.color.asColor)
            .rotationEffect(.degrees(-180))
            .edgesIgnoringSafeArea(.bottom)
            .onAppear(perform: viewModel.viewWillAppear)
    }
}

extension HomeView {
    private func customize() {
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear

        let controlAppearance = UISegmentedControl.appearance()

        controlAppearance.selectedSegmentTintColor = Asset.Colors.accentColor.color
        controlAppearance.setTitleTextAttributes(
            [.foregroundColor: Asset.Colors.navyBlue.color],
            for: .selected
        )
        controlAppearance.setTitleTextAttributes(
            [
                .font: FontFamily.Poppins.semiBold.font(size: 10),
                .foregroundColor: UIColor.white,
                .kern: 2.5
            ],
            for: .normal
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getHomeScene()
    }
}
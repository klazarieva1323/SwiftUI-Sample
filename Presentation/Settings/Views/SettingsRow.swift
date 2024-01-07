import Design
import Resources
import SwiftUI

struct SettingsRow<Item: SettingsItem>: View {
    // MARK: - Properties -

    private let viewModel: SettingsRowViewModel<Item>

    // MARK: - Life Cycle -

    init(
        item: Item,
        shouldShowSeparator: Bool = true,
        actionRowTapped: SettingsItemTappedBlock<Item>? = nil
    ) {
        viewModel = SettingsRowViewModel(
            item: item,
            shouldShowSeparator: shouldShowSeparator,
            actionRowTapped: actionRowTapped
        )
    }

    var body: some View {
        mainContainer()
    }

    // MARK: - Private -

    @ViewBuilder
    private func mainContainer() -> some View {
        switch viewModel.item.rowType {
        case .action:
            TransparentButton {
                viewModel.executeActionIfNeeded()
            } label: {
                container()
            }
        case .navigation:
            navigationRow()
        }
    }

    @ViewBuilder
    private func navigationRow() -> some View {
        if let route = viewModel.item.navigationRoute {
            container()
                .navigate(to: route)
        } else {
            container()
        }
    }

    @ViewBuilder
    private func container() -> some View {
        VStack(spacing: 0) {
            horizontalContainer()
                .padding(.vertical, 16)
            if viewModel.shouldShowSeparator {
                separator()
            }
        }
    }

    @ViewBuilder
    private func horizontalContainer() -> some View {
        HStack {
            CustomText(viewModel.item.title, font: .body2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    // added rectangle to make settings row clickable at any place
                    Rectangle()
                        .opacity(0.001)
                )

            if viewModel.item.rowType == .navigation {
                CustomImage(.settingsRightArrow)
            }
        }
    }

    @ViewBuilder
    private func separator() -> some View {
        Divider()
            .background(Colors.primary.swiftUIColor)
            .opacity(0.5)
    }
}

struct SettingsRow_Previews: PreviewProvider {
    static var previews: some View {
        let items: [AppSettingsItem] = [
            .accountSettings,
            .contactUs,
            .diagnosticsPage
        ]

        VStack(spacing: 0) {
            ForEach(items, id: \.self) {
                SettingsRow(item: $0)
            }
        }
        .padding()
    }
}

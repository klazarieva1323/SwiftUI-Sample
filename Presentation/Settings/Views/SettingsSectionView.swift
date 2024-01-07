import Design
import Resources
import SwiftUI

struct SettingsSectionView<Item: SettingsItem>: View {
    // MARK: - Properties -

    let viewModel: SettingsSectionViewModel<Item>

    // MARK: - Life Cycle -

    init(
        model: SettingsSectionModel<Item>,
        actionRowTapped: SettingsItemTappedBlock<Item>? = nil
    ) {
        self.viewModel = SettingsSectionViewModel(
            model: model,
            actionRowTapped: actionRowTapped
        )
    }

    var body: some View {
        container
    }

    // MARK: - Private -

    private var container: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.model.items.indices, id: \.self) { index in
                if index == .zero, let sectionTitle = viewModel.model.type?.title {
                    VStack(alignment: .leading, spacing: 0) {
                        // Section title
                        CustomText(
                            sectionTitle,
                            font: .caption2,
                            color: Colors.primary2.swiftUIColor
                        )
                        row(at: index)
                    }
                } else {
                    row(at: index)
                }
            }
        }
    }

    private func row(at index: Int) -> some View {
        let item = viewModel.item(at: index)
        return SettingsRow(
            item: item,
            shouldShowSeparator: viewModel.shouldShowSeparator(at: index),
            actionRowTapped: viewModel.actionRowTapped
        )
    }
}

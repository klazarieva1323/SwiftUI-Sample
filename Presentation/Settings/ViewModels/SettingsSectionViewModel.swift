import Foundation

final class SettingsSectionViewModel<Item: SettingsItem> {
    // MARK: - Properties -

    let model: SettingsSectionModel<Item>
    let actionRowTapped: SettingsItemTappedBlock<Item>?

    // MARK: - Life Cycle -

    init(
        model: SettingsSectionModel<Item>,
        actionRowTapped: SettingsItemTappedBlock<Item>?
    ) {
        self.actionRowTapped = actionRowTapped
        self.model = model
    }

    // MARK: - Internal -
    
    func shouldShowSeparator(at index: Int) -> Bool {
        index != model.items.count - 1
    }

    func item(at index: Int) -> Item {
        model.items[index]
    }
}

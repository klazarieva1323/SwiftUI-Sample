import Foundation

final class SettingsRowViewModel<Item: SettingsItem> {
    // MARK: - Properties -

    let item: Item
    let shouldShowSeparator: Bool
    let actionRowTapped: SettingsItemTappedBlock<Item>?

    // MARK: - Life Cycle -

    init(
        item: Item,
        shouldShowSeparator: Bool,
        actionRowTapped: SettingsItemTappedBlock<Item>?
    ) {
        self.item = item
        self.shouldShowSeparator = shouldShowSeparator
        self.actionRowTapped = actionRowTapped
    }

    // MARK: - Internal -

    func executeActionIfNeeded() {
        guard item.rowType == .action else {
            return
        }
        actionRowTapped?(item)
    }
}

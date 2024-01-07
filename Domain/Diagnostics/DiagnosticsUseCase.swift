import AppFoundation
import Combine
import Foundation
import ShortcutFoundation

#if os(iOS)
public final class DefaultDiagnosticsUseCase: DiagnosticsUseCase {
    // MARK: - Properties -

    @LazyInject private var analytics: AnalyticsRepository
    @LazyInject private var diagnosticsDataRepository: DiagnosticsDataRepository

    private var diagnosticsItemsSubscriber: AnyCancellable?

    // MARK: - Life Cycle -

    public init() {
        listenToDiagnosticsItemsChange()
    }

    // MARK: - Diagnostics Retrieve

    /// Retrieves device and user's informative data
    public func getDiagnosticsDataItems() -> AnyPublisher<[DiagnosticsItem], Error> {
        diagnosticsDataRepository.getDiagnosticsDataItems()
    }

    public func getDiagnosticsFormattedString() -> String {
        diagnosticsDataRepository.getDiagnosticsFormattedString()
    }

    // MARK: - Diagnostics Manipulation

    /// Collects all device and user's diagnostics and set's them as a user properties for analytics
    public func updateDeviceSpecificDiagnostics() {
        diagnosticsDataRepository.updateDeviceAndUserSpecificDiagnostics()
    }

    /// Updates the diagnostics info with the currently connected social accounts
    public func updateConnectedSocialDiagnosticsInfo() {
        diagnosticsDataRepository.updateConnectedSocialDiagnosticsInfo()
    }

    /// Either inserts or updates an item of a passed type with a passed value
    ///
    ///  - parameters:
    ///     - type: A diagnostics item type
    ///     - value: An item value
    ///
    public func updateDiagnosticsItem(of type: DiagnosticsItemType, with value: String) {
        diagnosticsDataRepository.updateDiagnosticsItem(of: type, with: value)
    }

    /// Removes user specific diagnostics items
    public func removeUserSpecificProperties() {
        diagnosticsDataRepository.removeUserSpecificProperties()
    }

    // MARK: Analytics User Properties

    private func listenToDiagnosticsItemsChange() {
        self.diagnosticsItemsSubscriber = diagnosticsDataRepository.diagnosticsItemsPublisher
            .sink(receiveValue: {
                $0.forEach({ item in
                    switch item.type {
                    case .platform:
                        self.analytics.set(userProperty: .platform(item.value))

                    case .model:
                        self.analytics.set(userProperty: .deviceModel(item.value))

                    case .appVersion:
                        self.analytics.set(userProperty: .appVersion(item.value))

                    case .userId:
                        self.analytics.set(userProperty: .userId(item.value))

                    case .locale:
                        self.analytics.set(userProperty: .locale(item.value))

                    case .connectivity:
                        self.analytics.set(userProperty: .connectivity(item.value))

                    case .connectedSocials:
                        self.analytics.set(userProperty: .connectedSocials(item.value))

                    case .timezone:
                        self.analytics.set(userProperty: .timezone(item.value))
                    }
                })
            })
    }
}
#endif

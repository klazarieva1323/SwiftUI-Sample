import AppFoundation
import Combine
import ShortcutFoundation
import UIKit

#if os(iOS)
public final class DefaultDiagnosticsDataRepository: DiagnosticsDataRepository {
    // MARK: - Properties -

    @LazyInject private var userDataRepository: UserDataRepository
    @LazyInject private var healthSourcesDataRepository: HealthSourcesDataRepository
    @LazyInject private var reachabilityProvider: ReachabilityProviderProtocol

    private var diagnosticsItemsSubject = CurrentValueSubject<Set<DiagnosticsItem>, Never>([])
    private var diagnosticsItems: [DiagnosticsItem] {
        getOrderedItems()
    }
    public lazy var diagnosticsItemsPublisher = diagnosticsItemsSubject.eraseToSharedPublisher()

    private let itemsOrder: [DiagnosticsItemType] = [
        .platform,
        .model,
        .appVersion,
        .userId,
        .locale,
        .timezone,
        .connectivity,
        .connectedSocials,
        .connectedHealthSources
    ]

    // MARK: - Life Cycle -

    public init() {}

    // MARK: - DiagnosticsDataRepository

    public func updateDeviceAndUserSpecificDiagnostics() {
        generateDeviceDiagnosticsItems()
    }

    /// Updates the diagnostics info with the currently connected social accounts
    public func updateConnectedSocialDiagnosticsInfo() {
        userDataRepository.getAuthenticationSourcesString()
            .receiveAndCancel(receiveOutput: {
                self.updateDiagnosticsItem(
                    of: .connectedSocials,
                    with: $0
                )
            })
    }

    public func getDiagnosticsDataItems() -> AnyPublisher<[DiagnosticsItem], Error> {
        if diagnosticsItems.isNotEmpty {
            return getItems()
        }

        return loadUserData()
            .catch { _ -> AnyPublisher<[DiagnosticsItem], Error> in
                self.generateDeviceDiagnosticsItems()

                return self.getItems()
            }
            .eraseToAnyPublisher()
    }

    /// Retrieves diagnostics items description as a formatted string
    /// - returns: `String` with a description of device and user's diagnostics
    public func getDiagnosticsFormattedString() -> String {
        diagnosticsItems.reduce(.empty, {
            String(format: "\($0)\n\n\($1.type.title)\n\($1.value)")
        })
    }

    /// Either inserts or updates an item of a passed type with a passed value
    ///
    ///  - parameters:
    ///     - type: A diagnostics item type
    ///     - value: An item value
    ///
    public func updateDiagnosticsItem(of type: DiagnosticsItemType, with value: String) {
        let diagnosticsItem = DiagnosticsItem(type: type, value: value)

        var diagnosticsItems = self.diagnosticsItemsSubject.value

        if diagnosticsItems.update(with: diagnosticsItem) == nil {
            diagnosticsItems.insert(diagnosticsItem)
        }

        diagnosticsItemsSubject.send(diagnosticsItems)
    }

    /// Removes user specific diagnostics items
    public func removeUserSpecificProperties() {
        let diagnosticsItems = self.diagnosticsItemsSubject.value.filter { !$0.type.isUserSpecific }

        diagnosticsItemsSubject.send(diagnosticsItems)
    }

    // MARK: - Private -
    private func getItems() -> AnyPublisher<[DiagnosticsItem], Error> {
        .justWithFailure(diagnosticsItems)
    }

    private func prepareDivHtmlBlocks() -> String {
        diagnosticsItems.map {
            "<div>\($0.type.title)</br>\($0.value)</div></br>"
        }.joined(separator: "")
    }

    private func getOrderedItems() -> [DiagnosticsItem] {
        itemsOrder.compactMap { orderedItem in
            diagnosticsItemsSubject.value.first(where: { $0.type == orderedItem })
        }
    }

    private func loadUserData() -> AnyPublisher<[DiagnosticsItem], Error> {
        Publishers.Zip(
            userDataRepository.getUser(),
            userDataRepository.getAuthenticationSourcesString()
        )
        .map { user, connectedSocials in
            let stepSources = self.healthSourcesDataRepository.getHealthSource()?.diagnosticsName ?? .empty

            self.generateDeviceDiagnosticsItems(
                userId: user.id,
                connectedSocials: connectedSocials,
                connectedHealthSources: stepSources
            )
            return self.diagnosticsItems
        }
        .eraseToAnyPublisher()
    }

    private func generateDeviceDiagnosticsItems(userId: String? = nil,
                                                connectedSocials: String? = nil,
                                                connectedHealthSources: String? = nil) {
        let platform = UIDevice.operatingSystemDescription
        let model = UIDevice.modelName
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? .empty
        let locale = Locale.current.identifier

        var diagnosticsItems = [DiagnosticsItem]()

        diagnosticsItems.append(
            .init(
                type: .platform,
                value: platform
            )
        )
        diagnosticsItems.append(
            .init(
                type: .model,
                value: model
            )
        )
        diagnosticsItems.append(
            .init(
                type: .appVersion,
                value: appVersion
            )
        )
        diagnosticsItems.append(
            .init(
                type: .timezone,
                value: .currentTimeZone
            )
        )
        if let userId {
            diagnosticsItems.append(
                .init(
                    type: .userId,
                    value: userId
                )
            )
        }
        diagnosticsItems.append(
            .init(
                type: .locale,
                value: locale
            )
        )
        diagnosticsItems.append(
            .init(
                type: .connectivity,
                value: reachabilityProvider.connectionDescription
            )
        )
        if let connectedSocials {
            diagnosticsItems.append(
                .init(
                    type: .connectedSocials,
                    value: connectedSocial
                )
            )
        }
        if let connectedHealthSources {
            diagnosticsItems.append(
                .init(
                    type: .connectedHealthSources,
                    value: connectedHealthSources
                )
            )
        }

        self.diagnosticsItemsSubject.send(Set(diagnosticsItems))
    }
}
#endif

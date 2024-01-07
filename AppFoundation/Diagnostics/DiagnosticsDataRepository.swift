import Combine
import Foundation

#if os(iOS)
public protocol DiagnosticsDataRepository {
    var diagnosticsItemsPublisher: AnyPublisher<Set<DiagnosticsItem>, Never> { get }

    /// Retrieves device and user's informative data
    ///
    /// - returns: List of items type of `DiagnosticsItem`
    ///
    func getDiagnosticsDataItems() -> AnyPublisher<[DiagnosticsItem], Error>

    /// Retrieves diagnostics items description as a formatted string
    /// - returns: `String` with a description of device and user's diagnostics
    func getDiagnosticsFormattedString() -> String

    /// Either inserts or updates an item of a passed type with a passed value
    ///
    ///  - parameters:
    ///     - type: A diagnostics item type
    ///     - value: An item value
    ///
    func updateDiagnosticsItem(of type: DiagnosticsItemType, with value: String)

    /// Fetches device's and user's related diagnostics data and regenerates all diagnostics
    func updateDeviceAndUserSpecificDiagnostics()

    /// Updates the diagnostics info with the currently connected social accounts
    func updateConnectedSocialDiagnosticsInfo()

    /// Removes user specific diagnostics items
    func removeUserSpecificProperties()
}
#endif

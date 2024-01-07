import Foundation

// MARK: - Generic -

typealias SettingsItemTappedBlock<Item: SettingsItem> = (_ rowType: Item) -> Void

protocol SettingsSection {
    var title: String { get }
}

enum SettingsRowType {
    case action
    case navigation
}

protocol SettingsItem {
    var title: String { get }
    var rowType: SettingsRowType { get }
    var navigationRoute: Route? { get }
}

struct SettingsSectionModel<Item: SettingsItem> {
    /// The type of the section. Set `nil` if the items need to be grouped together but with no section customisation (no section name)
    let type: SettingsSection?
    let items: [Item]

    init(
        type: SettingsSection? = nil,
        items: [Item]
    ) {
        self.type = type
        self.items = items
    }
}

// MARK: - App Settings entities -

enum AppSettingsSectionType: SettingsSection, CaseIterable {
    case account
    case info
    case support

    var title: String {
        switch self {
        case .account:
            return Translations.settingsAccount

        case .info:
            return Translations.settingsInformation

        case .support:
            return Translations.settingsSupport
        }
    }
}

enum AppSettingsItem: SettingsItem, CaseIterable {
    case myOrders
    case personalInfo
    case accountSettings

    case contactUs
    case helpCenter
    case termsOfService
    case privacyPolicy
    case howToUse
    case rateApp
    case diagnosticsPage

    var title: String {
        switch self {
        case .myOrders:
            return Translations.shopMyOrders

        case .personalInfo:
            return Translations.settingsAccountPersonalInformation

        case .accountSettings:
            return Translations.settingsAccountIntegration

        case .contactUs:
            return Translations.generalButtonContact

        case .helpCenter:
            return Translations.settingsSupportHelpcenter

        case .termsOfService:
            return Translations.settingsInformationTermsConditions

        case .privacyPolicy:
            return Translations.settingsInformationPrivacyPolicy

        case .howToUse:
            return Translations.settingsInformationHowToUse

        case .rateApp:
            return Translations.settingsInformationRate

        case .diagnosticsPage:
            return Translations.settingsSupportDiagnosticsPage
        }
    }

    var rowType: SettingsRowType {
        switch self {
        case .contactUs,
             .rateApp:
            return .action

        default:
            return .navigation
        }
    }

    var navigationRoute: Route? {
        switch self {
        case .myOrders:
            return .myOrders(parent: .settings)

        case .personalInfo:
            return .personalInfo(displayMode: .view)

        case .accountSettings:
            return .accountSettings

        case .helpCenter:
            return .helpCenter

        case .termsOfService:
            return .termsAndConditions

        case .privacyPolicy:
            return .privacyPolicy

        case .howToUse:
            return .appUsageInfo

        case .diagnosticsPage:
            return .diagnosticPage

        default:
            return nil
        }
    }
}

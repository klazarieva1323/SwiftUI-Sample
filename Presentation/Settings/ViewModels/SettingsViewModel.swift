import AppFoundation
import Foundation
import ShortcutFoundation

typealias AppSettingsSectionModel = SettingsSectionModel<AppSettingsItem>

final class SettingsViewModel: ObservableObject {
    // MARK: - Variables -

    var sections: [AppSettingsSectionModel] = []

    @LazyInject private var appModalViewRouter: AppModalViewRouter
    @LazyInject private var userAuthenticationUseCase: UserAuthenticationUseCase
    @LazyInject private var analytics: AnalyticsRepository
    @Published var shouldPresentContactUs = false

    // MARK: - Life Cycle -

    init() {
        prepareDataSource()
    }

    // MARK: - Internal -

    func logSettingsScreenViewed() {
        analytics.log(.settingsScreenViewed)
    }

    func showLogOutConfirmation() {
        analytics.log(.logOutButtonTapped)
        analytics.log(.logOutDetailScreenViewed)
        appModalViewRouter.showCustomSheet(state: .logOutConfirmation(handleUserResponse: { [weak self] isConfirmed in
            if isConfirmed {
                self?.analytics.log(.logOutConfirmationButtonTapped)
                self?.logOut()
            } else {
                self?.analytics.log(.logOutCancelButtonTapped)
            }
        }))
    }

    func executeAction(for settingsItem: AppSettingsItem) {
        switch settingsItem {
        case .contactUs:
            openContactUsPopup()

        case .rateApp:
            showRateAppPopup()

        default:
            break
        }
    }
}

// MARK: - Private -

private extension SettingsViewModel {
    func logOut() {
        userAuthenticationUseCase.logOut()
    }

    func openContactUsPopup() {
        analytics.log(.contactUsButtonTapped)
        shouldPresentContactUs = true
    }

    func showRateAppPopup() {
        let handleUserResponse: BoolCompletion = { [weak self] isConfirmed in
            guard isConfirmed else {
                self?.analytics.log(.cancelRatingButtonTapped)
                return
            }

            self?.analytics.log(.rateNowButtonTapped)
            RateAppPresenter.shared.presentRateAppFlow()
        }

        analytics.log(.rateAppScreenViewed)
        appModalViewRouter.showCustomSheet(state: .rateAppConfirmation(handleUserResponse: handleUserResponse))
    }

    func prepareDataSource() {
        let accountSection = AppSettingsSectionModel(
            type: AppSettingsSectionType.account,
            items: [
                .personalInfo,
                .stepGoal,
                .accountSettings
            ]
        )

        let infoSection = AppSettingsSectionModel(
            type: AppSettingsSectionType.info,
            items: [
                .howToUse,
                .termsOfService,
                .privacyPolicy
            ]
        )

        let supportSection = AppSettingsSectionModel(
            type: AppSettingsSectionType.support,
            items: [
                .helpCenter,
                .contactUs,
                .diagnosticsPage,
                .rateApp
            ]
        )

        sections = [
            accountSection,
            infoSection,
            supportSection
        ]
    }
}

import Core
import Design
import SwiftUI

struct SettingsView: View {
    // MARK: - Properties -

    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        container
            .navigationTitle(Translations.settings.uppercased())
            .customBackground()
            .onAppear {
                viewModel.logSettingsScreenViewed()
            }
    }

    // MARK: - Private -

    private var container: some View {
        CustomScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<viewModel.sections.count, id: \.self) { index in
                    let sectionModel = viewModel.sections[index]
                    SettingsSectionView(model: sectionModel) { settingsItem in
                        viewModel.executeAction(for: settingsItem)
                    }
                }

                logoutButton
            }
            .padding([.top, .horizontal], 16)
            .bottomPadding(40)
        }
        .contactUs(shouldPresent: $viewModel.shouldPresentContactUs)
    }

    private var logoutButton: some View {
        TransparentButton {
            viewModel.showLogOutConfirmation()
        } label: {
            HStack(spacing: 7) {
                CustomImage(.logOut)
                CustomText(
                    Translations.settingsLogout,
                    font: .subtitle1
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct SettingsViewPreviews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

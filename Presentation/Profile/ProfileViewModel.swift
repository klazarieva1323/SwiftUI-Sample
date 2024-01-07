import AppFoundation
import Combine
import Core
import ShortFoundation

final class ProfileViewModel: ObservableObject {
    ...
    // - MARK: - Properties -
    @LazyInject private var profileUseCase: ProfileUseCase
    @LazyInject private var toastMessageRouter: ToastMessageRouter

    @Published var personalInfo: UserProfileInfo?
    @Published var isLoadingProfileInfo = false

    var updatePhotoAction: EmptyBlock?

    // MARK: - Internal -
    func onAppear() {
        updateFullProfileInfo()
    }

    // MARK: - Private -
    private func updateFullProfileInfo() {
        isLoadingProfileInfo = true
        
        profileUseCase.getUserProfileInfo()
            .receive(on: DispatchQueue.main)
            .receiveAndCancel { [weak self] in
                self?.isLoadingProfileInfo = false
                self?.personalInfo = $0
            } receiveError: { [weak self] error in
                self?.isLoadingProfileInfo = false
                self?.toastMessageRouter.show(error: error)
            }
    }
    ...
}

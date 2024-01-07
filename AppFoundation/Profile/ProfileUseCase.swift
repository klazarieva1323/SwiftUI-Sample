import Combine

public protocol ProfileUseCase {
    /// Retrieves the user profile data
    func getProfile() -> AnyPublisher<Profile, Error>

    /// Update user's profile personal info
    func updateProfile(_ profile: Profile) -> AnyPublisher<Profile, Error>

    /// Retrieves the profile history
    func getProfileHistoryData() -> AnyPublisher<ProfileHistoryData?, Error>
}

import Combine
import Infra

final class HomeViewModel: ObservableObject {
    @Published var profileName = String()
    @Published var isLoading = false
}

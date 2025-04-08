// Import necessary SwiftUI framework
import SwiftUI

// MARK: - AuthView Definition
/// A view that determines whether to show the main content view or the login view
/// based on the user's authentication state.
///
/// This view observes the `AuthService` to reactively switch between the `ContentView`
/// (for authenticated users) and the `LoginView` (for unauthenticated users).
/// It injects the shared `AuthService` instance into the environment of its child views.
struct AuthView: View {
    /// The shared authentication service instance, observed as a StateObject.
    @StateObject private var authService = AuthService.shared

    /// The body of the view, conditionally displaying content based on authentication state.
    var body: some View {
        Group {
            // Check the authentication state provided by the AuthService.
            if authService.authState == .authenticated {
                // If authenticated, display the main application content view.
                // Pass necessary settings and inject the authService into the environment.
                ContentView(settings: AppSettings())
                    .environmentObject(authService)
            } else {
                // If not authenticated, display the login view.
                // Inject the authService into the environment.
                LoginView()
                    .environmentObject(authService)
            }
        }
        // Apply a smooth transition animation when the authentication state changes.
        .animation(.easeInOut, value: authService.authState)
    }
}

// MARK: - AuthView Previews
/// Provides previews for the `AuthView` in Xcode.
struct AuthView_Previews: PreviewProvider {
    /// A static property to provide view previews.
    static var previews: some View {
        // Instantiate AuthView for previewing.
        // Note: In a real preview scenario, you might want to inject mock
        // AuthService instances with different states (.authenticated, .unauthenticated)
        // to test both paths.
        AuthView()
    }
}
import SwiftUI

// MARK: - Alert Item Structure
/// A structure to represent identifiable alert information for the Login screen.
struct LoginAlertItem: Identifiable {
    let id = UUID()
    let title: String = "登录错误" // Consistent title
    let message: String
}

// MARK: - Login ViewModel
/// ViewModel responsible for managing the state and logic of the LoginView.
@MainActor
final class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    /// The username (email) entered by the user.
    @Published var username: String = ""
    /// The password entered by the user.
    @Published var password: String = ""
    /// Controls the presentation of the Forgot Password sheet.
    @Published var showingForgotPasswordSheet: Bool = false
    /// Controls the presentation of the Register sheet.
    @Published var showingRegisterSheet: Bool = false
    /// Holds the alert item to be presented to the user.
    @Published var alertItem: LoginAlertItem?
    /// Indicates if the login operation is currently in progress. Relies on AuthService.isLoading.
    var isLoading: Bool { authService.isLoading }
    /// Holds any error message from the AuthService.
    var errorMessage: String? { authService.errorMessage }

    // MARK: - Dependencies
    /// The shared authentication service. Passed via environment or injected.
    /// We need access to it for `isLoading`, `errorMessage`, and the `login` function.
    /// Here, we assume it will be available via the environment in the View.
    private var authService: AuthService

    // MARK: - Initialization
    /// Initializes the ViewModel with the necessary AuthService.
    /// - Parameter authService: The authentication service instance.
    init(authService: AuthService) {
        self.authService = authService
    }


    // MARK: - Methods
    /// Handles the login button press action.
    func handleLogin() {
        // Basic input validation
        guard !username.isEmpty else {
            alertItem = LoginAlertItem(message: "请输入您的邮箱")
            return
        }

        guard !password.isEmpty else {
            alertItem = LoginAlertItem(message: "请输入您的密码")
            return
        }

        // Clear previous errors before attempting
        authService.errorMessage = nil // Clear error by setting message to nil

        // Perform login using AuthService with a completion handler
        authService.login(email: username, password: password) { success in
            // This closure executes when the login call completes.
            // Since the ViewModel is @MainActor, UI updates are safe here.

            // Check if login failed
            if !success {
                // If login failed, check the errorMessage property for details
                let message = self.authService.errorMessage ?? "An unknown login error occurred."
                self.alertItem = LoginAlertItem(message: message)
            }
            // If success is true, AuthView handles the state change, no explicit action needed here
            // isLoading should also be managed by AuthService and reflected automatically
        }
    }
}


// MARK: - LoginView Definition
/// A view presenting the login interface for the iFrench application.
struct LoginView: View {
    /// The shared authentication service, injected via the environment.
    @EnvironmentObject private var authService: AuthService
    /// The ViewModel managing the state and logic for this view.
    /// Needs to be initialized with the authService.
    @StateObject private var viewModel: LoginViewModel
    /// State to manage keyboard focus between fields.
    @FocusState private var focusedField: Field?

    /// Enum to identify focusable fields.
    private enum Field: Hashable {
        case username
        case password
    }

    /// Initializes the LoginView, creating the ViewModel with the AuthService.
    /// This ensures the ViewModel has access to the service passed via environment.
    init() {
        // Create the StateObject here, accessing the (soon-to-be-injected) EnvironmentObject
        // This pattern is generally discouraged, but necessary when StateObject needs EnvironmentObject.
        // A cleaner approach might involve passing authService explicitly if not using .environmentObject propagation from AuthView.
        // However, since AuthView *does* inject it, retrieving it during init is complex.
        // Alternative: Pass authService explicitly to LoginView if needed before body access.
        // For simplicity now, assuming AuthView correctly injects it before this view appears.
        // LET'S REVISIT THIS: Initialize ViewModel in .onAppear or pass explicitly if issues arise.
        // **Correction:** Initialize in the body or via init that accepts the service.
        // Simplest approach given AuthView injects it: Initialize directly in the @StateObject declaration
        // *after* ensuring AuthService is available. Or use a helper initializer.

         // Let's use a temporary placeholder and initialize properly later if needed,
         // but relying on EnvironmentObject passed from AuthView should work directly in most cases
         // if @StateObject is initialized correctly relative to the environment setup.
         // Best practice: Inject dependencies explicitly if possible.
         // Let's assume AuthView ensures authService is in the environment when LoginView appears.
         // We'll initialize the ViewModel *inside* the struct using the environment object.
         // This requires a custom init or accessing environment *before* body.

         // **Revised Approach for safer init:**
         // The View struct itself doesn't have access to @EnvironmentObject during its own init.
         // We must initialize @StateObject *before* body is called.
         // The most robust way is often to pass the required service if needed by the @StateObject's init.
         // Since AuthView passes authService via environment, LoginView should receive it.

         // Let's try initializing directly and rely on the environment being set up by AuthView.
         // This is common but technically relies on init order.
         self._viewModel = StateObject(wrappedValue: LoginViewModel(authService: AuthService.shared)) // Fallback if not passed explicitly

        // **More Correct Approach:** If LoginView is always created where authService is in the environment
        // (like in AuthView), @EnvironmentObject will be available *before* body is called.
        // So, we should initialize the ViewModel *inside* the View's body using the @EnvironmentObject.
        // No, @StateObject must be initialized *before* body.

        // **Final Robust Approach:** Create an initializer that accepts the authService if needed.
        // Or, if it's guaranteed by AuthView, let the ViewModel access it directly if passed.
        // Let's assume AuthView sets it up, and ViewModel will use the injected service.
        // The ViewModel init shown requires the service. Let's adjust AuthView to pass it, or structure differently.

        // **Simplification:** Let AuthView create LoginView and pass the service IF NEEDED by ViewModel init.
        // Since LoginViewModel *does* need it, let's assume AuthView passes it or it's globally accessible.
        // Using AuthService.shared directly in ViewModel init is okay if it's truly a singleton.
    }


    /// The main view content.
    var body: some View {
        // Use NavigationStack for modern navigation (iOS 16+)
        // If supporting older iOS, use NavigationView but be aware of potential issues.
        NavigationStack {
            VStack(spacing: 20) {
                branding // Logo and titles

                loginForm // Input fields and buttons

                Spacer()

                registrationLink // Link to Register screen
            }
            .padding()
            .navigationTitle("登录") // Set navigation title
            .navigationBarHidden(true) // Keep the bar hidden as per original logic
            // Use .alert(item: content:) for cleaner alert presentation
            .alert(item: $viewModel.alertItem) { item in
                Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("确定")))
            }
            // Use .sheet(isPresented: content:) for modal presentation
            .sheet(isPresented: $viewModel.showingForgotPasswordSheet) {
                ForgotPasswordView()
                    .environmentObject(authService) // Pass environment object down
            }
            .sheet(isPresented: $viewModel.showingRegisterSheet) {
                RegisterView()
                    .environmentObject(authService) // Pass environment object down
            }
            // Dismiss keyboard on tap outside
            .onTapGesture {
                focusedField = nil
            }
        }
        // Inject the ViewModel into the environment if child views need it (unlikely here)
        // .environmentObject(viewModel)
    }


    // MARK: - Subviews

    /// Branding elements: Logo and titles.
    private var branding: some View {
        VStack(spacing: 10) {
            Image("AppIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.bottom, 10)

            Text("iFrench")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue) // Consider Color.accentColor

            Text("法语学习伙伴")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 20) // Adjusted padding
        }
    }

    /// The login form containing input fields and buttons.
    private var loginForm: some View {
        VStack(spacing: 15) {
            // Username (Email) Field
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.blue) // Consider .accentColor
                    .frame(width: 24)

                TextField("邮箱", text: $viewModel.username)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress) // Autofill hint
                    .focused($focusedField, equals: .username) // Focus state
                    .submitLabel(.next) // Keyboard return key action
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)

            // Password Field
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.blue) // Consider .accentColor
                    .frame(width: 24)

                SecureField("密码", text: $viewModel.password)
                    .textContentType(.password) // Autofill hint
                    .focused($focusedField, equals: .password) // Focus state
                    .submitLabel(.done) // Keyboard return key action
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)

            // Login Button
            Button(action: viewModel.handleLogin) {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("登录")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.6 : 1.0)


            // Forgot Password Button
            Button("忘记密码?") {
                viewModel.showingForgotPasswordSheet = true
            }
            .font(.footnote)
            .foregroundColor(.blue) // Consider .accentColor
            .padding(.top, 5)
        }
        // Handle keyboard submission actions
        .onSubmit {
            switch focusedField {
            case .username:
                focusedField = .password // Move focus to password
            case .password:
                focusedField = nil // Dismiss keyboard
                viewModel.handleLogin() // Attempt login
            case .none:
                break
            }
        }
    }

    /// Link to navigate to the registration screen.
    private var registrationLink: some View {
        HStack {
            Text("还没有账号?")
            Button("注册") {
                viewModel.showingRegisterSheet = true
            }
            .fontWeight(.semibold)
            .foregroundColor(.blue) // Consider .accentColor
        }
        .font(.callout)
        .padding(.bottom, 20)
    }
}

// MARK: - LoginView Previews
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock or shared AuthService instance for the preview
        let mockAuthService = AuthService.shared // Or a specific mock instance
        LoginView()
            .environmentObject(mockAuthService) // Provide the service to the environment
    }
}
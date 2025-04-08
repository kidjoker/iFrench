import SwiftUI

// MARK: - Alert Item Structure
/// A structure to represent identifiable alert information for the Register screen.
struct RegisterAlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

// MARK: - Password Strength Enum
/// Represents different levels of password strength with associated descriptions and colors.
enum PasswordStrength {
    case empty
    case weak       // Less than 6 chars (or other criteria)
    case medium     // 6-9 chars (or other criteria)
    case strong     // 10+ chars (or other criteria)

    /// A textual description of the password strength.
    var description: String {
        switch self {
        case .empty: return "未设置" // Not Set
        case .weak: return "弱"     // Weak
        case .medium: return "中"   // Medium
        case .strong: return "强"   // Strong
        }
    }

    /// The color associated with the password strength level.
    var color: Color {
        switch self {
        case .empty: return .gray
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        }
    }

    /// Calculates the width fraction for the strength indicator bar.
    /// - Parameter totalWidth: The total available width for the bar.
    /// - Returns: The calculated width for the indicator segment.
    /// Note: Using totalWidth directly might be brittle. Consider fixed proportions.
    func barWidthFraction() -> CGFloat {
         switch self {
         case .empty: return 0
         case .weak: return 0.33
         case .medium: return 0.66
         case .strong: return 1.0
         }
     }
}

// MARK: - Register ViewModel
/// ViewModel responsible for managing the state and logic of the RegisterView.
@MainActor
final class RegisterViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var alertItem: RegisterAlertItem?
    /// Indicates if the registration operation is currently in progress. Relies on AuthService.
    var isLoading: Bool { authService.isLoading }
    /// Holds any error message from the AuthService.
    var errorMessage: String? { authService.errorMessage }

    // MARK: - Dependencies
    private var authService: AuthService

    // MARK: - Initialization
    init(authService: AuthService) {
        self.authService = authService
    }

    // MARK: - Computed Properties
    /// Calculates the current password strength based on the password input.
    var passwordStrength: PasswordStrength {
        if password.isEmpty {
            return .empty
        } else if password.count < 6 { // Example criteria
            return .weak
        } else if password.count < 10 { // Example criteria
            return .medium
        } else {
            return .strong
        }
    }

    /// Determines if the registration form is valid and the button should be enabled.
    var isRegisterButtonDisabled: Bool {
        // Check loading state first
        if isLoading { return true }
        // Check individual fields and conditions
        return username.isEmpty ||
               email.isEmpty ||
               password.isEmpty ||
               password != confirmPassword ||
               password.count < 6 // Reuse validation logic implicitly
    }

    // MARK: - Validation Methods (Private)
    /// Validates the email format.
    private var isEmailFormatValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    // MARK: - Actions
    /// Handles the registration button press action.
    func handleRegister() {
        // Perform comprehensive validation before calling the service
        guard isEmailFormatValid else {
            alertItem = RegisterAlertItem(title: "输入错误", message: "请输入有效的邮箱地址")
            return
        }

        guard password == confirmPassword else {
            alertItem = RegisterAlertItem(title: "密码不匹配", message: "请确保两次输入的密码一致")
            return
        }

        guard password.count >= 6 else {
            alertItem = RegisterAlertItem(title: "密码太短", message: "密码长度必须至少为6个字符")
            return
        }

        // Ensure previous errors are cleared
         authService.errorMessage = nil // Clear error by setting message to nil

        // Execute registration asynchronously
        // Task { // <-- Removed Task wrapper
        //     await authService.register(username: username, email: email, password: password) // <-- Removed await
        //     // Check for errors from the authService after the call
        //     if let errorMsg = authService.errorMessage {
        //          alertItem = RegisterAlertItem(title: "注册失败", message: errorMsg)
        //     }
        //      // If registration is successful, AuthView should react to the authState change.
        //      // No explicit navigation needed here if AuthView handles the switch.
        // }

        // Assuming AuthService.register uses a completion handler like: (Bool) -> Void
        authService.register(username: username, email: email, password: password) { success in
            // This closure executes when the registration call completes.
            // Since the ViewModel is @MainActor, UI updates are safe here.

            // Check if registration failed
            if !success {
                // If registration failed, check the errorMessage property for details
                let message = self.authService.errorMessage ?? "An unknown registration error occurred."
                self.alertItem = RegisterAlertItem(title: "注册失败", message: message)
            }
            // If success is true, AuthView handles the state change, no explicit action needed here
            // isLoading should also be managed by AuthService and reflected automatically
        }
    }
}

// MARK: - RegisterView Definition
/// A view for users to create a new account.
struct RegisterView: View {
    /// Environment value to dismiss the current view presentation.
    @Environment(\.dismiss) private var dismiss
    /// The shared authentication service, injected via the environment.
    @EnvironmentObject private var authService: AuthService
    /// The ViewModel managing the state and logic for this view.
    @StateObject private var viewModel: RegisterViewModel
    /// State to manage keyboard focus.
    @FocusState private var focusedField: Field?

    /// Enum to identify focusable fields.
    private enum Field: Hashable {
        case username, email, password, confirmPassword
    }

    /// Custom initializer to ensure ViewModel gets the AuthService.
    init() {
       // Initialize StateObject using the shared service instance.
       // Assumes AuthService.shared is the correct singleton pattern.
       self._viewModel = StateObject(wrappedValue: RegisterViewModel(authService: AuthService.shared))
    }

    var body: some View {
        // Use ScrollView to handle potentially long content on smaller screens
        ScrollView {
            VStack(spacing: 20) {
                header // Back button

                branding // Icon and titles

                registrationForm // Input fields

                loginLink // Link back to Login
            }
            .padding(.vertical) // Padding for scrollable content
        }
        .alert(item: $viewModel.alertItem) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("确定")))
        }
        // Dismiss keyboard on tap outside focusable area
        .contentShape(Rectangle()) // Make entire area tappable
        .onTapGesture {
            focusedField = nil
        }
        .navigationTitle("创建账户") // Set title if within a NavigationStack
        .navigationBarHidden(true) // Hide nav bar if not needed
    }

    // MARK: - Subviews
    /// The header containing the back button.
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("返回")
                }
                .foregroundColor(.blue) // Consider AccentColor
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    /// Branding elements like icon and titles.
    private var branding: some View {
        VStack(spacing: 5) {
            Image("AppIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                .padding(.top, 10)

            Text("创建账户")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10) // Adjusted padding

            Text("注册后开始您的法语学习之旅")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 15) // Adjusted padding
        }
    }

    /// The main registration form.
    private var registrationForm: some View {
        VStack(spacing: 15) {
            inputField(systemImage: "person.fill", placeholder: "用户名", text: $viewModel.username, focus: .username, contentType: .username)
                .disableAutocorrection(true) // Specific modifier for username

            inputField(systemImage: "envelope.fill", placeholder: "邮箱", text: $viewModel.email, focus: .email, contentType: .emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            passwordField(placeholder: "密码", text: $viewModel.password, focus: .password)

            // Password Strength Indicator (using GeometryReader for width calculation)
             passwordStrengthIndicator
                 .padding(.horizontal, 5) // Match padding if needed

            passwordField(placeholder: "确认密码", text: $viewModel.confirmPassword, focus: .confirmPassword)
                .overlay( // Show checkmark if passwords match and are not empty
                    HStack {
                        Spacer()
                        if !viewModel.password.isEmpty && viewModel.password == viewModel.confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .padding(.trailing)
                        }
                    }
                )


            registerButton
        }
        .padding(.horizontal, 20)
        // Handle keyboard submission flow
        .onSubmit {
             switch focusedField {
             case .username: focusedField = .email
             case .email: focusedField = .password
             case .password: focusedField = .confirmPassword
             case .confirmPassword:
                 focusedField = nil
                 viewModel.handleRegister() // Attempt registration on final submit
             case .none: break
             }
         }
    }

    /// Reusable input field component.
    private func inputField(systemImage: String, placeholder: String, text: Binding<String>, focus: Field, contentType: UITextContentType? = nil) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.blue) // Consider AccentColor
                .frame(width: 24)

            TextField(placeholder, text: text)
                .textContentType(contentType)
                .focused($focusedField, equals: focus)
                .submitLabel(focus == .confirmPassword ? .done : .next)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    /// Reusable secure field component for passwords.
    private func passwordField(placeholder: String, text: Binding<String>, focus: Field) -> some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundColor(.blue) // Consider AccentColor
                .frame(width: 24)

            SecureField(placeholder, text: text)
                .textContentType(.newPassword) // Hint for password managers
                .focused($focusedField, equals: focus)
                .submitLabel(focus == .confirmPassword ? .done : .next)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    /// The visual indicator for password strength.
    private var passwordStrengthIndicator: some View {
        VStack(alignment: .leading, spacing: 3) {
             // Only show if password is not empty
             if !viewModel.password.isEmpty {
                 HStack(spacing: 5) {
                     Text("密码强度：")
                     Text(viewModel.passwordStrength.description)
                         .foregroundColor(viewModel.passwordStrength.color)
                     Spacer()
                 }
                 .font(.caption)
                 .foregroundColor(.gray)

                 // Use GeometryReader to get available width for the bar
                 GeometryReader { geometry in
                     ZStack(alignment: .leading) {
                         Rectangle() // Background track
                             .frame(height: 4)
                             .foregroundColor(Color.gray.opacity(0.2))

                         Rectangle() // Strength indicator
                             .frame(width: geometry.size.width * viewModel.passwordStrength.barWidthFraction(), height: 4)
                             .foregroundColor(viewModel.passwordStrength.color)
                     }
                     .clipShape(Capsule()) // Use Capsule for rounded ends
                 }
                 .frame(height: 4) // Set height for GeometryReader
             }
         }
         // Add a fixed height to prevent layout jumps when indicator appears/disappears
         .frame(height: viewModel.password.isEmpty ? 0 : 25) // Adjust height as needed
         .animation(.easeInOut, value: viewModel.passwordStrength) // Animate changes
         .padding(.bottom, 5) // Add some space below indicator
    }


    /// The main registration button.
    private var registerButton: some View {
        Button(action: viewModel.handleRegister) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("注册")
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
        .padding(.top, 10)
        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
        .disabled(viewModel.isRegisterButtonDisabled)
        .opacity(viewModel.isRegisterButtonDisabled ? 0.6 : 1.0)
    }

    /// Link to navigate back to the login screen.
    private var loginLink: some View {
        HStack {
            Text("已有账户?")
            Button("登录") {
                dismiss() // Dismiss the registration sheet
            }
            .fontWeight(.semibold)
            .foregroundColor(.blue) // Consider AccentColor
        }
        .font(.callout)
        .padding(.top, 15) // Adjusted padding
        .padding(.bottom, 20)
    }
}

// MARK: - RegisterView Previews
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide the necessary environment object for the preview
        RegisterView()
            .environmentObject(AuthService.shared) // Use shared or mock service
    }
}
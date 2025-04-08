import SwiftUI

// MARK: - Alert Item Structure
/// A structure to represent identifiable alert information.
struct ForgotPasswordAlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    var isSuccess: Bool = false // Flag to know if dismissal should trigger navigation back
}

// MARK: - ForgotPassword ViewModel
/// ViewModel responsible for managing the state and logic of the ForgotPasswordView.
@MainActor // Ensures UI updates are published on the main thread
final class ForgotPasswordViewModel: ObservableObject {
    // MARK: - Published Properties
    /// The email address entered by the user.
    @Published var email: String = ""
    /// Indicates if a network operation (password reset request) is in progress.
    @Published var isLoading: Bool = false
    /// Holds the alert item to be presented to the user. Optional; nil means no alert.
    @Published var alertItem: ForgotPasswordAlertItem?

    // MARK: - Dependencies (Could be injected)
    // Assuming AuthService handles the actual reset request
    // private let authService: AuthService = AuthService.shared

    // MARK: - Computed Properties
    /// Determines if the email format is valid.
    private var isEmailValid: Bool {
        // Basic email validation regex
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    /// Determines if the reset password button should be enabled.
    var isResetButtonDisabled: Bool {
        isLoading || email.isEmpty
    }

    // MARK: - Methods
    /// Initiates the password reset process.
    func resetPassword() {
        guard !email.isEmpty else { return } // Should be disabled, but safeguard

        guard isEmailValid else {
            alertItem = ForgotPasswordAlertItem(
                title: "输入错误",
                message: "请输入有效的邮箱地址"
            )
            return
        }

        isLoading = true

        // --- TODO: Replace with actual network call using async/await ---
        // Example using AuthService:
        /*
        Task {
            do {
                // Assuming authService has a method like:
                // try await authService.requestPasswordReset(email: email)

                // If successful:
                self.alertItem = ForgotPasswordAlertItem(
                    title: "邮件已发送",
                    message: "密码重置链接已发送到您的邮箱，请查收",
                    isSuccess: true
                )
            } catch {
                // If error:
                self.alertItem = ForgotPasswordAlertItem(
                    title: "发送失败",
                    message: error.localizedDescription // Or a user-friendly message
                )
            }
            self.isLoading = false // Ensure isLoading is set back on completion/error
        }
        */

        // Simulating network request for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.alertItem = ForgotPasswordAlertItem(
                title: "邮件已发送",
                message: "密码重置链接已发送到您的邮箱，请查收",
                isSuccess: true
            )
        }
        // --- End TODO ---
    }
}

// MARK: - ForgotPasswordView Definition
/// A view allowing users to request a password reset link via email.
struct ForgotPasswordView: View {
    /// Environment value to dismiss the current view presentation.
    @Environment(\.dismiss) private var dismiss
    /// The ViewModel managing the state and logic for this view.
    @StateObject private var viewModel = ForgotPasswordViewModel()
    /// State to manage keyboard focus.
    @FocusState private var isEmailFocused: Bool

    /// The main view content.
    var body: some View {
        VStack(spacing: 20) {
            // Top Bar with Back Button
            header

            // Logo and Titles
            branding

            // Email Input Field
            emailField

            // Submit Button
            submitButton

            Spacer() // Pushes content to the top
        }
        .padding(.top, 10)
        // Present an alert when viewModel.alertItem is not nil
        .alert(item: $viewModel.alertItem) { item in
            Alert(
                title: Text(item.title),
                message: Text(item.message),
                dismissButton: .default(Text("确定")) {
                    if item.isSuccess {
                        dismiss() // Dismiss view on successful reset request confirmation
                    }
                }
            )
        }
        // Dismiss keyboard when tapping outside the text field
        .onTapGesture {
             isEmailFocused = false
        }
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
                .foregroundColor(.blue) // Consider using AccentColor
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    /// Branding elements like icon and titles.
    private var branding: some View {
        VStack(spacing: 10) {
            Image("AppIcon") // Ensure this image exists in Assets
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 20)) // Use clipShape for corner radius
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                .padding(.top, 20)

            Text("重置密码")
                .font(.title)
                .fontWeight(.bold)

            Text("请输入您的邮箱地址，我们将向您发送密码重置链接")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                .padding(.bottom, 10) // Adjusted padding
        }
    }

    /// The input field for the user's email address.
    private var emailField: some View {
        HStack {
            Image(systemName: "envelope.fill")
                .foregroundColor(.blue) // Consider AccentColor
                .frame(width: 24)

            TextField("邮箱", text: $viewModel.email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .textContentType(.emailAddress) // Improves autofill
                .focused($isEmailFocused) // Bind focus state
        }
        .padding()
        .background(Color(.systemGray6)) // Use semantic colors
        .clipShape(RoundedRectangle(cornerRadius: 8)) // Use clipShape
        .padding(.horizontal, 20)
    }

    /// The button to submit the password reset request.
    private var submitButton: some View {
        Button(action: viewModel.resetPassword) {
            Group { // Use Group to switch content easily
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("发送重置链接")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(
                LinearGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]), // Consider defining gradients elsewhere
                               startPoint: .leading,
                               endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12)) // Use clipShape
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
        .disabled(viewModel.isResetButtonDisabled) // Bind disabled state to ViewModel
        .opacity(viewModel.isResetButtonDisabled ? 0.6 : 1.0) // Visual cue for disabled state
    }
}

// MARK: - ForgotPasswordView Previews
/// Provides previews for the `ForgotPasswordView`.
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
            // You can optionally configure the viewModel for different preview states here
            // .environmentObject(AuthService.shared) // If ViewModel needed authService
    }
}
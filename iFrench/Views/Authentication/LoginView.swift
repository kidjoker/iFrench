import SwiftUI

/// Login screen view
struct LoginView: View {
    @EnvironmentObject private var authService: AuthService
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showingForgotPassword = false
    @State private var showingRegister = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo
                Image("AppIcon") // 使用应用图标
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 10)
                
                Text("iFrench")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
                    .padding(.bottom, 10)
                
                Text("法语学习伙伴")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 30)
                
                // Login form
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        TextField("邮箱", text: $username)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        SecureField("密码", text: $password)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    Button(action: handleLogin) {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing)
                                )
                                .cornerRadius(12)
                        } else {
                            Text("登录")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing)
                                )
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    .disabled(authService.isLoading)
                    
                    // Forgot password link
                    Button("忘记密码?") {
                        showingForgotPassword = true
                    }
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.top, 5)
                }
                
                Spacer()
                
                // Create account option
                HStack {
                    Text("还没有账号?")
                    Button("注册") {
                        showingRegister = true
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
                .font(.callout)
                .padding(.bottom, 20)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    // 隐藏导航栏的替代方案
                    EmptyView()
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("登录错误"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
                    .environmentObject(authService)
            }
            .sheet(isPresented: $showingRegister) {
                RegisterView()
                    .environmentObject(authService)
            }
        }
    }
    
    /// Handle the login process
    private func handleLogin() {
        // Validate inputs
        guard !username.isEmpty else {
            alertMessage = "请输入您的邮箱"
            showingAlert = true
            return
        }
        
        guard !password.isEmpty else {
            alertMessage = "请输入您的密码"
            showingAlert = true
            return
        }
        
        // Attempt login
        authService.login(email: username, password: password) { success in
            if !success, let errorMsg = authService.errorMessage {
                alertMessage = errorMsg
                showingAlert = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthService.shared)
    }
} 
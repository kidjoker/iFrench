import SwiftUI

/// 注册视图
struct RegisterView: View {
    @EnvironmentObject private var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    // 密码强度检查
    private var passwordStrength: PasswordStrength {
        if password.isEmpty {
            return .empty
        } else if password.count < 6 {
            return .weak
        } else if password.count < 10 {
            return .medium
        } else {
            return .strong
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 顶部返回按钮
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("返回")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // 图标
                Image("AppIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                    .padding(.top, 10)
                
                Text("创建账户")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 5)
                
                Text("注册后开始您的法语学习之旅")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                
                // 注册表单
                VStack(spacing: 15) {
                    // 用户名
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        TextField("用户名", text: $username)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 邮箱
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        TextField("邮箱", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 密码
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            SecureField("密码", text: $password)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        // 密码强度指示器
                        if !password.isEmpty {
                            HStack(spacing: 5) {
                                Text("密码强度：")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(passwordStrength.description)
                                    .font(.caption)
                                    .foregroundColor(passwordStrength.color)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 5)
                            
                            // 密码强度条
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 4)
                                    .foregroundColor(Color.gray.opacity(0.2))
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .frame(width: passwordStrength.barWidth(totalWidth: UIScreen.main.bounds.width - 60), height: 4)
                                    .foregroundColor(passwordStrength.color)
                                    .cornerRadius(2)
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                    
                    // 确认密码
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        SecureField("确认密码", text: $confirmPassword)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    // 注册按钮
                    Button(action: handleRegister) {
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
                            Text("注册")
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
                    .padding(.top, 10)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    .disabled(authService.isLoading || !isFormValid())
                }
                .padding(.horizontal, 20)
                
                // 已有账户
                HStack {
                    Text("已有账户?")
                    Button("登录") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
                .font(.callout)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .padding(.vertical)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("确定"))
            )
        }
    }
    
    /// 表单验证
    private func isFormValid() -> Bool {
        return !username.isEmpty && !email.isEmpty && !password.isEmpty && 
               password == confirmPassword && password.count >= 6
    }
    
    /// 处理注册逻辑
    private func handleRegister() {
        // 邮箱格式验证
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        guard emailPred.evaluate(with: email) else {
            alertTitle = "输入错误"
            alertMessage = "请输入有效的邮箱地址"
            showingAlert = true
            return
        }
        
        // 密码确认
        guard password == confirmPassword else {
            alertTitle = "密码不匹配"
            alertMessage = "请确保两次输入的密码一致"
            showingAlert = true
            return
        }
        
        // 密码长度检查
        guard password.count >= 6 else {
            alertTitle = "密码太短"
            alertMessage = "密码长度必须至少为6个字符"
            showingAlert = true
            return
        }
        
        // 执行注册
        authService.register(username: username, email: email, password: password) { success in
            if !success, let errorMsg = authService.errorMessage {
                alertTitle = "注册失败"
                alertMessage = errorMsg
                showingAlert = true
            } else if success {
                // 注册成功，会自动跳转到主界面
            }
        }
    }
}

/// 密码强度枚举
enum PasswordStrength {
    case empty
    case weak
    case medium
    case strong
    
    var description: String {
        switch self {
        case .empty: return "未设置"
        case .weak: return "弱"
        case .medium: return "中"
        case .strong: return "强"
        }
    }
    
    var color: Color {
        switch self {
        case .empty: return .gray
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        }
    }
    
    func barWidth(totalWidth: CGFloat) -> CGFloat {
        switch self {
        case .empty: return 0
        case .weak: return totalWidth * 0.3
        case .medium: return totalWidth * 0.6
        case .strong: return totalWidth * 0.9
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthService.shared)
    }
} 
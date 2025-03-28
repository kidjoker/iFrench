import SwiftUI

/// 忘记密码视图
struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isSuccess: Bool = false
    
    var body: some View {
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
                .padding(.top, 20)
            
            Text("重置密码")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10)
            
            Text("请输入您的邮箱地址，我们将向您发送密码重置链接")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            
            // 邮箱输入框
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
            .padding(.horizontal, 20)
            
            // 提交按钮
            Button(action: resetPassword) {
                if isLoading {
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
                    Text("发送重置链接")
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
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
            .disabled(isLoading || email.isEmpty)
            
            Spacer()
        }
        .padding(.top, 10)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("确定")) {
                    if isSuccess {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    /// 执行密码重置流程
    private func resetPassword() {
        guard !email.isEmpty else { return }
        
        // 邮箱格式验证
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        guard emailPred.evaluate(with: email) else {
            alertTitle = "输入错误"
            alertMessage = "请输入有效的邮箱地址"
            showAlert = true
            return
        }
        
        isLoading = true
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            isSuccess = true
            alertTitle = "邮件已发送"
            alertMessage = "密码重置链接已发送到您的邮箱，请查收"
            showAlert = true
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
} 
//
//  LogInView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-06-02.
//

import SwiftUI
import AuthenticationServices

enum LogInFocusableField: Hashable{
    case email, password
}

struct LogInView: View{
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var showPassword = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showLoading: Bool = false
    @FocusState private var loginFocus: LogInFocusableField?
    @State private var emailError: String?
    @State private var passwordError: String?
    
    var body: some View{
        NavigationView {
            ZStack {
                VStack{
                    Spacer()
                    VStack(alignment: .center) {
                        Text("Welcome to")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .fontDesign(.rounded)
                        Text("Scavenger Hunt")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.accentColor)
                    }
                    Spacer()
                    VStack(alignment: .leading){
                        TextField("Email", text: $email)
                            .modifier(CustomTextFieldStyle())
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.next)
                            .focused($loginFocus, equals: .email)
                            .onSubmit {
                                self.loginFocus = .password
                            }
                            .onChange(of: email) { newValue in
                                if !validateEmail(newValue){
                                    emailError = "Please enter a valid email."
                                }else{
                                    emailError = nil
                                }
                            }
                        if let emailErr = emailError{
                            Text(emailErr)
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                        HStack{
                            if showPassword {
                                TextField("Password", text: $password)
                                    .modifier(CustomTextFieldStyle())
                                    .textContentType(.password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .focused($loginFocus, equals: .password)
                                    .submitLabel(.go)
                                    .onSubmit {
                                        login()
                                    }
                            } else {
                                SecureField("Password", text: $password)
                                    .modifier(CustomTextFieldStyle())
                                    .textContentType(.password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .focused($loginFocus, equals: .password)
                                    .submitLabel(.go)
                                    .onSubmit {
                                        login()
                                    }
                            }
                        }
                        .onChange(of: password) { newValue in
                            if !validatePassword(newValue){
                                passwordError = "Please enter a valid password."
                            }else{
                                passwordError = nil
                            }
                        }
                        .overlay {
                            HStack{
                                Spacer()
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                        }
                        if let passErr = passwordError{
                            Text(passErr)
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                    }
                    .font(.headline)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            
                        }, label: {
                            Text("Forgot Password?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                    })
                    }
                    Button(action: {
                        login()
                    }, label: {
                        Text("Login")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .foregroundColor(.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.accentColor]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(6)
                    })
                    .padding(.top, 8)
                    NavigationLink(destination: {
                        SignUpView()
                    }, label: {
                        Text("Sign Up")
                            .font(.title3)
                            .fontWeight(.medium)
                    })
                    .buttonStyle(.borderless)
                    .padding(.top)
//                    HStack {
//                        VStack {
//                            Divider()
//                                .background(.secondary)
//                        }
//                        Text("OR")
//                            .foregroundColor(.secondary)
//                        VStack {
//                            Divider()
//                                .background(.secondary)
//                        }
//                    }
//                    .padding(.horizontal, 20)
//
//                    SignInWithAppleView()
//                        .frame(height: 60, alignment: .center)
//                        .onTapGesture(perform: showAppleLoginView)
//                        .frame(maxWidth: .infinity)
//                        .padding(.horizontal, 20)
                }
                .allowsHitTesting(!showLoading)
                .modifier(DismissKeyboardOnTap())
                if showLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(width: 80, height: 80, alignment: .center)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(20)
        }
    }
}

extension LogInView{
    private func validateLoginForm() -> String {
        var errorMessage: String = ""
        
        if !validateEmail(email) {
            errorMessage.append("Please enter a valid email\n")
        }
        
        if !validatePassword(password) {
            errorMessage.append("Please enter a valid password")
        }
        return errorMessage
    }
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func validatePassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func login() {
        let message = validateLoginForm()
        if message == ""{
            showLoading = true
            Task{
                await authVM.login(email: email, password: password)
                showLoading = false
            }
        }else {
            authVM.appError = AppError(title: "Validation Failed", message: message)
            authVM.showAlert = true
        }
    }
    private func showAppleLoginView() {
        let signInWithAppleViewModel = SignInWithAppleViewModel()
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = signInWithAppleViewModel
        controller.performRequests()
      }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
            .environmentObject(AuthViewModel())
    }
}

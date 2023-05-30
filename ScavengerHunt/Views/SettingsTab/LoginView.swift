//
//  LoginView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-04.
//

import SwiftUI
import AuthenticationServices

enum FocusableField: Hashable{
    case email, password, name, confirmPassword
}

struct LoginView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var showLogin: Bool = true
    @State private var showLoading: Bool = false

    var body: some View {
        ScrollView {
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
            .padding(.vertical, 30)

            ZStack {
                LogInView(authVM: authVM, showLogin: $showLogin, showLoading: $showLoading)
                    .offset(x: showLogin ? 0 : -UIScreen.main.bounds.width)
                    .animation(.spring(), value: showLogin)
                    .zIndex(showLogin ? 1 : 0)
                    .padding(.horizontal, 20)

                SignUpView(authVM: authVM, showLogin: $showLogin, showLoading: $showLoading)
                    .offset(x: showLogin ? UIScreen.main.bounds.width : 0)
                    .animation(.spring(), value: showLogin)
                    .zIndex(showLogin ? 0 : 1)
                    .padding(.horizontal, 20)
            }

            HStack {
                VStack {
                    Divider()
                        .background(.secondary)
                }
                Text("OR")
                    .foregroundColor(.secondary)
                VStack {
                    Divider()
                        .background(.secondary)
                }
            }
            .padding(.horizontal, 20)

            SignInWithAppleView()
                .frame(height: 60, alignment: .center)
                .onTapGesture(perform: showAppleLoginView)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
        }
        .overlay(
            Group {
                if showLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(width: 80, height: 80, alignment: .center)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                }
            }
        )
        .allowsHitTesting(!showLoading)
        .alert(authVM.appError?.title ?? "", isPresented: $authVM.showAlert) {
            Text("OK")
        } message: {
            Text(authVM.appError?.message ?? "")
        }

    }
}

struct CustomTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 6).stroke(lineWidth: 0.5).fill(.primary.opacity(0.4)))
            .padding(.bottom, 5)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Add this custom view modifier
struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .gesture(TapGesture().onEnded { _ in
                UIApplication.shared.endEditing()
            })
    }
}

extension LoginView{
    struct LogInView: View{
        @ObservedObject var authVM: AuthViewModel
        @Binding var showLogin: Bool
        @State private var showPassword = false
        @State private var email: String = ""
        @State private var password: String = ""
        @Binding var showLoading: Bool
        @FocusState private var loginFocus: FocusableField?
        @State private var emailError: String?
        @State private var passwordError: String?
        
        
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
        
        var body: some View{
            VStack{
                VStack(alignment: .leading){
                    TextField("Email", text: $email)
                        .modifier(CustomTextFieldStyle())
                        .textContentType(.emailAddress)
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
                Button(action: {
                    showLogin = false
                },label: {
                    Text("Sign Up")
                        .font(.title3)
                        .fontWeight(.medium)
                })
                .buttonStyle(.borderless)
                .padding(.top)
            }
            .modifier(DismissKeyboardOnTap())
        }
    }
    
    struct SignUpView: View{
        @ObservedObject var authVM: AuthViewModel
        @Binding var showLogin: Bool
        @State private var name: String = ""
        @State private var email: String = ""
        @State private var password: String = ""
        @Binding var showLoading: Bool
        @FocusState private var signupFocus: FocusableField?
        @State private var showPassword = false
        @State private var nameError: String?
        @State private var emailError: String?
        @State private var passwordError: String?
        
        private func validateSignUpForm() -> String {
            var errorMessage: String = ""
            
            if !validateName(name){
                errorMessage.append("Please enter a valid name\n")
            }
            
            if !validateEmail(email) {
                errorMessage.append("Please enter a valid email\n")
            }
            
            if !validatePassword(password) {
                errorMessage.append("Please enter a valid password")
            }
            return errorMessage
        }

        private func signUp(){
            let message = validateSignUpForm()
            if message == "" {
                showLoading = true
                Task {
                    await authVM.signUp(name: name, email: email, password: password)
                    showLoading = false
                }
            }else {
                authVM.appError = AppError(title: "Validation Failed", message: message)
                authVM.showAlert = true
            }
        }
        
        func validateName(_ name: String) -> Bool {
            let nameRegex = "^[a-zA-Z]{2,}(?: [a-zA-Z]+){0,2}$"
            let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
            return namePredicate.evaluate(with: name)
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
        
        var body: some View{
            VStack{
                VStack(alignment: .leading){
                    TextField("Name", text: $name)
                        .modifier(CustomTextFieldStyle())
                        .textContentType(.name)
                        .keyboardType(.default)
                        .submitLabel(.next)
                        .focused($signupFocus, equals: .name)
                        .onSubmit {
                            self.signupFocus = .email
                        }
                        .onChange(of: name, perform: { newValue in
                            if !validateName(newValue){
                                nameError = "Please enter a valid name."
                            }else{
                               nameError = nil
                            }
                        })
                    if let nameErr = nameError{
                        Text(nameErr)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    TextField("Email", text: $email)
                        .modifier(CustomTextFieldStyle())
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .focused($signupFocus, equals: .email)
                        .onSubmit {
                            self.signupFocus = .password
                        }
                        .onChange(of: email, perform: { newValue in
                            if !validateEmail(newValue){
                                emailError = "Please enter a valid email."
                            }else{
                               emailError = nil
                            }
                        })
                    if let emailErr = emailError{
                        Text(emailErr)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    HStack{
                        if showPassword {
                            TextField("Password", text: $password)
                                .modifier(CustomTextFieldStyle())
                                .textContentType(.newPassword)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($signupFocus, equals: .password)
                                .submitLabel(.go)
                                .onSubmit {
                                    signUp()
                                }
                        } else {
                            SecureField("Password", text: $password)
                                .modifier(CustomTextFieldStyle())
                                .textContentType(.newPassword)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($signupFocus, equals: .password)
                                .submitLabel(.go)
                                .onSubmit {
                                    signUp()
                                }
                        }
                    }.onChange(of: password, perform: { newValue in
                        if !validatePassword(newValue){
                            passwordError = "Please enter a valid password."
                        }
                        else{
                            passwordError = nil
                        }
                    })
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
                Button(action: {
                    signUp()
                }, label: {
                    Text("Sign Up")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.accentColor]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(6)
                })
                .padding(.top)
                Button(action: {
                    showLogin = true
                },label: {
                    Text("Back")
                        .font(.title3)
                        .fontWeight(.medium)
                })
                .buttonStyle(.borderless)
                .padding(.top)
            }
            .modifier(DismissKeyboardOnTap())
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authVM: AuthViewModel())
    }
}

//
//  SignUpView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-06-02.
//

import SwiftUI
import AuthenticationServices

enum SignUpFocusableField: Hashable{
    case email, password, name, confirmPassword
}

struct SignUpView: View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showLoading: Bool = false
    @FocusState private var signupFocus: SignUpFocusableField?
    @State private var showPassword = false
    @State private var nameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    
    var body: some View{
        NavigationView {
            ZStack {
                VStack{
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
                                    nameError = "Please enter a valid name. Less than 18 characters"
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
                        dismiss()
                    }, label: {
                        Text("Back")
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

extension SignUpView{
    private func validateSignUpForm() -> String {
        var errorMessage: String = ""
        
        if !validateName(name){
            errorMessage.append("Please enter a valid name less than 18 Characters")
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
        guard name.count <= 18 else{return false}
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}

//
//  SignUpView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-18.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = SignUpViewModel()
    @FocusState private var focus: FocusableField?
    @State private var isSigningIn: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading){
                    titleSection
                    formFields
                    Button("Terms and Conditions") {
                        
                    }
                    .padding(.top, 10)
                    signUpButton
                    loginButton
                }
                .alert(item: $viewModel.appError, content: { appError in
                    Alert(title: Text(appError.title), message: Text(appError.message))
                })
                .padding()
                Spacer()
            }
            .navigationTitle("Scavenger Hunt")
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

extension SignUpView{
    private var titleSection: some View{
        VStack(alignment: .center){
            Text("Sign Up to create an Account")
                .padding(.bottom)
        }
    }
    private var formFields: some View{
        VStack(alignment: .leading){
            TextField("Full Name", text: $viewModel.name)
                .textContentType(.name)
                .focused($focus, equals: .name)
                .submitLabel(.next)
                .onSubmit {
                    focus = .email
                }
            if(viewModel.showErrors && !viewModel.isNameCriteriaValid){
                Text(viewModel.namePrompt)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 8)
            }
            TextField("Email ID", text: $viewModel.email)
                .textContentType(.username)
                .keyboardType(.emailAddress)
                .focused($focus, equals: .email)
                .submitLabel(.next)
                .onSubmit {
                    focus = .password
                }
            if(viewModel.showErrors && !viewModel.isEmailCriteriaValid){
                Text(viewModel.emailPrompt)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 8)
            }
            SecureField("New Password", text: $viewModel.password)
                .textContentType(.newPassword)
                .focused($focus, equals: .password)
                .submitLabel(.go)
                .onSubmit {
                    submit()
                }
            if(viewModel.showErrors && !viewModel.isPasswordCriteriaValid){
                Text(viewModel.passwordPrompt)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 8)
            }else{
                Text(viewModel.passwordPrompt)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.caption)
                    .padding(.leading, 8)
            }
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .disabled(isSigningIn)
    }
    private var signUpButton: some View{
        Button {
            submit()
        } label: {
            HStack(spacing: 10){
                if(isSigningIn){
                    Text("Signing Up")
                        .font(.headline)
                    ProgressView()
                        .font(.headline)
                        .tint(.white)
                }else{
                    Text("Sign Up")
                        .font(.headline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 35)
        }
        .buttonStyle(BorderedProminentButtonStyle())
    }
    private var loginButton: some View{
        HStack{
            Text("Already Have an account?")
            Button(action: { self.presentationMode.wrappedValue.dismiss()}, label: {
                HStack(spacing: 10){
                    Text("Log In")
                        .font(.headline)
                }
            })
            .buttonStyle(.borderless)
        }
    }
    
    func submit(){
        if(viewModel.canSubmit){
            focus = nil
            isSigningIn = true
            Task{
                await viewModel.signUp()
                isSigningIn = false
            }
        }else{
            viewModel.showErrors = true
            let alertTitle = "Fields Empty"
            let alertMessage = "Please fill all the fields"
            viewModel.appError = AppError(title: alertTitle, message: alertMessage)
        }
    }
}

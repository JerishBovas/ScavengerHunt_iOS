//
//  SignUpView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-06-02.
//

import SwiftUI
import Combine
import FirebaseAnalyticsSwift
import GoogleSignInSwift
import AuthenticationServices

private enum FocusableField: Hashable {
    case email
    case password
    case confirmPassword
}

struct SignupView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @FocusState private var focus: FocusableField?

    private func signUpWithEmailPassword() {
        Task {
            if await authVM.signUpWithEmailPassword() == true {
                dismiss()
            }
        }
    }
    
    private func signInWithGoogle() {
        Task {
            if await authVM.signInWithGoogle() == true {
                dismiss()
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign Up")
                .font(.title)
                .fontWeight(.bold)
            Text("Sign up for a new \"Scavenger Hunt\" account")
                .font(.footnote)
                .foregroundStyle(.secondary)
            VStack(spacing: 16){
                HStack {
                    Image(systemName: "at")
                    TextField("Email", text: $authVM.email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focus, equals: .email)
                        .submitLabel(.next)
                        .onSubmit {
                            self.focus = .password
                        }
                }
                .font(.headline)
                .padding(10)
                .frame(height: 45, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(lineWidth: 1.0))
                
                HStack {
                    Image(systemName: "lock")
                    SecureField("Password", text: $authVM.password)
                        .focused($focus, equals: .password)
                        .submitLabel(.next)
                        .onSubmit {
                            self.focus = .confirmPassword
                        }
                }
                .font(.headline)
                .padding(10)
                .frame(height: 45, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(lineWidth: 1.0))
                
                HStack {
                    Image(systemName: "lock")
                    SecureField("Confirm password", text: $authVM.confirmPassword)
                        .focused($focus, equals: .confirmPassword)
                        .submitLabel(.go)
                        .onSubmit {
                            signUpWithEmailPassword()
                        }
                }
                .font(.headline)
                .padding(10)
                .frame(height: 45, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(lineWidth: 1.0))
                
                
                if !authVM.errorMessage.isEmpty {
                    VStack {
                        Text(authVM.errorMessage)
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                }
                
                Button(action: signUpWithEmailPassword) {
                    if authVM.authenticationState != .authenticating {
                        Text("Sign up")
                            .font(.headline)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!authVM.isValid)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
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
            
            SignInWithAppleButton(.continue) { request in
                authVM.handleSignInWithAppleRequest(request)
            } onCompletion: { result in
                authVM.handleSignInWithAppleCompletion(result)
            }
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
            .frame(height: 50, alignment: .center)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            Button(action: signInWithGoogle) {
                HStack(spacing: 5){
                    Image("Google")
                        .resizable()
                        .frame(width: 15, height: 15)
                    Text("Continue with Google")
                        .font(.system(size: 19, weight: .medium, design: .default))
                        .foregroundStyle(.black)
                }
                .frame(height: 35, alignment: .center)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .clipped()
            .shadow(radius: 2)
            
            HStack {
                Text("Already have an account?")
                Button(action: { authVM.switchFlow() }) {
                    Text("Log in")
                        .fontWeight(.semibold)
                        .foregroundColor(.accent)
                }
            }
            .padding([.top, .bottom], 10)
        }
        .listStyle(.plain)
        .padding(.horizontal)
        .analyticsScreen(name: "\(Self.self)")
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            SignupView()
                .environmentObject(AuthenticationViewModel())
        }
    }
}

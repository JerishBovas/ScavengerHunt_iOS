//
//  LogInView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-06-02.
//

import SwiftUI
import Combine
import FirebaseAnalyticsSwift
import AuthenticationServices
import GoogleSignInSwift

private enum FocusableField: Hashable {
    case email
    case password
}

struct LoginView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @FocusState private var focus: FocusableField?

    private func signInWithEmailPassword() {
        Task {
            if await authVM.signInWithEmailPassword() == true {
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
        VStack(spacing: 16){
            Text("Login")
                .font(.title)
                .fontWeight(.bold)
            Text("Login to Scavenger Hunt with your existing account")
                .font(.footnote)
                .foregroundStyle(.secondary)
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
                    .submitLabel(.go)
                    .onSubmit {
                        signInWithEmailPassword()
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
            
            Button(action: signInWithEmailPassword) {
                if authVM.authenticationState != .authenticating {
                    Text("Login")
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
            
            HStack{
              VStack { Divider() }
              Text("or")
              VStack { Divider() }
            }
            
            SignInWithAppleButton(.continue) { request in
              authVM.handleSignInWithAppleRequest(request)
            } onCompletion: { result in
              authVM.handleSignInWithAppleCompletion(result)
            }
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
            .frame(height: 50, alignment: .center)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
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
                Text("Don't have an account yet?")
                Button(action: { authVM.switchFlow() }) {
                    Text("Sign up")
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            LoginView()
                .environmentObject(AuthenticationViewModel())
        }
    }
}

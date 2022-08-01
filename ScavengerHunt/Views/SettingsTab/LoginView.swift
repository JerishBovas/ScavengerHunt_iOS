//
//  LoginSheetView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-21.
//

import SwiftUI

enum FocusableField: Hashable{
    case email, password, name, confirmPw
}

struct LoginView: View {
    @EnvironmentObject var VM: LoginViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State var isLoggingIn: Bool = false
    @FocusState private var focus: FocusableField?
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(alignment: .leading){
                titleSection
                Divider()
                formFields
                Button("Forgot Password?") {
                    
                }
                .padding(.top, 8)
                loginButton
                signUpButton
            }
            .padding()
            Spacer()
        }
        .alert(item: $VM.appError, content: { appError in
            Alert(title: Text(appError.title), message: Text(appError.message))
        })
    }
}

extension LoginView{
    private var titleSection: some View{
        VStack(alignment: .leading){
            Text("Welcome to")
                .font(.title)
                .fontWeight(.semibold)
            Text("Scavenger Hunt")
                .font(.system(.title, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
                .padding(.bottom)
            Text("Please Log In to Continue...")
        }
    }
    private var formFields: some View {
        VStack{
            LoginField(title: "Email ID", text: $email)
                .textContentType(.username)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
                .focused($focus, equals: .email)
                .onSubmit {
                    self.focus = .password
                }
            LoginField(title: "Password", text: $password, isSecure: true)
                .textContentType(.password)
                .focused($focus, equals: .password)
                .submitLabel(.go)
                .onSubmit {
                    isLoggingIn = true
                    Task{
                        if(email != "" && password != ""){
                            await VM.login(email: email, password: password)
                        }
                        isLoggingIn = false
                    }
                }
        }
    }
    private var loginButton: some View{
        Button {
            isLoggingIn = true
            Task{
                if(email != "" && password != ""){
                    await VM.login(email: email, password: password)
                }
                isLoggingIn = false
            }
        } label: {
            HStack(spacing: 10){
                if(isLoggingIn){
                    Text("Logging In")
                        .font(.headline)
                    ProgressView()
                        .font(.headline)
                        .tint(.white)
                }else{
                    Text("Log In")
                        .font(.headline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 35)
        }
        .buttonStyle(BorderedProminentButtonStyle())
    }
    private var signUpButton: some View{
        HStack{
            Text("New to Scavenger Hunt?")
            NavigationLink(destination: SignUpView(), label: {
                HStack(spacing: 10){
                    Text("Sign Up")
                        .font(.headline)
                }
            })
            .buttonStyle(.borderless)
        }
    }
}

struct LoginField: View {
    var title: String
    @Binding var text: String
    @State var isSecure: Bool = false
    
    var body: some View {
        HStack{
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            if isSecure{
                SecureField("Required", text: $text)
                    .frame(maxWidth: 250, alignment: .trailing)
            }
            else{
                TextField("Required", text: $text)
                    .frame(maxWidth: 250, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
        Divider()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(LoginViewModel())
    }
}

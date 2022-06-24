//
//  LoginSheetView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-21.
//

import SwiftUI

struct LoginSheetView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State var isLoggingIn: Bool = false
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                TextField("Email", text: $email)
                    .padding()
                    .font(.headline)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(5)
                    .padding(.bottom, 10)
                SecureField("Password", text: $password)
                    .padding()
                    .font(.headline)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(5)
                    .padding(.bottom, 10)
                Button {
                    
                } label: {
                    Text("Forgot password?")
                }
                .padding(.bottom, 10)
                
                Button {
                    isLoggingIn = true
                    Task{
                        if(email != "" && password != ""){
                            await authVM.login(email: email, password: password)
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
                    .frame(maxWidth: .infinity, maxHeight: 40)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                Button {
                    
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderlessButtonStyle())
                Spacer()
            }
            .navigationTitle("Login")
            .padding()
        }
    }
}

struct LoginSheetView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSheetView()
            .environmentObject(AuthViewModel())
    }
}

//
//  ProfileView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-28.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State var searchString: String = ""
    
    var body: some View {
        NavigationView {
            if(authVM.isAuthenticated){
                VStack{
                    Text(authVM.user?.name ?? "Name")

                }
                .navigationTitle("Settings")
                .searchable(text: $searchString)
                .onAppear {
                    Task{
                        if authVM.user == nil {
                            await authVM.getAccount()
                        }
                    }
                }
            }
            else{
                Button {
                    authVM.showLogin = true
                } label: {
                    Text("Login")
                }
                .buttonStyle(BorderedButtonStyle())
                .sheet(isPresented: $authVM.showLogin) {
                    LoginSheetView()
                }
                .navigationTitle("Settings")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}

extension SettingsView{
    
}

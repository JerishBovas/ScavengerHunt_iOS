//
//  RootView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-03-29.
//

import SwiftUI

struct RootView: View {
    @State private var firstCheck = true
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        VStack{
            if !authViewModel.isAuthenticated{
                LoginView(authVM: authViewModel)
                    .onAppear{
                        firstCheck = false
                    }
            }
            else if firstCheck{
                loggingInSection
            }
            else{
                TabBarView()
            }
        }
        .alert(authViewModel.appError?.title ?? "", isPresented: $authViewModel.showAlert) {
            Text("OK")
        } message: {
            Text(authViewModel.appError?.message ?? "")
        }
    }
}

extension RootView{
    private var loggingInSection: some View{
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
            HStack{
                VStack(alignment: .center){
                    Text("Logging In...")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                    ProgressView()
                }
                .foregroundColor(.accentColor)
            }
            .padding(.top, 100)
            Spacer()
        }
        .task {
            try? await authViewModel.refreshToken()
            firstCheck = false
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AuthViewModel())
    }
}

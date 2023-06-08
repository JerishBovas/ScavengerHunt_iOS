//
//  RootView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-03-29.
//

import SwiftUI

struct RootView: View {
    @State private var firstCheck = true
    @State private var authNeeded = true
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        VStack{
            if authViewModel.isAuthenticated{
                TabBarView()
            }
        }
        .fullScreenCover(isPresented: .constant(!authViewModel.isAuthenticated), content: {
            VStack {
                if firstCheck{
                    loggingInSection
                }else {
                    LogInView()
                }
            }
        })
        .task {
            try? await authViewModel.refreshToken()
            firstCheck = false
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
            ProgressView()
                .scaleEffect(1.5)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AuthViewModel())
    }
}

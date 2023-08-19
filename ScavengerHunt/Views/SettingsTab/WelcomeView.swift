//
//  WelcomeView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-07-31.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var authVM: AuthenticationViewModel
    @State private var isLogoVisible = false
    @State private var isTitleVisible = false
    @State private var isTextVisible = false
    @State private var isSignUpButtonPressed = false
    @State private var isLoginButtonPressed = false
    
    var body: some View {
        VStack(spacing: 16){
            VStack(spacing: 0){
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .opacity(isLogoVisible ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0), value: isLogoVisible)
                Text("Scavenger Hunt")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(LinearGradient(colors: [.cyan, .yellow, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .padding(.top, -8)
                    .opacity(isTitleVisible ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0), value: isTitleVisible)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 8){
                HStack(spacing: 16){
                    Image("arGame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    VStack(alignment: .leading){
                        Text("AR Exploration")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Discover virtual treasures in real-world locations and interact with them in a completely immersive way.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Divider()
                    .padding(.leading, 76)
                HStack(spacing: 16){
                    Image("tailorGame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    VStack(alignment: .leading){
                        Text("Personalized Hunts")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Choose from different themes, locations, and challenges for a unique treasure hunting experience every time.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Divider()
                    .padding(.leading, 76)
                HStack(spacing: 16){
                    Image("socialIntegration")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    VStack(alignment: .leading){
                        Text("Social Integration")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Compete with your friends, share your scores, and invite others to join the hunt with our app's social features.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Divider()
                    .padding(.leading, 76)
                HStack(spacing: 16){
                    Image("funLearning")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    VStack(alignment: .leading){
                        Text("Learning with Fun")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Each challenge is designed to teach something new - be it historical facts, geography, or scientific wonders.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.primary, in: RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(lineWidth: 1.0))
            Spacer()
            Text("Login for a seamless experience across devices")
                .font(.footnote)
                .foregroundStyle(.secondary)
            VStack(spacing: 16){
                HStack(spacing: 16){
                    NavigationLink(destination: AuthenticationView()
                        .environmentObject(authVM)) {
                        Text("Log In")
                            .font(.title3)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, maxHeight: 30)
                    }
                    .buttonStyle(.borderedProminent)
                    .scaleEffect(isLoginButtonPressed ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isLoginButtonPressed)
                    .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                        isLoginButtonPressed = pressing
                    }, perform: { })
                }
                Button("Continue without account") {
                    Task{
                        await authVM.signInAnonymously()
                    }
                }
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLogoVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isTitleVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isTextVisible = true
            }
        }
    }
}

struct WelcomeView_Preview: PreviewProvider{
    static var previews: some View{
        NavigationView{
            WelcomeView()
                .environmentObject(AuthenticationViewModel())
        }
    }
}

//
//  WelcomeView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-07-31.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var authVM: AuthenticationViewModel
    @State private var isSignUpButtonPressed = false
    @State private var isLoginButtonPressed = false
    
    var body: some View {
        VStack(spacing: 48){
            VStack(spacing: 0){
                Text("Welcome to")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                Text("Scavenger Hunt")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(LinearGradient(stops: [.init(color: .cyan, location: 0.1), .init(color: .purple, location: 0.5), .init(color: .red, location: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            FeaturesView()
            VStack{
                Text("Sign In for a seamless experience across devices")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                HStack(spacing: 16){
                    NavigationLink(destination: AuthenticationView()) {
                        Text("Continue to Sign In")
                            .font(.title3)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, maxHeight: 30)
                    }
                    .buttonStyle(.borderedProminent)
                }
                Button(action: {
                    Task{
                        await authVM.signInAnonymously()
                    }
                }, label: {
                    Text("Skip")
                })
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundStyle(.accent)
                .padding(.top, 10)
            }
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .background(SlantedRectangle())
    }
}

extension WelcomeView{
    private struct SlantedRectangle: View {
        var body: some View {
            GeometryReader{ geometry in
                let width = geometry.size.width
                let startPoint = (geometry.size.height - width)/2
                Path{ path in
                    path.move(to: CGPoint(x: width, y: startPoint))
                    path.addLine(to: CGPoint(x: width, y: startPoint + width/2))
                    path.addQuadCurve(to: CGPoint(x: 0, y: startPoint + width), control: CGPoint(x: Int(width/2), y: Int(startPoint) + Int(width/1.6)))
                    path.addLine(to: CGPoint(x: 0, y: startPoint + width/3))
                    path.addQuadCurve(to: CGPoint(x: width, y: startPoint), control: CGPoint(x: Int(width/2), y: Int(startPoint) + Int(width/2)))
                }
                .fill(.linearGradient(colors: [.purple, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                .scaledToFit()
            }
        }
    }
    
    private struct FeaturesView: View {
        var body: some View {
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
                            .foregroundStyle(.pink)
                        Text("Discover virtual treasures in real-world locations and interact with them in a completely immersive way.")
                            .font(.footnote)
                            .foregroundStyle(.primary)
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
                            .foregroundStyle(.pink)
                        Text("Choose from different themes, locations, and challenges for a unique treasure hunting experience every time.")
                            .font(.footnote)
                            .foregroundStyle(.primary)
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
                            .foregroundStyle(.pink)
                        Text("Compete with your friends, share your scores, and invite others to join the hunt with our app's social features.")
                            .font(.footnote)
                            .foregroundStyle(.primary)
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
                            .foregroundStyle(.pink)
                        Text("Each challenge is designed to teach something new - be it historical facts, geography, or scientific wonders.")
                            .font(.footnote)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(radius: 5)
        }
    }
}

#Preview{
    NavigationView{
        WelcomeView()
            .environmentObject(AuthenticationViewModel())
    }
}

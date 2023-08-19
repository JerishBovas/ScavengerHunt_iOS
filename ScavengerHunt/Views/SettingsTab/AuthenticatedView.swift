//
//  AuthenticatedView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-07-25.
//

import SwiftUI
import AuthenticationServices

extension AuthenticatedView where Unauthenticated == EmptyView {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = nil
        self.content = content
    }
}

struct AuthenticatedView<Content, Unauthenticated>: View where Content: View, Unauthenticated: View {
    @StateObject private var viewModel = AuthenticationViewModel()

    var unauthenticated: Unauthenticated?
    @ViewBuilder var content: () -> Content

    public init(unauthenticated: Unauthenticated?, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = unauthenticated
        self.content = content
    }

    public init(@ViewBuilder unauthenticated: @escaping () -> Unauthenticated, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = unauthenticated()
        self.content = content
    }


    var body: some View {
        VStack{
            switch viewModel.authenticationState {
            case .unauthenticated, .authenticating:
                WelcomeView()
            case .authenticated:
                VStack {
                    content()
                    Text("You're logged in as \(viewModel.displayName).")
                    Button("Tap here to view your profile") {
                        viewModel.signOut()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)) { event in
                  viewModel.signOut()
                  if let userInfo = event.userInfo, let info = userInfo["info"] {
                    print(info)
                  }
                }
            }
        }
        .environmentObject(viewModel)
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView {
            Text("You're signed in.")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(.yellow)
        }
    }
}

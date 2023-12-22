//
//  AuthenticatedView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-07-25.
//

import SwiftUI
import AuthenticationServices

struct AuthenticatedView: View{
    @StateObject private var viewModel = AuthenticationViewModel()

    var body: some View {
        VStack{
            switch viewModel.authenticationState {
            case .unauthenticated, .authenticating:
                WelcomeView()
            case .authenticated:
                VStack {
                    TabBarView()
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
        AuthenticatedView()
    }
}

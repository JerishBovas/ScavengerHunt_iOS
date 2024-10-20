//
//  AuthenticatedView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-07-25.
//

import SwiftUI
import AuthenticationServices

struct AuthenticatedView: View{
    @StateObject private var authVM = AuthenticationViewModel()

    var body: some View {
        VStack{
            switch authVM.authenticationState {
            case .unauthenticated, .authenticating:
                AuthenticationView()
            case .authenticated:
                VStack {
                    TabBarView()
                }
                .onReceive(NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)) { event in
                  authVM.signOut()
                  if let userInfo = event.userInfo, let info = userInfo["info"] {
                    print(info)
                  }
                }
            }
        }
        .environmentObject(authVM)
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView()
            .environmentObject(AuthenticationViewModel())
    }
}

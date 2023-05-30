//
//  SignInWithAppleView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-08-03.
//

import SwiftUI
import AuthenticationServices

struct SignInWithAppleView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    typealias UIViewType = ASAuthorizationAppleIDButton

    func makeUIView(context: Context) -> UIViewType {
        return ASAuthorizationAppleIDButton(type: .signIn, style: colorScheme == .dark ? .white : .black)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

struct SignInWithAppleView_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithAppleView()
    }
}

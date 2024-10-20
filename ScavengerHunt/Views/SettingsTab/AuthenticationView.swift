//
//  AuthenticationView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-07-25.
//

import SwiftUI
import Combine

struct AuthenticationView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel

  var body: some View {
    VStack {
      switch viewModel.flow {
      case .login:
        LoginView()
      case .signUp:
        SignupView()
      }
    }
  }
}

struct AuthenticationView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView()
      .environmentObject(AuthenticationViewModel())
  }
}

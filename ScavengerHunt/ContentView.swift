//
//  ContentView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var loginVM: LoginViewModel
    @AppStorage("firstTime") var isFirstTime: Bool = true
    @State private var isFirstLoad: Bool = true
    
    var body: some View {
        VStack{
            if(loginVM.isAuthenticated){
                NavBarView()
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .opacity))
            }else{
                if(isFirstLoad){
                    VStack{
                        
                    }
                    .onAppear{
                        Task{
                            await loginVM.initLogin()
                            isFirstLoad = false
                        }
                    }
                }else{
                    LoginView()
                        .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .opacity))
                }
            }
        }
        .sheet(isPresented: $isFirstTime) {
            IntroSheetView()
        }
        .animation(.default, value: loginVM.isAuthenticated)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LoginViewModel())
    }
}

//
//  MainView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-26.
//

import SwiftUI

struct TabSelected: Equatable{
    let id: Int
    
    static func ==(lhs: TabSelected, rhs: TabSelected) -> Bool {
            return lhs.id == rhs.id
        }
}

struct NavBarView: View {
    @EnvironmentObject private var authVM: LoginViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var tabSelection = TabSelected(id: 1)
    @State private var prevTabSelection = TabSelected(id: 0)
    
    var body: some View {
        VStack{
            switch tabSelection.id{
            case 1:
                HomeView(tabSelection: $tabSelection)
                    .transition(getTabTransition())
                    .onAppear{
                        prevTabSelection = tabSelection
                    }
            case 2:
                GamesView()
                    .transition(getTabTransition())
                    .onAppear{
                        prevTabSelection = tabSelection
                    }
            case 3:
                TeamsView()
                    .transition(getTabTransition())
                    .onAppear{
                        prevTabSelection = tabSelection
                    }
            case 4:
                SettingsView()
                    .transition(getTabTransition())
                    .onAppear{
                        prevTabSelection = tabSelection
                    }
            default:
                HomeView(tabSelection: $tabSelection)
                    .transition(getTabTransition())
                    .onAppear{
                        prevTabSelection = tabSelection
                    }
            }
        }
        .animation(.spring(dampingFraction: 0.6), value: tabSelection)
        .background(colorScheme == .dark ? LinearGradient(colors: [Color(.systemBackground)], startPoint: .top, endPoint: .bottomTrailing) :
        LinearGradient(colors: [.yellow.opacity(0.5), .purple.opacity(0.5), .blue], startPoint: .top, endPoint: .bottom))
        .overlay {
            VStack {
                HStack{
                    Spacer()
                    Button(action: {tabSelection = TabSelected(id: 1)}) {
                        Image("house")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    Spacer()
                    Button(action: {tabSelection = TabSelected(id: 2)}) {
                        Image("house")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    Spacer()
                    Button(action: {tabSelection = TabSelected(id: 3)}) {
                        Image("house")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    Spacer()
                    Button(action: {tabSelection = TabSelected(id: 4)}) {
                        Image("house")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
                .padding(.vertical)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40))
                .padding(8)
            }
            .shadow(color: .gray.opacity(0.4),radius: 10)
            .frame(maxHeight: .infinity, alignment: .bottom)
            
        }
    }
}

extension NavBarView{
    private func getTabTransition() -> AnyTransition{
        if(tabSelection.id > prevTabSelection.id){
            return AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
        }else{
            return AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
        }
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView()
            .environmentObject(GameViewModel())
            .environmentObject(AuthViewModel())
            .environmentObject(TeamViewModel())
            .environmentObject(LoginViewModel())
    }
}

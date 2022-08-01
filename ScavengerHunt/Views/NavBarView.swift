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
            case 2:
                GamesView()
                    .transition(getTabTransition())
            case 3:
                TeamsView()
                    .transition(getTabTransition())
            case 4:
                SettingsView()
                    .transition(getTabTransition())
            default:
                HomeView(tabSelection: $tabSelection)
                    .transition(getTabTransition())
            }
        }
        .animation(.spring(), value: tabSelection)
        .overlay {
            NavBar
        }
    }
}

extension NavBarView{
    private var NavBar: some View {
        VStack {
            HStack{
                Spacer()
                getMenuItem(id: 1, name: "Home", icon: "house.fill")
                Spacer()
                getMenuItem(id: 2, name: "Games", icon: "gamecontroller.fill")
                Spacer()
                getMenuItem(id: 3, name: "Teams", icon: "person.2.fill")
                Spacer()
                getMenuItem(id: 4, name: "Settings", icon: "gear")
                Spacer()
            }
            .padding(.bottom)
            .padding(.bottom)
            .background(Color(.secondarySystemBackground))
        }
        .overlay(Divider().background(.tertiary), alignment: .top)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func getTabTransition() -> AnyTransition{
        if(tabSelection.id > prevTabSelection.id){
            return AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
        }else{
            return AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
        }
    }
    
    private func getMenuItem(id: Int, name: String, icon: String) -> some View{
        if(tabSelection.id == id){
            return VStack {
                Color.clear
                    .background(RoundedRectangle(cornerRadius: 10).fill(.blue))
                    .frame(width: 65, height: 2)
                VStack(spacing: 0) {
                    Button(action: {
                        prevTabSelection = tabSelection
                        tabSelection = TabSelected(id: id)
                    },label: {
                        Image(systemName: icon)
                            .foregroundColor(.accentColor)
                            .font(.title2)
                    })
                    .frame(width: 30, height: 30)
                    Text(name)
                        .foregroundColor(.accentColor)
                        .font(.caption)
                }
            }
        }else{
            return VStack {
                Color.clear
                    .background(RoundedRectangle(cornerRadius: 10).fill(.clear))
                    .frame(width: 65, height: 1)
                VStack(spacing: 0) {
                    Button(action: {
                        prevTabSelection = tabSelection
                        tabSelection = TabSelected(id: id)
                    },label: {
                        Image(systemName: icon)
                            .foregroundColor(.secondary)
                            .font(.title2)
                    })
                    .frame(width: 30, height: 30)
                    Text(name)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView()
            .environmentObject(GameViewModel())
            .environmentObject(HomeViewModel())
            .environmentObject(TeamViewModel())
            .environmentObject(LoginViewModel())
    }
}

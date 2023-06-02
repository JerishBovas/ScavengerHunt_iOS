//
//  DiscoverView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-03-29.
//

import SwiftUI

struct DashView: View {
    @EnvironmentObject private var vm: DashViewModel
    @Binding var selection: Int
    @State private var firstLoad = true
    @State private var showProfile = false
    @State private var showAlert: Bool = false
    @State private var appError: AppError?
    @State private var lvlXP: Int = 800
    
    private func shortAddress(address: String) -> String{
        var addressSplit = address.split(separator: ",")
        addressSplit.removeLast()
        return addressSplit.joined(separator: ",")
    }
    private var progress: CGFloat{
        CGFloat(vm.user?.score ?? 0)/CGFloat(lvlXP)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0){
                headerSection
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20){
                        spotLightSection
                        topGamesSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    gamesNearYouSection
                }
            }
            .navigationDestination(for: Game.self) { game in
                GameDetailView(game: game)
            }
            .refreshable {
                await vm.fetchPage()
            }
            .sheet(isPresented: $showProfile, content: {
                ProfileView()
            })
            .alert(appError?.title ?? "", isPresented: $showAlert) {
                Text("OK")
            } message: {
                Text(appError?.message ?? "")
            }
            .task {
                if firstLoad{
                    await vm.fetchPage()
                    firstLoad = false
                }
            }
        }
    }
}

extension DashView{
    private var headerSection: some View{
        VStack {
            HStack(alignment: .center) {
                VStack(alignment: .leading){
                    Text("Welcome Back,")
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundColor(.primary.opacity(0.6))
                    Text(vm.user?.name ?? "Guest")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundColor(.primary)
                }
                Spacer()
                Image("profileImage")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .onTapGesture {
                        showProfile = true
                    }

            }
            ProgressView(value: 400, total: Double(lvlXP))
                .tint(.primary)
                .background(.secondary.opacity(0.5))
            HStack(spacing: 0){
                Text("Level 4")
                    .font(.title2)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(400)")
                    .fontWeight(.medium)
                    .font(.footnote)
                    .foregroundColor(.primary.opacity(0.6))
                Text(" / \(lvlXP.description) XP")
                    .font(.footnote)
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
            }
            .padding(.vertical, 8)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(
        LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.7), Color.accentColor]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    
    private var spotLightSection: some View {
        VStack(alignment: .leading) {
            Text("TODAY")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.bottom, -1)
            
            ImageView(url: vm.gotd?.imageName ?? "")
                .frame(maxHeight: 230)
                .cornerRadius(8)
            
            NavigationLink(value: vm.gotd) {
                HStack{
                    ImageView(url: vm.gotd?.imageName ?? "")
                        .frame(width: 50, height: 50)
                        .cornerRadius(8, corners: .allCorners)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(vm.gotd?.name ?? "Jerish Bovas")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Text(shortAddress(address: vm.gotd?.address ?? "Something something somethign"))
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
        }
        .redacted(reason: vm.gotd == nil ? .placeholder : [])
    }

    
    private var topGamesSection: some View {
        return VStack(alignment: .leading, spacing: 8) {
            Text("TOP GAMES")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)

            LazyVStack {
                ForEach(vm.popularGames ?? [DataService.getGame(), DataService.getGame(), DataService.getGame(), DataService.getGame()]) { game in
                    HStack(alignment: .center, spacing: 10) {
                        ImageView(url: game.imageName)
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(game.name)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            Text(shortAddress(address: game.address))
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()

                        NavigationLink("View", value: game)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                    }
                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
        .redacted(reason: vm.popularGames == nil ? .placeholder : [])
    }

    
    private var topPlayersSection: some View {
        VStack(alignment: .leading) {
            Text("TOP PLAYERS")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)

            LazyVStack(spacing: 8) {
                ForEach(vm.leaderBoard ?? [DataService.getUser(), DataService.getUser(), DataService.getUser(), DataService.getUser()]) { user in
                    HStack(spacing: 10) {
                        ImageView(url: user.profileImage)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())

                        Text(user.name)
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)

                        Spacer()

                        Text(String(user.score))
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.accentColor)
                    }
                    Divider()
                        .padding(.leading, 60)
                }
                .redacted(reason: vm.leaderBoard == nil ? .placeholder : [])
            }
        }
    }

    
    private var gamesNearYouSection: some View {
        VStack(alignment: .leading) {
            Text("GAMES NEAR YOU")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.leading, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                let dimension = UIScreen.main.bounds.width - 60
                LazyHStack {
                    ForEach([DataService.getGame(), DataService.getGame(), DataService.getGame(), DataService.getGame()]) { game in
                        CardView(game: game, dimension: dimension)
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }

}

struct DashView_Previews: PreviewProvider {
    static var previews: some View {
        DashView(selection: .constant(0))
            .environmentObject(DashViewModel())
    }
}

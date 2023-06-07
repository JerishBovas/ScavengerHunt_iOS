//
//  DiscoverView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-03-29.
//

import SwiftUI

struct DashView: View {
    @EnvironmentObject private var vm: DashViewModel
    @EnvironmentObject private var profileVM: ProfileViewModel
    @Binding var selection: Int
    @State private var firstLoad = true
    @State private var showProfile = false
    @State private var showAlert: Bool = false
    @State private var appError: AppError?
    @State private var upperLimit: Int = 100
    @State private var lowerLimit: Int = 0
    @State private var level: Int = 1
    
    private func shortAddress(address: String) -> String{
        var addressSplit = address.split(separator: ",")
        addressSplit.removeLast()
        return addressSplit.joined(separator: ",")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32){
                    spotLightSection
                        .padding(.top, 20)
                    topGamesSection
                }
                .padding(.horizontal, 20)
                gamesNearYouSection
                    .padding(.top, 32)
            }
            .padding(.top, 160)
            .overlay{
                VStack{
                    headerSection
                    Spacer()
                }
            }
            .navigationDestination(for: Game.self) { game in
                GameDetailView(game: game)
            }
            .navigationDestination(for: User.self) { user in
                ProfileView(user: user)
            }
            .alert(appError?.title ?? "", isPresented: $showAlert) {
                Text("OK")
            } message: {
                Text(appError?.message ?? "")
            }
            .refreshable {
                await vm.fetchPage()
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
        VStack(spacing: 10) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0){
                    Text("Welcome Back,")
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundColor(.primary.opacity(0.6))
                    Text(profileVM.user?.name ?? "Guest")
                        .font(.system(size: 34))
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundColor(.primary)
                }
                Spacer()
                if let user = profileVM.user{
                    NavigationLink(value: user) {
                        ImageView(url: user.profileImage)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                }
                else{
                    Color.random()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
            }
            HStack(spacing: 2){
                Circle()
                    .stroke(lineWidth: 4)
                    .fill(.primary)
                    .frame(width: 60, height: 60)
                    .overlay{
                        Text(level.description)
                            .font(.title)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                    }
                ProgressView(value: max(min(Double((profileVM.user?.score ?? lowerLimit) - lowerLimit), Double(upperLimit - lowerLimit)), 0), total: Double(upperLimit - lowerLimit))
                    .tint(.primary)
                    .background(.secondary.opacity(0.5))
                    .overlay{
                        HStack{
                            Spacer()
                            VStack{
                                HStack(alignment: .bottom){
                                    Text("\(profileVM.user?.score ?? 0)")
                                    Text("/ \(upperLimit.description)")
                                }
                                .font(.headline)
                                .foregroundColor(.primary.opacity(0.7))
                                .fontDesign(.rounded)
                                Spacer()
                            }
                            .frame(height: 50)
                        }
                    }
                    .onAppear{
                        let (level, upperLimit, lowerLimit) = calculateLevelAndCutoff(for: profileVM.user?.score ?? 0)
                        self.upperLimit = upperLimit
                        self.lowerLimit = lowerLimit
                        self.level = level
                    }
            }
            .onChange(of: profileVM.user?.score) { newValue in
                let (level, upperLimit, lowerLimit) = calculateLevelAndCutoff(for: newValue ?? 0)
                self.upperLimit = upperLimit
                self.lowerLimit = lowerLimit
                self.level = level
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 8)
        .background(
        LinearGradient(gradient: Gradient(colors: [Color.accentColor, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    
    private var spotLightSection: some View {
        VStack(alignment: .leading) {
            Text("TODAY")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.bottom, -1)
            NavigationLink(value: vm.gotd) {
                VStack{
                    ImageView(url: vm.gotd?.imageName ?? "")
                        .frame(maxHeight: 230)
                        .cornerRadius(8)
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
            Divider()
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
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.leading, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                let dimension = UIScreen.main.bounds.width - 60
                LazyHStack {
                    ForEach(vm.popularGames ?? [DataService.getGame(), DataService.getGame(), DataService.getGame(), DataService.getGame()]) { game in
                        CardView(game: game, dimension: dimension)
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    private func calculateLevelAndCutoff(for score: Int) -> (level: Int, upperLimit: Int, lowerLimit: Int) {
        var level = 1
        var upperLimit = 100
        var lowerLimit = 0
        
        while score >= upperLimit {
            lowerLimit = upperLimit
            level += 1
            upperLimit *= 2
        }
        
        return (level, upperLimit, lowerLimit)
    }

}
struct LinearProgressViewHeightModifier: ViewModifier {
    var height: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .progressViewStyle(LinearProgressViewStyle())
    }
}

struct DashView_Previews: PreviewProvider {
    static var previews: some View {
        DashView(selection: .constant(0))
            .environmentObject(DashViewModel())
            .environmentObject(ProfileViewModel())
    }
}

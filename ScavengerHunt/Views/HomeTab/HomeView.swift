//
//  HomeView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-03-29.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @EnvironmentObject private var profileVM: ProfileViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var firstLoad = true
    @State private var showProfile = false
    @State private var upperLimit: Int = 100
    @State private var lowerLimit: Int = 0
    @State private var level: Int = 1
    @State private var showCard = false
    @State var isAnimating = false
    
    private func shortAddress(address: String) -> String{
        let addressSplit = address.split(separator: ",")
        return String(addressSplit.first ?? "")
    }
    
    private func shortName(name: String) -> String{
        let nameSplit = name.split(separator: " ")
        return nameSplit[0].capitalized
    }
    
    var body: some View {
        NavigationStack{
            GeometryReader{ geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 25){
                        header(geo: geo)
                        today
                        topGames
                        gamesNearYouSection
                    }
                    .padding(.horizontal)
                }
            }
        }
        .task {
            if firstLoad{
                await vm.fetchPage()
                firstLoad = false
            }
        }
    }
}

extension HomeView{
    private func header(geo: GeometryProxy) -> some View{
        VStack(spacing: 20){
            HStack(alignment: .center){
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                Spacer()
                if let user = profileVM.user{
                    ImageView(url: user.profileImage)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                else{
                    Circle()
                        .fill(Color.accentColor.gradient)
                        .frame(width: 40, height: 40)
                }
            }
            levelProgress(geo: geo)
        }
    }
    
    private func levelProgress(geo: GeometryProxy) -> some View{
        VStack(spacing: 8){
            ZStack{
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 2.0)
                    .fill(LinearGradient(colors: [.accentRed, .accentColor], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: max(geo.size.width - 32, 0), height: 16)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.background))
                HStack(spacing: 0){
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.accentRed, Color.accentPink]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(geo.size.width - 38, 0) * max(min(Double((profileVM.user?.score ?? lowerLimit) - lowerLimit), Double(upperLimit - lowerLimit)), 0) / Double(upperLimit - lowerLimit))
                        .cornerRadius(16)
                        .padding(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.default, value: profileVM.user?.score)
            }
            .onAppear{
                let (level, upperLimit, lowerLimit) = calculateLevelAndCutoff(for: profileVM.user?.score ?? 0)
                withAnimation {
                    self.upperLimit = upperLimit
                    self.lowerLimit = lowerLimit
                    self.level = level
                }
            }
            HStack{
                Text("LEVEL \(level)")
                    .font(.footnote)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.accentRed)
                Spacer()
                Text("\(Int(Double((profileVM.user?.score ?? lowerLimit) - lowerLimit) / Double(upperLimit - lowerLimit) * 100)) %")
                    .font(.footnote)
                    .fontWeight(.heavy)
                    .foregroundColor(.gray)
                Spacer()
                Text("LEVEL \(level + 1)")
                    .font(.footnote)
                    .fontWeight(.heavy)
                    .foregroundColor(.accentColor)
            }
        }
        .redacted(reason: firstLoad ? .placeholder : [])
        .onChange(of: profileVM.user?.score) { newValue in
            let (level, upperLimit, lowerLimit) = calculateLevelAndCutoff(for: newValue ?? 0)
            withAnimation {
                self.upperLimit = upperLimit
                self.lowerLimit = lowerLimit
                self.level = level
            }
        }
    }
    
    private var today: some View {
        VStack(alignment: .leading) {
            Text("TODAY")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.accentOrange)
                .padding(.bottom, -1)
            VStack(spacing: 16){
                ImageView(url: vm.gotd?.imageName ?? DataService.getGame().imageName)
                    .frame(maxHeight: 250)
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.gray.shadow(.inner(radius: 2)), lineWidth: 1.0))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                if let game = vm.gotd{
                    NavigationLink(value: game) {
                        HStack{
                            VStack(alignment: .leading, spacing: 3) {
                                Text(game.name)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(Color.accentPink)
                                Text(shortAddress(address: game.address))
                                    .font(.headline)
                                    .foregroundStyle(Color.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .transition(.move(edge: .top))
                    .zIndex(-1)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(lineWidth: 1).fill(LinearGradient(colors: [.accentRed, .accentColor], startPoint: .topLeading, endPoint: .bottomTrailing)))
            .animation(.spring(duration: 1, bounce: 0.2, blendDuration: 1), value: vm.gotd)
        }
        .redacted(reason: vm.gotd == nil ? .placeholder : [])
    }

    
    private var topGames: some View {
        return VStack(alignment: .leading, spacing: 8) {
            Text("TOP GAMES")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.accentOrange)
            Rectangle()
                .fill(
                    LinearGradient(colors: [.accentRed, .accentColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(height: 1)
            LazyVStack(spacing: 12){
                ForEach(vm.popularGames ?? [DataService.getGame(), DataService.getGame(), DataService.getGame(), DataService.getGame()]) { game in
                    HStack(alignment: .center, spacing: 16) {
                        ImageView(url: game.imageName)
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(game.name)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentPink)

                            Text(shortAddress(address: game.address))
                                .font(.headline)
                                .foregroundStyle(Color.secondary.gradient)
                        }
                        Spacer()
                        NavigationLink("View", value: game)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                    }
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [.accentRed, .accentColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(height: 1)
                        .padding(.leading, 66)
                }
            }
        }
            .redacted(reason: vm.popularGames == nil ? .placeholder : [])
    }

    
    private var topPlayersSection: some View {
        VStack(alignment: .leading) {
            Text("TOP PLAYERS")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.accentOrange)

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
                .foregroundColor(.accentOrange)
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

struct DashView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .environmentObject(HomeViewModel())
                .environmentObject(ProfileViewModel())
        }
    }
}

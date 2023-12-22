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
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var scrollOffset: CGFloat = 0
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
                VStack(spacing: 0){
                    header(geo: geo)
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 12){
                            today
                            Divider()
                                .padding(.vertical, 8)
                            recommendedForYou
                            Divider()
                                .padding(.vertical, 8)
                            topGames
                            Divider()
                                .padding(.vertical, 8)
                            topPlayers
                        }
                        .safeAreaPadding()
                        .background(GeometryReader { geo in
                            let offset = -geo.frame(in: .named("scroll")).minY
                            Color.clear
                                .preference(key: ScrollViewOffsetPreferenceKey.self,
                                            value: offset)
                        })
                    }
                    .scrollIndicators(.hidden)
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollViewOffsetPreferenceKey.self, perform: { value in
                        scrollOffset = value
                    })
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

struct ScrollViewOffsetPreferenceKey: PreferenceKey{
    typealias Value = CGFloat
    static var defaultValue: CGFloat = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

extension HomeView{
    private func header(geo: GeometryProxy) -> some View{
        VStack(spacing: 12){
            HStack(alignment: .bottom){
                VStack(alignment: .leading){
                    Text("\(greetUser()),")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .fontDesign(.rounded)
                    Text(profileVM.user?.name ?? "Scavenger")
                        .font(.custom("name", size: 30))
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                }
                Spacer()
                if let user = profileVM.user{
                    ImageView(url: user.profileImage)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
            }
            levelProgress(geo: geo)
                .frame(maxHeight: 50)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(Rectangle()
            .fill(.accent)
            .shadow(radius: 5)
            .ignoresSafeArea(edges: .top))
    }
    
    private func levelProgress(geo: GeometryProxy) -> some View{
        VStack(spacing: 16){
            ZStack{
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [.secondary.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: max(geo.size.width - 32, 0), height: 4)
                HStack(spacing: 0){
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.white]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(geo.size.width - 38, 0) * max(min(Double((profileVM.user?.score ?? lowerLimit) - lowerLimit), Double(upperLimit - lowerLimit)), 0) / Double(upperLimit - lowerLimit), height: 5)
                        .cornerRadius(16)
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
                Spacer()
                Text("\(profileVM.user?.score ?? 0)")
                    .font(.footnote)
                    .fontWeight(.heavy)
                Spacer()
                Text("LEVEL \(level + 1)")
                    .font(.footnote)
                    .fontWeight(.heavy)
            }
        }
        .foregroundStyle(.white)
        .redacted(reason: firstLoad ? .placeholder : [])
        .onChange(of: profileVM.user?.score) { _, newValue in
            let (level, upperLimit, lowerLimit) = calculateLevelAndCutoff(for: newValue ?? 0)
            withAnimation {
                self.upperLimit = upperLimit
                self.lowerLimit = lowerLimit
                self.level = level
            }
        }
    }
    
    private var recommendedForYou: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("RECOMMENDED FOR YOU")
                .font(.system(size: 23, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(vm.popularGames ?? [DataService.getGame(), DataService.getGame(), DataService.getGame(), DataService.getGame()]) { game in
                        CardView(game: game)
                    }
                }
            }
            .redacted(reason: vm.popularGames == nil ? .placeholder : [])
        }
    }
    
    private var today: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TOP TODAY")
                .font(.system(size: 23, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
            NavigationLink(value: vm.gotd) {
                VStack {
                    ImageView(url: vm.gotd?.imageName ?? DataService.getGame().imageName)
                        .frame(maxHeight: 200)
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.gray.opacity(0.4).shadow(.inner(radius: 1)),lineWidth: 1.0))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .blendMode(colorScheme == .dark ? .lighten : .darken)
                    HStack {
                        VStack(alignment: .leading) {
                            Text(vm.gotd?.name ?? "")
                                .font(.title3)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .foregroundStyle(Color.primary)
                                .lineLimit(1)
                            Text(vm.gotd?.address ?? "")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .foregroundColor(Color.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text(vm.gotd?.ratings.description ?? "0.0")
                            .foregroundStyle(Color.primary)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .padding(8)
                            .background(.regularMaterial, in: Circle())
                    }
                }
            }
            .redacted(reason: vm.gotd == nil ? .placeholder : [])
        }
    }

    
    private var topGames: some View {
        return VStack(alignment: .leading, spacing: 16) {
            Text("TOP GAMES")
                .font(.system(size: 23, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
            VStack(spacing: 12){
                ForEach(vm.popularGames ?? [DataService.getGame(), DataService.getGame(), DataService.getGame(), DataService.getGame()]) { game in
                    HStack(alignment: .center, spacing: 16) {
                        ImageView(url: game.imageName)
                            .frame(width: 45, height: 45)
                            .cornerRadius(8)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(game.name)
                                .font(.title3)
                                .fontDesign(.rounded)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.primary)
                                .lineLimit(1)

                            Text(game.address)
                                .font(.footnote)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .foregroundStyle(Color.secondary.gradient)
                                .lineLimit(1)
                        }
                        Spacer()
                        NavigationLink("View", value: game)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                    }
                    Divider()
                        .padding(.leading, 66)
                }
            }
            .redacted(reason: vm.popularGames == nil ? .placeholder : [])
        }
    }

    
    private var topPlayers: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TOP PLAYERS")
                .font(.system(size: 23, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
            LazyVStack(spacing: 8) {
                ForEach(vm.leaderBoard ?? [DataService.getUser(), DataService.getUser(), DataService.getUser(), DataService.getUser()]) { user in
                    HStack(spacing: 16) {
                        ImageView(url: user.profileImage)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                        Text(user.name)
                            .font(.title3)
                            .fontDesign(.rounded)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)

                        Spacer()

                        Text(String(user.score))
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.accentColor)
                    }
                    Divider()
                        .padding(.leading, 66)
                }
            }
            .redacted(reason: vm.leaderBoard == nil ? .placeholder : [])
        }
    }

    func greetUser() -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5...11:
            return "Good Morning"
        case 12...16:
            return "Good Afternoon"
        case 17...20:
            return "Good Evening"
        case 21...23:
            return "Good Night"
        default:
            return "Hello"
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

//
//  HomeView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-28.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var locVM: GameViewModel
    @EnvironmentObject private var VM: HomeViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var tabSelection: TabSelected
    @State private var showAddGame: Bool = false
    @State private var isScoreLoading: Bool = false
    @State private var topSafeAreaHeight = 0.0
    @State private var welcomeViewHeight = 0.0
    @State private var scrollViewHeight = 0.0
    @State private var barChartValues: [Double] = [20.0, 44, 24, 70, 54, 33]
    
    var body: some View {
        VStack(spacing: 0) {
            WelcomeTitle
                .background(GeometryReader{ geometry -> Color in
                    DispatchQueue.main.async {
                        self.topSafeAreaHeight = geometry.safeAreaInsets.top
                        self.welcomeViewHeight = geometry.size.height
                    }
                    return Color.clear
                })
            ScrollView(showsIndicators: false){
                ZStack {
                    VStack(alignment: .leading, spacing: 16){
                        ScoreCard
                        Stats
                        if(!barChartValues.isEmpty){
                            BarChartCard
                        }
                        LeaderBoard
                        LocOfTheDay
                        PopularGames
                        GamesSlide
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 40)
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named("scroll")).minY
                        Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                if(value < 0){
                    scrollViewHeight = 0
                }else{
                    scrollViewHeight = 120
                }
            }
        }
        .background(LinearGradient(colors: colorScheme == .light ? [.cyan, .blue] : [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(height: topSafeAreaHeight + welcomeViewHeight + scrollViewHeight)
            .frame(maxHeight: .infinity, alignment: .top)
            .edgesIgnoringSafeArea(.top)
            .animation(.spring(), value: scrollViewHeight)
        )
        .background(colorScheme == .light ? .gray.opacity(0.4) : Color(.systemBackground))
        .alert(item: $VM.appError, content: { appError in
            Alert(title: Text(appError.title), message: Text(appError.message))
        })
        .onAppear{
            isScoreLoading = true
            Task{
                if(VM.user != nil){
                    isScoreLoading = false
                    return
                }
                await VM.getUser()
                isScoreLoading = false
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView(tabSelection: .constant(TabSelected(id: 2)))
                .environmentObject(GameViewModel())
                .environmentObject(HomeViewModel())
        }
    }
}

extension HomeView{
    private var WelcomeTitle: some View{
        HStack{
            VStack(alignment: .leading){
                Text(getGreeting())
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(VM.user?.name ?? "User")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.semibold)
            }
            Spacer()
            VStack{
                AsyncImage(url: URL(string: VM.user?.profileImage ?? "")) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemBackground), in: Circle())
                        
                }
            }
        }
        .padding()
    }
    
    private var ScoreCard: some View {
        VStack {
            HStack {
                VStack(alignment: .leading){
                    Text("Your score")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    HStack{
                        Image(systemName: "bitcoinsign.circle")
                            .font(.title)
                            .foregroundColor(.yellow)
                        Text(String(VM.user?.userLog.userScore ?? 1000))
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.semibold)
                            .id(VM.user?.userLog.userScore)
                            .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)).combined(with: .opacity))
                    }
                    .animation(.default, value: VM.user?.userLog.userScore)
                }
                Spacer()
                Text("0")
                    .foregroundColor(.green)
                    .font(.headline)
                Image(systemName: "arrow.up")
                    .foregroundColor(.green)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            Spacer()
            VStack(alignment: .trailing, spacing: 10){
                Text("Elite Player")
                    .font(.headline)
                    .foregroundColor(.secondary)
                HStack{
                    ForEach((1...5), id: \.self) {_ in
                        Image(systemName: "star.circle.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(maxWidth: .infinity, maxHeight: 170)
        .padding(.horizontal)
    }
    
    private var LastUpdated: some View{
        VStack {
            HStack{
                Text("Score Last Updated")
                    .font(.body)
                    .foregroundColor(.white)
                Spacer()
                Text(VM.dateFormatter(dat: VM.user?.userLog.lastUpdated ?? Date.now.description))
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(LinearGradient(colors: [.pink, .purple, .blue], startPoint: .bottomLeading, endPoint: .topTrailing)))
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private var Stats: some View{
        VStack(alignment: .leading){
            HStack{
                StatSquareCard(logo: "gamecontroller.fill", logoColor: .pink, value: 8, title: "Games")
                Spacer()
                StatSquareCard(logo: "person.2.fill", logoColor: .purple, value: 3, title: "Teams")
                Spacer()
                StatSquareCard(logo: "star.circle.fill", logoColor: .yellow, value: 5, title: "Played")
            }
        }
        .padding(.horizontal)
    }
    
    private var BarChartCard: some View{
        BarChartView(data: barChartValues, colors: [.cyan, .blue])
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)
    }
    
    private var LeaderBoard: some View{
        VStack(alignment: .leading, spacing: 20){
            VStack(alignment: .leading, spacing: 5){
                Text("LEADERBOARD")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Text("Top Scoring Players")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            if !isScoreLoading {
                VStack{
                    if !VM.leaderBoard.isEmpty {
                        ForEach(VM.leaderBoard, id: \.self.id) { user in
                            HStack{
                                AsyncImage(url: URL(string: user.profileImage)) { image in
                                    image.resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color.random
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 5){
                                    Text(user.name)
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                    Text(VM.dateFormatter(dat: user.userLog.lastUpdated))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(String(user.userLog.userScore))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            Divider()
                                .padding(.leading, 50)
                        }
                    } else {
                        VStack(alignment: .center){
                            Spacer()
                            Text("No Players to show")
                                .font(.body)
                            Spacer()
                            Text("Updated Every 30 Minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {
                VStack(alignment: .center){
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in:RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
        .onAppear{
            Task{
                await VM.getLeaderboard()
            }
        }
    }
    
    private var GamesSlide: some View{
        VStack{
            if(!locVM.games.isEmpty){
                VStack(alignment: .leading){
                    Text("Made By You")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.leading)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(locVM.games, id: \.self.id) { game in
                                SlideCardView(game: game)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            else{
                VStack{
                    
                }
            }
        }
    }
    
    private var LocOfTheDay: some View{
        VStack{
            AsyncImage(url: URL(string: VM.user?.profileImage == "" ? "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449040109061189.jpeg" : VM.user?.profileImage ?? "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449040109061189.jpeg" )) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity,maxHeight: 200, alignment: .center)
                    .clipped()
            } placeholder: {
                ProgressView()
            }
            VStack(alignment: .leading){
                Text("GAME OF THE DAY")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Text("From white wine to right wine")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Vivino will help you find the perfect bottle for every occasion.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(minHeight: 100)
            .padding()
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
    
    private var PopularGames: some View{
        VStack(alignment: .leading, spacing: 20){
            VStack(alignment: .leading, spacing: 5){
                Text("OUR FAVOURITES")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Text("Popular Among Others")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            VStack{
                ForEach(VM.popularGames, id: \.self.id) { game in
                    HStack{
                        AsyncImage(url: URL(string: game.imageName)) { image in
                            image.resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        VStack(alignment: .leading, spacing: 5){
                            Text(game.name)
                                .font(.title3)
                                .foregroundColor(.primary)
                            Text(game.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            
                        } label: {
                            Text("Play")
                                .font(.caption)
                        }
                        .cornerRadius(20)
                        .buttonStyle(.borderedProminent)
                    }
                    Divider()
                        .padding(.leading, 50)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in:RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
        .onAppear{
            Task{
                await VM.getPopularGames()
            }
        }
    }
    
    private func getGreeting() -> String{
        let date = Date.now.formatted(date: .omitted, time: .shortened)
        let hrminSplit = date.split(separator: " ")
        let hrmin = hrminSplit[0].split(separator: ":")
        var hour = Int(hrmin[0]) ?? 0
        
        if(hrminSplit[1] == "PM"){
            hour += 12
        }
        
        switch hour{
        case 1...12:
            return "Good Morning,"
        case 13...16:
            return "Good Afternoon,"
        case 17...20:
            return "Good Evening,"
        case 21...23:
            return "Good Night,"
        case 24:
            return "Good Afternoon,"
        default:
            return "Good Day,"
        }
    }
    
    struct ScrollViewOffsetPreferenceKey: PreferenceKey {
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
    struct WelcomeViewHeightPreferenceKey: PreferenceKey{
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}

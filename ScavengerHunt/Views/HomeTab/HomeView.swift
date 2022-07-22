//
//  HomeView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-28.
//

import SwiftUI
import WeatherKit

struct HomeView: View {
    @EnvironmentObject private var locVM: GameViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddGame: Bool = false
    @State private var isScoreLoading: Bool = false
    @Binding var tabSelection: TabSelected
    var colors: [Color] = [.blue, .teal]
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(alignment: .leading){
                WelcomeTitle
                ScoreCard
                LastUpdated
                Stats
                LeaderBoard
                LocOfTheDay
                PopularGames
                GamesSlide
            }
        }
        .alert(item: $authVM.appError, content: { appError in
            Alert(title: Text(appError.title), message: Text(appError.message))
        })
        .onAppear{
            isScoreLoading = true
            Task{
                if(authVM.user != nil){
                    isScoreLoading = false
                    return
                }
                await authVM.getAccount()
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
                .environmentObject(AuthViewModel())
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
                Text(authVM.user?.name ?? "Hunter")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.semibold)
            }
            Spacer()
            VStack{
                Spacer()
                AsyncImage(url: URL(string: authVM.user?.profileImage ?? "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449040109061189.jpeg")) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Color.random
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                }
            }
            
        }
        .padding(24)
    }
    private var ScoreCard: some View {
        VStack {
            HStack {
                VStack(alignment: .leading){
                    Text("Your score")
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack{
                        Image(systemName: "bitcoinsign.circle")
                            .font(.title)
                            .foregroundColor(.yellow)
                        Text(String(authVM.user?.userLog.userScore ?? 1000))
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .id(authVM.user?.userLog.userScore)
                            .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)).combined(with: .opacity))
                    }
                    .animation(.default, value: authVM.user?.userLog.userScore)
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
                    .font(.body)
                    .foregroundColor(.white)
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
        .padding(.vertical)
        .background(LinearGradient(colors: [.pink, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing), in:RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .shadow(radius: 5)
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
                Text(authVM.dateFormatter(dat: authVM.user?.userLog.lastUpdated ?? Date.now.description))
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(LinearGradient(colors: [.pink, .purple, .blue], startPoint: .bottomLeading, endPoint: .topTrailing)))
        .shadow(radius: 5, y: 5)
        .padding(.horizontal)
        .padding(.vertical, 8)
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
                    if !locVM.games.isEmpty {
                        ForEach(locVM.games, id: \.self.id) { game in
                            HStack{
                                AsyncImage(url: URL(string: game.imageName)) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Color.random
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
                                Text("1392")
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
        .background(.ultraThinMaterial, in:
                        RoundedRectangle(cornerRadius: 10)
        )
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
        .padding(.bottom, 8)
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
                        .padding(.leading)
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
            AsyncImage(url: URL(string: authVM.user?.profileImage == "" ? "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449040109061189.jpeg" : authVM.user?.profileImage ?? "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449040109061189.jpeg" )) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
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
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in:
            Rectangle()
        )
        .cornerRadius(10)
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
                ForEach(locVM.games, id: \.self.id) { game in
                    HStack{
                        AsyncImage(url: URL(string: game.imageName)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
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
        .background(.ultraThinMaterial, in:
            RoundedRectangle(cornerRadius: 10)
        )
        .padding(.horizontal)
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
        case 13...15:
            return "Good Afternoon,"
        case 16...19:
            return "Good Evening,"
        case 20...23:
            return "Good Night,"
        case 24:
            return "Good Noon,"
        default:
            return "Good Day,"
        }
    }
}

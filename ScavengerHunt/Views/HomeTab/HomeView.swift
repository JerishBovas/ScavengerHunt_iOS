//
//  HomeView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-28.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var locVM: GameViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddGame: Bool = false
    @State private var isScoreLoading: Bool = false
    @Binding var tabSelection: Int
    var colors: [Color] = [.blue, .teal]
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(alignment: .leading) {
                welcomeTitle
                ScoreCard
                LeaderBoard
                Stats
                LocOfTheDay
                PopularGames
                GamesSlide

            }
        }
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
        HomeView(tabSelection: .constant(2))
            .environmentObject(GameViewModel())
            .environmentObject(AuthViewModel())
    }
}

extension HomeView{
    private var welcomeTitle: some View{
        VStack(alignment: .leading, spacing: 0){
            Text("Good Morning,")
                .foregroundColor(.secondary)
                .font(.headline)
            HStack(spacing: 15){
                Text(authVM.user?.name ?? "New Player")
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                Spacer()
                AsyncImage(url: URL(string: authVM.user?.profileImage == "" ? "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449040109061189.jpeg" : authVM.user?.profileImage ?? "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449040109061189.jpeg" )) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var ScoreCard: some View {
        VStack(spacing: 10){
            Text("Total score")
                .foregroundColor(.secondary)
                .font(.subheadline)
            HStack{
                HStack{
                    Image(systemName: "bitcoinsign.circle")
                        .foregroundColor(Color(red: 212/255, green: 175/215, blue: 55/255))
                        .font(.largeTitle)
                    Text(String(authVM.user?.userLog.userScore ?? 1000))
                        .foregroundColor(.accentColor)
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                Label("0", systemImage: "arrow.up")
                    .font(.headline)
                    .foregroundColor(.green)
                    .frame(alignment: .trailing)
            }
            NavigationLink(destination: HomeView(tabSelection: .constant(1)), label: {
                HStack(spacing: 3){
                    Text("View More")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

            })
            .frame(maxWidth: .infinity,alignment: .trailing)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in:
            RoundedRectangle(cornerRadius: 10)
        )
        .padding(.horizontal)
    }
    
    private var LeaderBoard: some View{
        VStack(alignment: .leading, spacing: 5){
            Text("TOP PLAYERS")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text("Top 10 Champions Of The Game")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
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
                                .fontWeight(.semibold)
                            Text(game.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("1392")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThickMaterial, in:
                        RoundedRectangle(cornerRadius: 10)
        )
        .padding(.horizontal)
    }
    
    private var Stats: some View{
        VStack(alignment: .leading){
            Text("Your Activities")
                .font(.title)
                .fontWeight(.semibold)
            HStack{
                StatSquareCard(logo: "gamecontroller.fill", logoColor: .pink, value: 8, title: "Created")
                StatSquareCard(logo: "person.2.fill", logoColor: .purple, value: 3, title: "Joined")
                StatSquareCard(logo: "star.circle.fill", logoColor: .yellow, value: 5, title: "Won")
            }
        }
        .padding(.horizontal)
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
        .background(.ultraThickMaterial, in:
            Rectangle()
        )
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var PopularGames: some View{
        VStack(alignment: .leading, spacing: 5){
            Text("OUR FAVOURITES")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text("Popular Among Others")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
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
                                .fontWeight(.semibold)
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
        .background(.ultraThickMaterial, in:
            RoundedRectangle(cornerRadius: 10)
        )
        .padding(.horizontal)
    }
}

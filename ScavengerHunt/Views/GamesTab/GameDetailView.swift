//
//  GameDetailView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-03.
//

import SwiftUI
import MapKit

struct GameDetailView: View {
    @State var game: Game
    var animationNamespace: Namespace.ID
    @Binding var showDetails: Bool
    @State private var onColor: Color = .yellow
    @State private var offColor: Color = .secondary.opacity(0.5)
    @State private var difficulty = ["None","Easy", "Medium", "Hard"]
    @State private var isPresented = false
    @State private var showItemsSheet = false
    @State private var showGamePlaySheet = false
    @State private var isShareSheetPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            ImageView(url: game.imageName)
                .frame(maxHeight: 200)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .matchedGeometryEffect(id: "gameImage", in: animationNamespace)
                .overlay{
                    VStack{
                        HStack{
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showDetails = false
                                }
                            }, label: {
                                Image(systemName: "chevron.down")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .padding()
                                    .foregroundStyle(.foreground)
                            })
                            .background(.ultraThickMaterial, in: Circle())
                            .padding()
                        }
                        Spacer()
                    }
                }
            header
        }
        .frame(maxWidth: 500)
        .background(RoundedRectangle(cornerRadius: 20.0).fill(.ultraThinMaterial).cornerRadius(15)
            .matchedGeometryEffect(id: "gameContainer", in: animationNamespace))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.5), radius: 20)
        .fullScreenCover(isPresented: $showGamePlaySheet, content: {
            PlayGameView(game: game)
                .transition(.scale(scale: 0.1, anchor: .bottom))
                .zIndex(1.0)
        })
        .sheet(isPresented: $showItemsSheet, content: {
            AddItemsView(game: game)
        })
        .sheet(isPresented: $isPresented,content: {
            EditGameView(game: game)
        })
    }
}

struct GameDetailViewSmall: View{
    @State var game: Game
    var animationNamespace: Namespace.ID
    @Binding var showDetails: Bool
    @State private var showGamePlaySheet = false
    
    var body: some View{
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 16){
                ImageView(url: game.imageName)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .matchedGeometryEffect(id: "gameImage", in: animationNamespace)
                
                VStack(alignment: .center){
                    Text(game.name)
                        .font(.custom("", size: 25))
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 8)
                        .matchedGeometryEffect(id: "gameName", in: animationNamespace)
                    Text(game.address)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .matchedGeometryEffect(id: "gameAddress", in: animationNamespace)
                }
            }
            HStack(spacing: 16){
                HStack(alignment: .bottom, spacing: 20) {
                    Button(action: {
                        // Handle favorite button tap
                    }) {
                        Image(systemName: game.isUser ? "heart.fill" : "heart")
                            .font(.title3)
                    }
                    .matchedGeometryEffect(id: "gameFavorite", in: animationNamespace)
                    ShareLink(
                        item: game.name, subject: Text(game.country), message: Text(game.address),
                        preview: SharePreview(game.name, image: Image(""))) {
                                 Image(systemName: "square.and.arrow.up")
                                     .fontWeight(.medium)
                                     .font(.title3)
                             }
                        .matchedGeometryEffect(id: "gameShare", in: animationNamespace)
                    Button(action: {
                        // Handle directions button tap
                    }) {
                        Image(systemName: "location.fill")
                            .font(.title3)
                    }
                    .matchedGeometryEffect(id: "gameDirection", in: animationNamespace)
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        showDetails = true
                    }
                }, label: {
                    Text("View Details")
                        .font(.headline)
                })
            }
            HStack(alignment: .bottom, spacing: 16){
                Button {
                    withAnimation {
                        showGamePlaySheet = true
                    }
                } label: {
                    Text("Start Game")
                        .font(.headline)
                        .frame(maxWidth: .infinity, maxHeight: 35)
                }
                .buttonStyle(.borderedProminent)
                .matchedGeometryEffect(id: "gamePlayButton", in: animationNamespace)
            }
        }
        .padding(16)
        .frame(maxWidth: 500)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .matchedGeometryEffect(id: "gameContainer", in: animationNamespace)
        )
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.5), radius: 20)
    }
}

extension GameDetailView{
    
    private var header: some View{
        VStack(alignment: .leading, spacing: 16){
            VStack{
                Text(game.name)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .matchedGeometryEffect(id: "gameTitle", in: animationNamespace)
                Text(game.address)
                    .foregroundColor(.secondary)
                    .matchedGeometryEffect(id: "gameAddress", in: animationNamespace)
            }
            .frame(maxWidth: .infinity)
            HStack{
                VStack(alignment: .leading, spacing: 8){
                    HStack(spacing: 0){
                        ForEach(1..<6) { index in
                            Image(systemName: "star.fill")
                                .foregroundColor(index <= Int(game.ratings) ? onColor : offColor)
                                .font(.custom("", size: 12))
                        }
                    }
                    Text(game.ratings.description)
                        .font(.custom("", size: 16))
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(difficulty[game.difficulty])
                    .font(.custom("", size: 18))
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
            }
            HStack(alignment: .center, spacing: 16){
                HStack(alignment: .bottom, spacing: 16){
                    Button(action: {}, label: {
                        Image(systemName: "heart")
                            .fontWeight(.medium)
                            .font(.title3)
                    })
                    .matchedGeometryEffect(id: "gameFavorite", in: animationNamespace)
                    ShareLink(
                        item: game.name, subject: Text(game.country), message: Text(game.address),
                        preview: SharePreview(game.name, image: Image(""))) {
                                 Image(systemName: "square.and.arrow.up")
                                     .fontWeight(.medium)
                                     .font(.title3)
                             }
                        .matchedGeometryEffect(id: "gameShare", in: animationNamespace)
                    Button(action: {
                        // Handle directions button tap
                    }) {
                        Image(systemName: "location.fill")
                            .font(.title3)
                    }
                    .matchedGeometryEffect(id: "gameDirection", in: animationNamespace)
                }
                Spacer()
                Button(action: {
                    showGamePlaySheet = true
                }, label: {
                    Text("Start Game")
                        .font(.headline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                })
                .buttonStyle(.borderedProminent)
                .matchedGeometryEffect(id: "gamePlayButton", in: animationNamespace)
            }
        }
        .padding()
    }
    
    private func dateFormatter(dat: String) -> String{
        let dateFormatterCS = DateFormatter()
        dateFormatterCS.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let dateFormatterSwift = DateFormatter()
        dateFormatterSwift.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM d, h:mm a"
        
        if let date = dateFormatterCS.date(from: dat) {
            return dateFormatterPrint.string(from: date)
        }
        else if let date = dateFormatterSwift.date(from: dat) {
            return dateFormatterPrint.string(from: date)
        }else {
            return "There was an error decoding the string"
        }
    }
    
    private func openMapsApp(game: Game) {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: game.coordinate.latitude, longitude: game.coordinate.longitude))
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.openInMaps(launchOptions: nil)
    }
}

struct GameDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GameDetailView(game: DataService.game, animationNamespace: Namespace().wrappedValue, showDetails: .constant(false))
    }
}

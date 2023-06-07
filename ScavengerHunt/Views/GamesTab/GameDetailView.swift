//
//  GameDetailView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-03.
//

import SwiftUI
import MapKit

struct GameDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var gameVM: GameViewModel
    let game: Game
    @State private var gameDetail = GameDetail()
    @State private var onColor: Color = .secondary
    @State private var offColor: Color = .secondary.opacity(0.5)
    @State private var difficulty = ["None","Easy", "Medium", "Hard"]
    @State private var isPresented = false
    @State private var showItemsSheet = false
    @State private var showGamePlaySheet = false
    @State private var isShareSheetPresented = false
    
    private func fetchGame() async{
        if let game = await gameVM.getGame(game: game){
            withAnimation {
                self.gameDetail = game
            }
        }
        else{
            dismiss()
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                HStack(spacing: 16){
                    ImageView(url: gameDetail.imageName)
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    VStack(alignment: .leading){
                        Text(gameDetail.name)
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Text(gameDetail.tags.joined(separator: ", "))
                            .foregroundColor(.secondary)
                            .onAppear{
                                gameDetail.tags = gameDetail.tags.map { $0.capitalized}
                            }
                        Spacer()
                        HStack{
                            Button(action: {
                                showGamePlaySheet = true
                            }, label: {
                                Text("Play")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                            })
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.borderedProminent)
                            Spacer()
                            ShareLink(
                                item: game.name, subject: Text(gameDetail.country), message: Text(game.address),
                                     preview: SharePreview(game.name, image: Image("profileImage"))) {
                                         Image(systemName: "square.and.arrow.up")
                                             .font(.title3)
                                             .fontWeight(.medium)
                                     }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 16){
                        Divider()
                        HStack{
                            VStack(spacing: 6){
                                Text("RATINGS")
                                    .font(.custom("Footer", size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                Text(gameDetail.ratings.description)
                                    .font(.custom("", size: 24))
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                                HStack(spacing: 0){
                                    ForEach(1..<6) { index in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(index <= Int(gameDetail.ratings) ? onColor : offColor)
                                            .font(.custom("", size: 12))
                                    }
                                }
                            }
                            Divider()
                                .padding(.vertical)
                                .padding(.horizontal, 8)
                            VStack(spacing: 6){
                                Text("DIFFICULTY")
                                    .font(.custom("Footer", size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                Text(gameDetail.difficulty.description)
                                    .font(.custom("", size: 24))
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                                Text(difficulty[gameDetail.difficulty])
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Divider()
                                .padding(.vertical)
                                .padding(.horizontal, 8)
                            VStack(spacing: 6){
                                Text("ITEMS")
                                    .font(.custom("Footer", size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                Text(gameDetail.items.count.description)
                                    .font(.custom("", size: 24))
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                                Text("Items")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Divider()
                                .padding(.vertical)
                                .padding(.horizontal, 8)
                            VStack(spacing: 6){
                                Text("GAME DURATION")
                                    .font(.custom("Footer", size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                Text(gameDetail.gameDuration.description)
                                    .font(.custom("", size: 24))
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                                Text("Minutes")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Divider()
                                .padding(.vertical)
                                .padding(.horizontal, 8)
                            VStack(spacing: 6){
                                Text("DEVELOPER")
                                    .font(.custom("Footer", size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                Image(systemName: "person.crop.square")
                                    .font(.custom("", size: 30))
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                                Text("Electronic Arts")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.horizontal)
                }
                VStack(alignment: .leading){
                    Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: gameDetail.coordinate.latitude, longitude: gameDetail.coordinate.longitude), latitudinalMeters: 500, longitudinalMeters: 500)), interactionModes: [], annotationItems: [CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: gameDetail.coordinate.latitude, longitude: gameDetail.coordinate.longitude))]) { game in
                        MapMarker(coordinate: game.coordinate)
                    }
                    .onTapGesture {
                        openMapsApp(game: gameDetail)
                    }
                    .frame(height: 240)
                    .cornerRadius(8, corners: .allCorners)
                    Text(gameDetail.address + ", " + gameDetail.country)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)
                if gameDetail.isUser{
                    Divider()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    if gameDetail.items.isEmpty {
                        HStack{
                            Spacer()
                            Text("No Items Added Yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.bottom, 8)
                    }else{
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack() {
                                ForEach(gameDetail.items, id: \.self) { item in
                                    Text(item.name)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 8)
                    }
                    HStack{
                        Spacer()
                        Button(action: {
                            showItemsSheet = true
                        }, label:{
                            HStack(spacing: 2){
                                Text("Add Items")
                                    .font(.headline)
                                Image(systemName: "chevron.right")
                            }
                        })
                    }
                    .padding(.horizontal)
                }
                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                VStack(alignment: .leading, spacing: 8){
                    Text("Information")
                        .font(.title2)
                        .fontWeight(.bold)
                    VStack(spacing: 12){
                        VStack{
                            HStack{
                                Text("Name")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(gameDetail.name)
                                    .foregroundColor(.primary)
                            }
                            Divider()
                            HStack{
                                Text("Private Mode")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(gameDetail.isPrivate == true ? "YES" : "NO")
                                    .foregroundColor(.primary)
                            }
                            Divider()
                        }
                        HStack{
                            Text("Latitude")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(gameDetail.coordinate.latitude.description)
                                .foregroundColor(.primary)
                        }
                        Divider()
                        HStack{
                            Text("Longitude")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(gameDetail.coordinate.longitude.description)
                                .foregroundColor(.primary)
                        }
                        Divider()
                        HStack{
                            Text("Date Created")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(gameVM.dateFormatter(dat: gameDetail.createdDate.description))
                                .foregroundColor(.primary)
                        }
                        Divider()
                        HStack{
                            Text("Date Updated")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(gameVM.dateFormatter(dat: gameDetail.lastUpdated.description))
                                .foregroundColor(.primary)
                        }
                    }
                    .font(.subheadline)
                }
                .padding([.bottom, .horizontal])
            }
        }
        .task{
            await fetchGame()
        }
        .refreshable {
            await fetchGame()
        }
        .toolbar{
            if gameDetail.isUser{
                ToolbarItem(placement: .confirmationAction) {
                    Button("Edit") {
                        isPresented = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showGamePlaySheet, content: {
            PlayGameView(game: gameDetail)
        })
        .sheet(isPresented: $showItemsSheet, onDismiss: {
            Task{
                await fetchGame()
            }
        }, content: {
            AddItemsView(game: gameDetail)
        })
        .sheet(isPresented: $isPresented, onDismiss: {
            Task{
                await fetchGame()
            }
        },content: {
            EditGameView(game: gameDetail)
        })
    }
}

extension GameDetailView{
    private func openMapsApp(game: GameDetail) {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: gameDetail.coordinate.latitude, longitude: gameDetail.coordinate.longitude))
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.openInMaps(launchOptions: nil)
    }
}

struct GameDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GameDetailView(game: Game())
            .environmentObject(GameViewModel())
    }
}

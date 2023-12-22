//
//  GamesMapView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 10/19/23.
//

import SwiftUI
import MapKit

enum FocusedField {
    case field
}

struct GamesView: View {
    @EnvironmentObject private var vm: GameViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchedText: String = ""
    @State private var selectedGameIndex: Int = 0
    @State private var showSearchResult: Bool = false
    @State private var showTabList: Bool = true
    @State private var mapCameraPosition: MapCameraPosition = .region(.init(center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832), latitudinalMeters: 500, longitudinalMeters: 500))
    @State private var showDetails: Bool = false
    
    @Namespace private var animationNamespace
    
    var body: some View {
        NavigationStack {
            ZStack{
                mapSection
                VStack {
                    searchBarSection
                    Spacer()
                    if vm.games.count > 0{
                        gamesSection
                    }
                }
                .animation(.spring(.smooth(duration: 0.5)), value: showTabList)
                if showSearchResult{
                    SearchBar(showSearchResult: $showSearchResult, animationNamespace: animationNamespace, searchedText: $searchedText)
                }
            }
            .animation(.default, value: showSearchResult)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .task {
                await vm.getGames()
            }
            .onChange(of: vm.games) {
                selectedGameIndex = 0
            }
        }
    }
}

extension GamesView{
    private var mapSection: some View{
        Map(position: $mapCameraPosition, interactionModes: .all, selection: .constant(5)) {
            ForEach(vm.games) { game in
                Marker(game.name, coordinate: CLLocationCoordinate2D(latitude: game.coordinate.latitude, longitude: game.coordinate.longitude))
            }
        }
        .onTapGesture {
            showTabList.toggle()
        }
        .onChange(of: selectedGameIndex) { _, newValue in
            withAnimation(.easeInOut(duration: 1.0)) {
                mapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: vm.games[newValue].coordinate.latitude, longitude: vm.games[newValue].coordinate.longitude), latitudinalMeters: 500, longitudinalMeters: 500))
            }
        }
    }
    
    private var searchBarSection: some View{
        VStack {
            HStack{
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                Text(searchedText == "" ? "Search Games" : searchedText)
                    .font(.title3)
                    .foregroundStyle(searchedText == "" ? .secondary : .primary)
                    .matchedGeometryEffect(id: "searchField", in: animationNamespace)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .font(.title3)
            .padding()
            
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        .offset(y: showTabList ? 0 : -300)
        .onTapGesture {
            showSearchResult = true
        }
        .shadow(color: Color.black.opacity(0.5), radius: 20)
        .padding()
    }
    
    private var gamesSection: some View{
        TabView(selection: $selectedGameIndex) {
            ForEach(Array(vm.games.enumerated()), id: \.1) { index, game in
                GameCardView(game: game, showTabList: $showTabList, showDetails: $showDetails)
                    .padding()
                    .tag(index)
            }
        }
        .offset(y: showTabList ? 0 : 800)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(maxHeight: showDetails ? 500 : 300)
        .onAppear{
            mapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: vm.games[selectedGameIndex].coordinate.latitude, longitude: vm.games[selectedGameIndex].coordinate.longitude), latitudinalMeters: 500, longitudinalMeters: 500))
        }
    }
}

struct GameCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let game: Game
    @Binding var showTabList: Bool
    @Binding var showDetails: Bool
    @Namespace private var cardViewNamespace
    @State private var showGameSheet = false
    @State private var showGamePlaySheet = false
    
    var body: some View {
        ZStack{
            if showDetails {
                GameDetailView(game: game, animationNamespace: cardViewNamespace, showDetails: $showDetails)
            }
            else{
                GameDetailViewSmall(game: game, animationNamespace: cardViewNamespace, showDetails: $showDetails)
            }
        }
    }
}

struct SearchBar: View {
    @EnvironmentObject private var vm: GameViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Binding var showSearchResult: Bool
    let animationNamespace: Namespace.ID
    @Binding var searchedText: String
    @State private var searchText: String = ""
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        VStack{
            VStack {
                HStack{
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search Games", text: $searchText)
                        .matchedGeometryEffect(id: "searchField", in: animationNamespace, isSource: true)
                        .focused($focusedField, equals: .field)
                        .onChange(of: searchText) { _, newValue in
                            Task{
                                await vm.searchComplete(query: newValue)
                            }
                        }
                        .submitLabel(.search)
                        .onSubmit {
                            Task{
                                await vm.search(query: searchText)
                                withAnimation {
                                    searchedText = String(searchText.split(separator: ",")[0])
                                    focusedField = nil
                                    showSearchResult = false
                                }
                            }
                        }
                    Button("Cancel") {
                        withAnimation {
                            focusedField = nil
                            showSearchResult = false
                            searchedText = ""
                        }
                    }
                }
                .font(.title3)
                .padding()
                .onAppear{
                    withAnimation {
                        focusedField = .field
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme == .light ? .ultraThinMaterial : .regularMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding()
            
            ScrollView(showsIndicators: false) {
                ForEach(vm.searchCompletion, id: \.self){ result in
                    Divider()
                    VStack(alignment: .leading){
                        Button {
                            Task{
                                await vm.search(query: result)
                                withAnimation {
                                    searchText = result
                                    focusedField = nil
                                    searchedText = String(searchText.split(separator: ",")[0])
                                    showSearchResult = false
                                }
                            }
                        } label: {
                            Text(result)
                                .font(.headline)
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .font(.title3)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background()
    }
}

#Preview {
    GamesView()
        .environmentObject(GameViewModel())
}


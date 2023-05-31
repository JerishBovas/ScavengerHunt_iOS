//
//  PlayGameView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-05-30.
//

import SwiftUI
import CoreLocation

struct PlayGameView: View {
    @Environment(\.dismiss) private var dismiss
    var game: GameDetail
    @StateObject private var vm = PlayGameViewModel()
    @StateObject private var locationService = LocationService()
    @State private var userLocation: CLLocation?
    @State private var locationStatus: LocationStatus = .notChecking
    @State private var isWithinRange: Bool = false
    @State private var showingAlert: Bool = false
    
    var body: some View {
        ZStack{
            ImageView(url: game.imageName)
            Rectangle().fill(.ultraThinMaterial)
            ScrollView(showsIndicators: false){
                VStack(spacing: 16) {
                    Text(game.name)
                        .font(.title)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                    VStack(spacing: 16) {
                        GridRowView(name: "Connection Status", status: vm.connectionStatus.icon)
                            .onChange(of: vm.connectionStatus) { newValue in
                                if newValue == .connected{
                                    vm.getGameStatus(gameId: game.id, userId: game.userId)
                                }
                            }
                        GridRowView(name: "Game Status", status: vm.gamePlayStatus.icon)
                            .onChange(of: vm.gamePlayStatus) { newValue in
                                if newValue == .ready{
                                    switch locationService.authorizationStatus {
                                    case .authorizedWhenInUse:
                                        if let location = locationService.currentLocation{
                                            locationStatus = .checking
                                            userLocation = location
                                            guard let loca = userLocation else {return}
                                            let from = CLLocationCoordinate2D(latitude: loca.coordinate.latitude, longitude: loca.coordinate.longitude)
                                            let to = CLLocationCoordinate2D(latitude: game.coordinate.latitude, longitude: game.coordinate.longitude)
                                            let distance = calculateDistance(from: from, to: to)
                                            isWithinRange = distance < 100 ? true : false
                                            locationStatus = isWithinRange ? .done : .checking
                                        }
                                    case .restricted, .denied:
                                        locationStatus = .failed
                                        showingAlert = true
                                    default:
                                        return
                                    }
                                }
                            }
                        GridRowView(name: "Location Status", status: locationStatus.icon)
                    }
                    .frame(width: UIScreen.main.bounds.width - 40)
                    if isWithinRange {
                        Text("You are in the game location.")
                            .foregroundColor(.green)
                            .font(.headline)
                    } else {
                        Text("Please move closer to the game location.")
                            .foregroundColor(.yellow)
                            .font(.headline)
                    }
                    CircleMap(gameLocation: CLLocationCoordinate2D(latitude: game.coordinate.latitude, longitude: game.coordinate.longitude))
                        .frame(width: UIScreen.main.bounds.width - 40)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    Button(action: {
                        // Start game action
                    }) {
                        Text("Start Game")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(!isWithinRange)
                }
                .overlay{
                    VStack{
                        HStack{
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .symbolRenderingMode(.monochrome)
                                    .font(.largeTitle)
                                    .tint(.primary)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }

                        }
                        Spacer()
                    }
                }
                .overlay{
                    VStack{
                        ForEach(vm.toasts) { toast in
                            ToastView(toast: toast, isPresented: .constant(true)) {
                                vm.toasts.removeAll(where: { $0.id == toast.id })
                            }
                            .transition(.slide)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .padding(.top, 60)
            .onAppear{
                vm.openConnection()
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .ignoresSafeArea()
        .onReceive(locationService.$currentLocation) { location in
            locationStatus = .checking
            userLocation = location
            guard let loca = userLocation else {return}
            let from = CLLocationCoordinate2D(latitude: loca.coordinate.latitude, longitude: loca.coordinate.longitude)
            let to = CLLocationCoordinate2D(latitude: game.coordinate.latitude, longitude: game.coordinate.longitude)
            let distance = calculateDistance(from: from, to: to)
            isWithinRange = distance < 100 ? true : false
            locationStatus = isWithinRange ? .done : .checking
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Location Access Denied"),
                message: Text("Please grant location access in Settings"),
                primaryButton: .cancel(),
                secondaryButton: .default(Text("Settings")) {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(settingsURL)
                }
            )
        }
    }
}

extension PlayGameView{
    private func createGridColumns() -> [GridItem] {
        Array(repeating: .init(.flexible(), spacing: 16), count: 3)
    }
    
    private func calculateDistance(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> CLLocationDistance {
        let sourceLocation = CLLocation(latitude: source.latitude, longitude: source.longitude)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        
        return sourceLocation.distance(from: destinationLocation)
    }
}

struct GridRowView: View {
    var name: String
    var status: RunStatus
    
    var body: some View {
        HStack {
            Text(name)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
            if status == .running{
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(.primary)
                    .padding(.trailing, 8)
            }
            else{
                status.getIcon
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct ToastView: View {
    @State var toast: Toast
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack {
            Text(toast.message)
                .font(.headline)
                .foregroundColor(toast.backgroundColor)
                .padding(16)
                .padding(.horizontal, 20)
                .background(.regularMaterial)
                .cornerRadius(10)
                .opacity(isPresented ? 1 : 0)
                .animation(.spring(), value: toast)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
                isPresented = false
                onDismiss?()
            }
        }
    }
}

struct PlayGameView_Previews: PreviewProvider {
    static var previews: some View {
        PlayGameView(game: DataService.gameDetail)
    }
}

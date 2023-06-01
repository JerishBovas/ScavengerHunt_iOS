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
    @State private var showingSection: Int = 0
    
    var body: some View {
        if let gamePlay = vm.gamePlay{
            gamePlaySection(play: gamePlay)
        }
        else{
            preparationSection
        }
    }
}

extension PlayGameView{
    private func gamePlaySection(play: GamePlay) -> some View{
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text("Score")
                        .font(.headline)
                    Text(play.score.description)
                        .font(.largeTitle)
                        .fontWeight(.medium)
                }
                Spacer()
                VStack(alignment: .trailing){
                    Text("Time Remaining")
                        .font(.headline)
                    Text(play.deadline)
                        .font(.largeTitle)
                        .fontWeight(.medium)
                }
            }
            HStack{
                if let item = vm.item{
                    Spacer()
                    Text(item.name)
                    Spacer()
                    ImageView(url: item.imageUrl)
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                else{
                    Spacer()
                    Text("Item...")
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .frame(width: 150, height: 150)
                }
            }
            if let image = vm.image{
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            }
            else{
                CameraPreviewView(session: vm.session)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            }
            Spacer()
            
        }
        .padding(20)
        .ignoresSafeArea(.keyboard)
        .overlay{
            VStack{
                Spacer()
                footerSection
            }
        }
        .onAppear{
            vm.setupCamera()
        }
    }
    
    private var preparationSection: some View{
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
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
            HStack{
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                Spacer()
                Button(action: {
                    vm.startGame(gameId: game.id, gameUserId: game.userId)
                }) {
                    Text("Start Game")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
                .disabled(!isWithinRange)
            }
            .padding()
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
        .padding(.horizontal, 20)
        .onAppear{
            vm.openConnection()
        }
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
    
    private var footerSection: some View{
        HStack{
            if let _ = vm.image{
                HStack{
                    Button(action: {
                        vm.image = nil
                    }, label: {
                        Image(systemName: "xmark")
                            .symbolRenderingMode(.multicolor)
                            .font(.largeTitle)
                    })
                    Spacer()
                    Button(action: {
                        vm.verifyItem()
                    }, label: {
                        Image(systemName: "checkmark")
                            .symbolRenderingMode(.multicolor)
                            .font(.largeTitle)
                    })
                }
                .padding(.horizontal, 100)
            }else{
                Spacer()
                Button(action: {
                    vm.captureImage()
                }, label: {
                    ZStack{
                        Circle()
                            .frame(width: 70)
                        Circle()
                            .stroke(.background, lineWidth: 3.0)
                            .frame(width: 60)
                    }
                })
                Spacer()
            }
        }
        .frame(height: 100)
        .background(.ultraThickMaterial)
    }
    
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
                .font(.headline)
            Spacer()
            if status == .running{
                ProgressView()
                    .tint(.primary)
                    .padding(.trailing, 4)
            }
            else{
                status.getIcon
            }
        }
        .padding(8)
        .padding(.horizontal, 8)
        .frame(height: 50)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
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

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
    @State private var showConfirmation: Bool = false
    
    var body: some View {
        VStack{
            if showingSection == 0{
                preparationSection
            }
            else if showingSection == 1{
                if let result = vm.result{
                    VStack{
                        Text(result.name)
                        Text(result.score.description)
                    }
                    .background(Color.accentColor)
                }else{
                    gamePlaySection(play: vm.gamePlay)
                }
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: showingSection)
        .edgesIgnoringSafeArea(.bottom)
        .overlay{
            VStack(){
                HStack{
                    Button("Close") {
                        if showingSection == 1{
                            showConfirmation = true
                        }else{
                            dismiss()
                        }
                    }
                    .foregroundColor(.red)
                    .buttonStyle(.borderless)
                    Spacer()
                    if vm.connectionStatus == .connected{
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.title2)
                            .symbolRenderingMode(.multicolor)
                    }else{
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .font(.title2)
                            .foregroundColor(.red)
                            .symbolRenderingMode(.multicolor)
                    }
                }
                .padding(.horizontal, 20)
                .alert("End Game?", isPresented: $showConfirmation) {
                    Button("Cancel"){
                        showConfirmation = false
                    }
                    Button("Yes"){
                        dismiss()
                    }
                    .foregroundColor(.red)
                } message: {
                    Text("Are you sure you want to end the Game?")
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
        .onAppear{
            vm.openConnection()
        }
        .onDisappear{
            if let play = vm.gamePlay{
                vm.stopTimer()
                vm.endGame(gamePlayId: play.id)
            }
            vm.closeConnection()
        }
    }
}

extension PlayGameView{
    private func gamePlaySection(play: GamePlay?) -> some View{
        VStack(spacing: 0){
            Text(game.name)
                .font(.title)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .padding(.bottom, 8)
            Divider()
            HStack{
                HStack{
                    VStack(spacing: 6){
                        Text("SCORE")
                            .font(.custom("Footer", size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(.blue) // Use your desired color
                        Text(play?.score.description ?? "0")
                            .font(.custom("", size: 24))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.blue) // Use your desired color
                        Text("XP")
                            .font(.footnote)
                            .foregroundColor(.blue) // Use your desired color
                    }
                    Divider()
                        .padding(.vertical)
                        .padding(.horizontal, 8)
                    VStack(spacing: 6){
                        Text("TOTAL")
                            .font(.custom("Footer", size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(.green) // Use your desired color
                        Text(play?.items.count.description ?? "0")
                            .font(.custom("", size: 24))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.green) // Use your desired color
                        Text("Items")
                            .font(.footnote)
                            .foregroundColor(.green) // Use your desired color
                    }
                    Divider()
                        .padding(.vertical)
                        .padding(.horizontal, 8)
                    VStack(spacing: 6){
                        Text("FOUND")
                            .font(.custom("Footer", size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(.orange) // Use your desired color
                        Text("\((play?.items.count ?? 0) - (vm.itemsRemaining?.count ?? 0))")
                            .font(.custom("", size: 24))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.orange) // Use your desired color
                        Text("Items")
                            .font(.footnote)
                            .foregroundColor(.orange) // Use your desired color
                    }
                }
                HStack{
                    Divider()
                        .padding(.vertical)
                        .padding(.horizontal, 8)
                    VStack(spacing: 6){
                        Text("TO FIND")
                            .font(.custom("Footer", size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(.purple) // Use your desired color
                        Text(vm.itemsRemaining?.count.description ?? "0")
                            .font(.custom("", size: 24))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.purple) // Use your desired color
                        Text("Items")
                            .font(.footnote)
                            .foregroundColor(.purple) // Use your desired color
                    }
                    Divider()
                        .padding(.vertical)
                        .padding(.horizontal, 8)
                    VStack(spacing: 6){
                        Text("TIME LEFT")
                            .font(.custom("Footer", size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(.red) // Use your desired color
                        Text(timeString(from: vm.timeRemaining))
                            .font(.custom("", size: 24))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.red) // Use your desired color
                        Text("Minutes")
                            .font(.footnote)
                            .foregroundColor(.red) // Use your desired color
                    }
                }
            }

            .frame(maxHeight: 80)
            .padding(.vertical, 8)
            Divider()
            HStack{
                if let item = vm.item{
                    HStack{
                        ImageView(url: item.imageUrl)
                            .scaledToFit()
                            .frame(maxHeight: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Spacer()
                        VStack(spacing: 20){
                            Text(item.name)
                                .font(.title)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                        }
                        Spacer()
                    }
                }
                else{
                    HStack{
                        Image("placeholder")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Spacer()
                        VStack(spacing: 20){
                            Text("Item Name")
                                .font(.title)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                        }
                        .padding()
                        Spacer()
                    }
                }
            }
            .padding(8)
            VStack{
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
            }
            .animation(.default, value: vm.image)
            footerSection
            
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
            Button(action: {
                showingSection = 1
                vm.startGame(gameId: game.id, gameUserId: game.userId)
            }) {
                Text("Start Game")
                    .font(.title)
                    .padding(8)
            }
            .buttonStyle(.bordered)
            .disabled(!isWithinRange)
            Spacer()
        }
        .padding(.horizontal, 20)
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

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
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

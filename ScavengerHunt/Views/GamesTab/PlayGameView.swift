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
    @State private var backgroundImage: String = ""
    @State private var rating: Int = 0
    
    private let backgroundSet: [String] = ["img1", "img2", "img3", "img4", "img5", "img6", "img7", "img8"]
    
    var body: some View {
        VStack{
            if showingSection == 0{
                preparationSection
            }
            else if showingSection == 1{
                if let result = vm.result{
                    gameResultSection(name: result.name, score: result.score)
                }else{
                    gamePlaySection(play: vm.gamePlay)
                }
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: showingSection)
        .edgesIgnoringSafeArea(.bottom)
        .overlay{
            if vm.result == nil{
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
                    .alert(isPresented: $showConfirmation) {
                        Alert(title: Text("End Game?"), message: Text("Are you sure you want to End the Game?"), primaryButton: .destructive(Text("Yes")){
                            dismiss()
                        }, secondaryButton: .cancel())
                    }

                    Spacer()
                }
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
            if let play = vm.gamePlay, vm.result == nil{
                vm.endGame(gamePlayId: play.id)
            }
            vm.stopTimer()
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
                        Text(play?.score.description ?? "0")
                            .font(.custom("", size: 24))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        Text("XP")
                            .font(.footnote)
                    }
                    Divider()
                        .padding(.vertical)
                        .padding(.horizontal, 8)
                    VStack(spacing: 6){
                        Text("TOTAL")
                            .font(.custom("Footer", size: 12))
                            .fontWeight(.bold)
                        Text(play?.items.count.description ?? "0")
                            .font(.custom("", size: 24))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        Text("Items")
                            .font(.footnote)
                    }
                    Divider()
                        .padding(.vertical)
                        .padding(.horizontal, 8)
                    VStack(spacing: 6){
                        Text("FOUND")
                            .font(.custom("Footer", size: 12))
                            .fontWeight(.bold)
                        Text("\((play?.items.count ?? 0) - (vm.itemsRemaining.count))")
                            .font(.custom("", size: 24))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        Text("Items")
                            .font(.footnote)
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
                        Text(vm.itemsRemaining.count.description)
                            .font(.custom("", size: 24))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        Text("Items")
                            .font(.footnote)
                    }
                    Divider()
                        .padding(.vertical)
                        .padding(.horizontal, 8)
                    VStack(spacing: 6){
                        Text("TIME LEFT")
                            .font(.custom("Footer", size: 12))
                            .fontWeight(.bold)
                        Text(timeString(from: vm.timeRemaining))
                            .font(.custom("", size: 24))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        Text("Minutes")
                            .font(.footnote)
                    }
                }
            }
            .frame(maxHeight: 80)
            .padding(.vertical, 8)
            .foregroundColor(.secondary)
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
                            Text("")
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
            .disabled(!(vm.connectionStatus == .connected) || !(vm.gamePlayStatus == .ready) || !isWithinRange)
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
                if vm.isVerifying{
                    HStack{
                        Spacer()
                        VStack{
                            ProgressView()
                            Text("Verifying...")
                        }
                        Spacer()
                    }
                }else{
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
                    .padding(.horizontal, 50)
                }
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
    
    func gameResultSection(name:String, score: Int) -> some View {
        ZStack {
            // Background with celebration
            Image(backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .onAppear{
                    backgroundImage = backgroundSet.randomElement()!
                }
            
            VStack(spacing: 16) {
                Text("Congratulations")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                
                Text("\(name.uppercased())")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                
                Text("XP Earned: \(score)")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                rating = index
                            }
                    }
                }
                .onChange(of: rating) { newValue in
                    if newValue > 0 && newValue < 6{
                        vm.submitRating(rating: rating)
                    }
                }
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(20)
        }
        .overlay{
            VStack{
                HStack{
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .shadow(radius: 5)
                }
                .padding(.vertical, 60)
                .padding(.horizontal, 20)
                Spacer()
            }
        }
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

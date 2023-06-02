//
//  PlayGameViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-08-11.
//

import Foundation
import UIKit
import SignalRClient
import SwiftUI
import AVFoundation

class PlayGameViewModel : NSObject, ObservableObject{
    @Published var connectionStatus: ConnectionStatus = .stopped
    @Published var gamePlayStatus: GameStatus = .notFetched
    @Published var toasts: [Toast] = []
    @Published var item: Item?
    @Published var gamePlay: GamePlay?
    @Published var itemsRemaining: [Item]?
    @Published var result: GamePlay?
    @Published var image: UIImage?
    @Published var timeRemaining = 0
    private var accessToken: String?
    private var hubConnection: HubConnection?
    private var imageProcessor = ImageProcessor()
    private var timesRetry: Int = 0
    let session = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    @State private var timer: Timer?
    
    
    override init() {
        super.init()
        accessToken = UserDefaults.standard.string(forKey: "accessToken")
        let url = Bundle.main.infoDictionary?["API_ENDPOINT"] as? String ?? ""
        hubConnection = HubConnectionBuilder(url: URL(string: "\(url)/Play")!)
            .withHubConnectionDelegate(delegate: self)
            .withHttpConnectionOptions(configureHttpOptions: { httpConnectionOptions in
                httpConnectionOptions.accessTokenProvider = {() -> String? in
                    return self.accessToken
                }
            })
            .withLogging(minLogLevel: .info)
            .build()
    
        addListeners()
    }
    
    
    func addListeners(){
        hubConnection!.on(method: "Error") { message in
            let message = try! message.getArgument(type: String.self)
            DispatchQueue.main.async {
                self.enqueue(message: message, backgroundColor: .red)
            }
        }
        
        hubConnection!.on(method: "VerifyImage") { message in
            let result = try? message.getArgument(type: VerifiedItem.self)
            
            if let result = result, let _ = self.gamePlay {
                DispatchQueue.main.async {
                    withAnimation {
                        self.gamePlay?.gameEnded = result.gameEnded
                        self.gamePlay?.score = result.score
                        if let itemId = result.itemToRemove{
                            self.itemsRemaining?.removeAll(where: {$0.id == itemId})
                        }
                    }
                }
            }
        }
        
        hubConnection!.on(method: "StartGame") { message in
            let result = try? message.getArgument(type: GamePlay.self)
            
            if let result = result {
                DispatchQueue.main.async {
                    withAnimation {
                        self.gamePlay = result
                        self.itemsRemaining = result.items
                        self.item = self.randomPickWithNoRepeats(from: result.items)
                        self.startTimer()
                    }
                }
            }
        }
        
        hubConnection!.on(method: "EndGame") { message in
            let result = try? message.getArgument(type: GamePlay.self)
            
            if let result = result {
                DispatchQueue.main.async {
                    withAnimation {
                        self.result = result
                    }
                }
            }
        }
        
        hubConnection!.on(method: "GameStatus") { message in
            let result = try? message.getArgument(type: Bool.self)
            
            if let status = result {
                DispatchQueue.main.async {
                    withAnimation {
                        self.gamePlayStatus = status ? .ready : .notReady
                    }
                }
            }
        }
    }
    
    func verifyItem(){
        guard let img = self.image,
                let image = imageProcessor.getCompressedImage(image: img, quality: 128),
                let item = self.item,
                let gamePlay = self.gamePlay,
                let itemRemaining = self.itemsRemaining else {return}
        
        let data = ImageData(imageString: image.base64EncodedString(), itemId: item.id, gamePlayId: gamePlay.id)
        let serializedData = try? JSONEncoder().encode(data)
        let jsonString = String(data: serializedData!, encoding: .utf8)
        guard connectionStatus == .connected else {return}
        hubConnection!.send(method: "VerifyImage", jsonString){ error in
            if let error = error {
                print("Sending data failed: \(error)")
                // Handle the error, such as retrying or showing an error message
            } else {
                DispatchQueue.main.async {
                    withAnimation {
                        self.item = self.randomPickWithNoRepeats(from: itemRemaining)
                        self.image = nil
                    }
                }
            }
        }
    }
    
    func startGame(gameId: String, gameUserId: String){
        guard connectionStatus == .connected else {return}
        hubConnection!.send(method: "StartGame", gameId, gameUserId)
    }
    
    func endGame(gamePlayId: String){
        guard connectionStatus == .connected else {return}
        hubConnection!.send(method: "EndGame", gamePlayId)
    }
    
    func getGameStatus(gameId: String, userId: String){
        DispatchQueue.main.async {
            withAnimation {
                self.gamePlayStatus = .fetching
            }
        }
        guard connectionStatus == .connected else {return}
        hubConnection!.send(method: "GameStatus", gameId, userId)
    }
    
    func openConnection(){
        DispatchQueue.main.async {
            withAnimation {
                self.connectionStatus = .connecting
            }
        }
        hubConnection!.start()
    }
    
    func closeConnection(){
        hubConnection!.stop()
    }
}

extension PlayGameViewModel: AVCapturePhotoCaptureDelegate{
    func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
                guard let device = AVCaptureDevice.default(for: .video) else {
                    return
                }
                
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    self.session.addInput(input)
                    
                    self.photoOutput = AVCapturePhotoOutput()
                    if let photoOutput = self.photoOutput {
                        self.session.addOutput(photoOutput)
                    }
                } catch {
                    print("Error setting up camera: \(error.localizedDescription)")
                }
                
                self.session.startRunning()
            }
    }
    
    func captureImage() {
        guard let photoOutput = photoOutput else {
            return
        }
        
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Process the captured image data
            processImage(imageData)
        }
    }
    
    private func processImage(_ imageData: Data) {
        guard let img = UIImage(data: imageData), let sqrImg = imageProcessor.cropImageToSquare(image: img) else {return}
        DispatchQueue.main.async {
            withAnimation {
                self.image = sqrImg
            }
        }
    }
}

extension PlayGameViewModel{
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let dateFormatterCS = DateFormatter()
            dateFormatterCS.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            guard let gamePlay = self.gamePlay, let deadline = dateFormatterCS.date(from: gamePlay.deadline) else {return}
            let currentTime = Date()
            let timeDifference = Calendar.current.dateComponents([.second], from: currentTime, to: deadline)
            if let secondsRemaining = timeDifference.second, secondsRemaining > 0 {
                self.timeRemaining = secondsRemaining
            } else {
                self.stopTimer()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        if let play = gamePlay{
            endGame(gamePlayId: play.id)
        }
    }
    private func randomPickWithNoRepeats<T>(from array: [T]) -> T? {
        guard !array.isEmpty else {
            return nil
        }
        
        var previousIndex: Int?
        var randomIndex: Int
        
        repeat {
            randomIndex = Int.random(in: 0..<array.count)
        } while randomIndex == previousIndex
        
        previousIndex = randomIndex
        return array[randomIndex]
    }

    func enqueue(message: String, backgroundColor: Color) {
        let toast = Toast(message: message, backgroundColor: backgroundColor)
        DispatchQueue.main.async {
            withAnimation {
                self.toasts.append(toast)
                self.dequeueToast(after: toast.duration)
            }
        }
    }
    
    private func dequeueToast(after duration: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.toasts.removeFirst()
        }
    }
}

extension PlayGameViewModel: HubConnectionDelegate{
    internal func connectionDidOpen(hubConnection: HubConnection) {
        DispatchQueue.main.async {
            withAnimation {
                self.timesRetry = 0
                self.connectionStatus = .connected
                self.enqueue(message: "Connected", backgroundColor: .green)
            }
        }
    }

    internal func connectionDidFailToOpen(error: Error) {
        if timesRetry < 5{
            DispatchQueue.main.async {
                withAnimation {
                    self.connectionStatus = .tryingAgain
                    self.enqueue(message: "Retrying Connection to Game Server", backgroundColor: .yellow)
                }
            }
            timesRetry += 1
            hubConnection!.start()
        }else{
            DispatchQueue.main.async {
                withAnimation {
                    self.connectionStatus = .connectionFailed
                    self.enqueue(message: "Error connecting to Game Server", backgroundColor: .red)
                }
            }
        }
    }

    internal func connectionDidClose(error: Error?) {
        DispatchQueue.main.async {
            withAnimation {
                self.connectionStatus = .stopped
                self.enqueue(message: "Connection stopped", backgroundColor: .red)
            }
        }
    }
}

struct Toast: Equatable, Identifiable{
    var id = UUID()
    var message: String
    var backgroundColor: Color
    var duration: TimeInterval = 5
}

enum RunStatus{
    typealias Body = Self
    
    case running, notRunning, success, failed
    
    var getIcon: some View{
        switch self{
        case .failed:
            return Image(systemName: "xmark")
                .font(.title2)
                .symbolRenderingMode(.multicolor)
        case .notRunning:
            return Image(systemName: "questionmark")
                .font(.title2)
                .symbolRenderingMode(.multicolor)
        case .success:
            return Image(systemName: "checkmark")
                .font(.title2)
                .symbolRenderingMode(.multicolor)
        case .running:
            return Image(systemName: "figure.run")
                .font(.title2)
                .symbolRenderingMode(.multicolor)
        }
    }
}

enum GameStatus{
    case notFetched, fetching, ready, notReady
    
    var icon: RunStatus{
        switch self{
        case .notFetched:
            return .notRunning
        case .fetching:
            return .running
        case .ready:
            return .success
        case .notReady:
            return .failed
        }
    }
}

enum LocationStatus{
    case checking, notChecking, done, failed
    
    var icon: RunStatus{
        switch self{
        case .notChecking:
            return .notRunning
        case .checking:
            return .running
        case .done:
            return .success
        case .failed:
            return .failed
        }
    }
}

enum ConnectionStatus{
    case connected, connecting, tryingAgain, connectionFailed, stopped
    
    var description: String{
        switch self{
        case .connected:
            return "Connection Success"
        case .connecting:
            return "Connecting..."
        case .tryingAgain:
            return "Trying Again..."
        case .connectionFailed:
            return "Connection Failed"
        case .stopped:
            return "Connection Stopped"
        }
    }
    
    var icon: RunStatus{
        switch self{
        case .connected:
            return .success
        case .connecting:
            return .running
        case .tryingAgain:
            return .running
        case .connectionFailed:
            return .failed
        case .stopped:
            return .notRunning
        }
    }
}

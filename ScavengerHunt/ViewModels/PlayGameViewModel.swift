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
    private var accessToken: String?
    @Published var image: UIImage?
    private var hubConnection: HubConnection?
    private var imageProcessor = ImageProcessor()
    private var timesRetry: Int = 0
    let session = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    
    
    override init() {
        super.init()
        accessToken = UserDefaults.standard.string(forKey: "accessToken")
        hubConnection = HubConnectionBuilder(url: URL(string: "https://api.scavengerhunt.quest/Play")!)
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
            print(">>> \(try! message.getArgument(type: String.self))")
        }
    }
    
    func verifyItem(){
        guard let img = self.image,
                let image = imageProcessor.getCompressedImage(image: img, quality: 128),
                let item = self.item,
                let gamePlay = self.gamePlay else {return}
        
        let data = ImageData(imageBytes: image, itemId: item.id, gamePlayId: gamePlay.id)
        self.item = randomPickWithNoRepeats(from: gamePlay.items)
        hubConnection!.invoke(method: "VerifyImage", data, resultType: VerifiedItem.self) { (result: VerifiedItem?, error: Error?) in
            if let result = result, let _ = self.gamePlay {
                DispatchQueue.main.async {
                    withAnimation {
                        self.gamePlay?.gameEnded = result.gameEnded
                        self.gamePlay?.score = result.score
                        if let itemId = result.itemToRemove{
                            self.gamePlay?.items.removeAll(where: {$0.id == itemId})
                        }
                    }
                }
            } else if let _ = error {
                DispatchQueue.main.async {
                    withAnimation {
                        self.enqueue(message: error?.localizedDescription ?? "Error starting game.", backgroundColor: .red)
                    }
                }
            }
        }
    }
    
    func startGame(gameId: String, gameUserId: String){
        hubConnection!.invoke(method: "StartGame", gameId, gameUserId, resultType: GamePlay.self) { (result: GamePlay?, error: Error?) in
            if let result = result {
                DispatchQueue.main.async {
                    withAnimation {
                        self.gamePlay = result
                        self.item = self.randomPickWithNoRepeats(from: result.items)
                    }
                }
            } else if let _ = error {
                DispatchQueue.main.async {
                    withAnimation {
                        self.enqueue(message: error?.localizedDescription ?? "Error starting game.", backgroundColor: .red)
                    }
                }
            }
        }
    }
    
    func getGameStatus(gameId: String, userId: String){
        self.gamePlayStatus = .fetching
        hubConnection!.invoke(method: "GameStatus", gameId, userId, resultType: Bool.self) { (status: Bool?, error: Error?) in
            if let status = status {
                DispatchQueue.main.async {
                    withAnimation {
                        self.gamePlayStatus = status ? .ready : .notReady
                    }
                }
            } else if let _ = error {
                DispatchQueue.main.async {
                    withAnimation {
                        self.gamePlayStatus = .notFetched
                        self.enqueue(message: "Error fetching data", backgroundColor: .red)
                    }
                }
            }
        }
    }
    
    func openConnection(){
        connectionStatus = .connecting
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
        guard let img = UIImage(data: imageData), let sqrImg = imageProcessor.cropImageToSquare(image: img), let compressImg = imageProcessor.getCompressedImage(image: sqrImg, quality: 256) else {return}
        image = UIImage(data: compressImg)
    }
}

extension PlayGameViewModel{
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
        toasts.append(toast)
        dequeueToast(after: toast.duration)
    }
    
    private func dequeueToast(after duration: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.toasts.removeFirst()
        }
    }
}

extension PlayGameViewModel: HubConnectionDelegate{
    internal func connectionDidOpen(hubConnection: HubConnection) {
        timesRetry = 0
        connectionStatus = .connected
    }

    internal func connectionDidFailToOpen(error: Error) {
        if timesRetry < 5{
            connectionStatus = .tryingAgain
            timesRetry += 1
            enqueue(message: "Retrying Connection to Game Server", backgroundColor: .yellow)
            hubConnection!.start()
        }else{
            connectionStatus = .connectionFailed
            enqueue(message: "Error connecting to Game Server", backgroundColor: .red)
        }
    }

    internal func connectionDidClose(error: Error?) {
        connectionStatus = .stopped
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

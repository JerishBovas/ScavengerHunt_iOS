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

class PlayGameViewModel : ObservableObject, HubConnectionDelegate{
    @Published var connectionStatus: ConnectionStatus = .stopped
    @Published var gamePlayStatus: GameStatus = .notFetched
    @Published var toasts: [Toast] = []
    private var accessToken: String?
    private var image: UIImage? = nil
    private var hubConnection: HubConnection?
    private var imageProcessor: ImageProcessor
    private var timesRetry: Int = 0
    
    init() {
        accessToken = UserDefaults.standard.string(forKey: "accessToken")
        imageProcessor = ImageProcessor()
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
        hubConnection!.on(method: "VerifyItem") { message in
            print(">>> \(try! message.getArgument(type: String.self))")
        }
    }
    
    func getGameStatus(gameId: String, userId: String){
        self.gamePlayStatus = .fetching
        hubConnection!.invoke(method: "GameStatus", gameId, userId, resultType: Bool.self) { (status: Bool?, error: Error?) in
            if let status = status {
                DispatchQueue.main.async {
                    self.gamePlayStatus = status ? .ready : .notReady
                }
            } else if let _ = error {
                DispatchQueue.main.async {
                    self.gamePlayStatus = .notFetched
                    self.enqueue(message: "Error fetching data", backgroundColor: .red)
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
            return Image(systemName: "xmark.octagon.fill")
                .font(.title)
                .symbolRenderingMode(.multicolor)
        case .notRunning:
            return Image(systemName: "questionmark.circle.fill")
                .font(.title)
                .symbolRenderingMode(.multicolor)
        case .success:
            return Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .symbolRenderingMode(.multicolor)
        case .running:
            return Image(systemName: "figure.run.circle.fill")
                .font(.title)
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

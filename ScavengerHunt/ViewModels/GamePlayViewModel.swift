//
//  GamePlayViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-08-11.
//

import Foundation
import UIKit
import SignalRClient

class GamePlayViewModel : ObservableObject{
    private var image: UIImage? = nil
    private var hubConnection: HubConnection? = nil
    private var connectionDelegate: HubConnectionDelegate? = nil
    
    init() {
        let defaults = UserDefaults.standard
        
        connectionDelegate = PlayHubConnectionDelegate(vm: self)
        hubConnection = HubConnectionBuilder(url: URL(string: "http://192.168.2.23:5190/Play")!)
            .withHubConnectionDelegate(delegate: connectionDelegate!)
            .withHttpConnectionOptions(configureHttpOptions: { httpConnectionOptions in
                httpConnectionOptions.accessTokenProvider = {() -> String? in
                    return defaults.string(forKey: "accessToken")
                }
            })
            .withLogging(minLogLevel: .info)
            .build()
        
        hubConnection!.on(method: "VerifyItem") { message in
            print(">>> \(try! message.getArgument(type: String.self))")
        }
        hubConnection!.start()
    }
    
    func invokeConnection(){
        hubConnection!.invoke(method: "VerifyItem") { [self] error in
            if let error = error{
                print(error)
                let image = FunctionsLibrary().getCompressedImage(image: image!, quality: 64)
                _ = image?.base64EncodedString()
            }else{
                print("Successfully Invoked!")
            }
        }
    }
    
    func connectionDidOpen() {
        print("Connected")
        invokeConnection()
    }

    func connectionDidFailToOpen(error: Error) {
        print("Connection Failed")
    }

    func connectionDidClose(error: Error?) {
        print("Disconnected")
    }
}

class PlayHubConnectionDelegate: HubConnectionDelegate {
    weak var vm: GamePlayViewModel?
    
    init(vm: GamePlayViewModel) {
        self.vm = vm
    }
    
    func connectionDidOpen(hubConnection: HubConnection) {
        vm?.connectionDidOpen()
    }

    func connectionDidFailToOpen(error: Error) {
        vm?.connectionDidFailToOpen(error: error)
    }

    func connectionDidClose(error: Error?) {
        vm?.connectionDidClose(error: error)
    }
}

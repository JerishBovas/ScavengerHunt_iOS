//
//  GameViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation
import CoreLocation
import SwiftUI

class GameViewModel: ObservableObject {
    private var accessToken: String?
    @Published var showAlert: Bool = false
    @Published var appError: AppError?
    @Published var games: [Game]?
    @Published var myGames: [Game]?
    private let api: ApiService
    private let lib: FunctionsLibrary
    var temperature: Double?
    var uvIndex: Int?
    
    init() {
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken")
        self.games = nil
        self.api = ApiService()
        self.lib = FunctionsLibrary()
        self.temperature = nil
        self.uvIndex = nil
    }
    
    func getMyGames() async{
        do{
            guard let accessToken = accessToken else{
                throw AppError(title: "Authentication Failed", message: "Please try logging in again")
            }
            let games: [Game] = try await api.get(accessToken: accessToken, endpoint: APIEndpoint.game.description + "?category=user&count=25")
            print("Games fetched")
            DispatchQueue.main.async {
                self.myGames = games
            }
        }catch let error as AppError{
            DispatchQueue.main.async {
                self.appError = error
                self.showAlert = true
            }
        }catch {
            DispatchQueue.main.async {
                self.appError = AppError(title: "An error occured.", message: error.localizedDescription)
                self.showAlert = true
            }
        }
    }
    
    func getGames() async{
        do{
            guard let accessToken = accessToken else{
                throw AppError(title: "Authentication Failed", message: "Please try logging in again")
            }
            let games: [Game] = try await api.get(accessToken: accessToken, endpoint: APIEndpoint.game.description + "?category=other&count=25")
            print("Games fetched")
            DispatchQueue.main.async {
                self.games = games
            }
        }catch let error as AppError{
            DispatchQueue.main.async {
                self.appError = error
                self.showAlert = true
            }
        }catch {
            DispatchQueue.main.async {
                self.appError = AppError(title: "An error occured.", message: error.localizedDescription)
                self.showAlert = true
            }
        }
    }
    
    func getGame(game: Game) async -> GameDetail?{
        do{
            guard let accessToken = accessToken else{
                throw AppError(title: "Authentication Failed", message: "Please try logging in again")
            }
            let game: GameDetail = try await api.get(accessToken: accessToken, endpoint: APIEndpoint.gameId(id: game.id, userId: game.userId).description)
            return game
        }catch let error as AppError{
            DispatchQueue.main.async {
                self.appError = error
                self.showAlert = true
            }
        }catch {
            DispatchQueue.main.async {
                self.appError = AppError(title: "An error occured.", message: error.localizedDescription)
                self.showAlert = true
            }
        }
        return nil
    }
    
    func addGame(game: NewGame, uiImage: UIImage) async throws{
        guard let imageData = lib.getCompressedImage(image: uiImage, quality: 256) else {
            throw AppError(title: "Data Error", message: "Given data not in correct format")
        }
        guard let accessToken = accessToken else{
            throw AppError(title: "Authentication Failed", message: "Please try logging in again")
        }
        let gameData = try! JSONEncoder().encode(game)
        
        let gameResp: Game = try await api.post(imageData: imageData, data: gameData, endpoint: APIEndpoint.gameCreate.description, accessToken: accessToken)
        DispatchQueue.main.async {
            self.myGames?.insert(gameResp, at: 0)
        }
    }
    
    func updateGame(game: GameDetail, uiImage: UIImage?) async{
        do{
            try validateGame(game: game)
            var imageData: Data? = nil
            if let image = uiImage{ imageData = lib.getCompressedImage(image: image, quality: 256)}
            let gameData = try! JSONEncoder().encode(game)
            
            guard let accessToken = accessToken else{
                throw AppError(title: "Authentication Failed", message: "Please try logging in again")
            }
            
            let _:GameDetail = try await api.put(imageData: imageData, data: gameData, endpoint: APIEndpoint.gameId(id: game.id, userId: game.userId).description, accessToken: accessToken)
        }catch let error as AppError{
            DispatchQueue.main.async {
                self.appError = error
                self.showAlert = true
            }
        }catch {
            DispatchQueue.main.async {
                self.appError = AppError(title: "An error occured.", message: error.localizedDescription)
                self.showAlert = true
            }
        }
    }
    private func validateGame(game: GameDetail) throws {
        // Validate game name
        if game.name.trimmingCharacters(in: .whitespaces).isEmpty {
            throw AppError(title: "Invalid Name", message: "Please enter a valid game name.")
        }

        // Validate game description
        if game.description.trimmingCharacters(in: .whitespaces).isEmpty {
            throw AppError(title: "Invalid Description", message: "Please enter a valid game description.")
        }

        // Validate game address
        if game.address.trimmingCharacters(in: .whitespaces).isEmpty {
            throw AppError(title: "Invalid Address", message: "Please enter a valid game address.")
        }

        // Validate game country
        if game.country.trimmingCharacters(in: .whitespaces).isEmpty {
            throw AppError(title: "Invalid Country", message: "Please enter a valid game country.")
        }

        // Validate game coordinate
        if game.coordinate.latitude == 0 && game.coordinate.longitude == 0 {
            throw AppError(title: "Invalid Location", message: "Please select a valid game location.")
        }
    }
    
    func dateFormatter(dat: String) -> String{
        let dateFormatterCS = DateFormatter()
        dateFormatterCS.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let dateFormatterSwift = DateFormatter()
        dateFormatterSwift.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM d, h:mm a"
        
        if let date = dateFormatterCS.date(from: dat) {
            return dateFormatterPrint.string(from: date)
        }
        else if let date = dateFormatterSwift.date(from: dat) {
            return dateFormatterPrint.string(from: date)
        }else {
            return "There was an error decoding the string"
        }
    }
}

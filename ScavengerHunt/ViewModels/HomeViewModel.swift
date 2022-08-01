//
//  HomeViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-17.
//

import Foundation
import UIKit

class HomeViewModel: ObservableObject{
    @Published var user: User? = nil
    @Published var scoreLog: ScoreLog? = nil
    @Published var leaderBoard = [User]()
    @Published var gotd: Game? = nil
    @Published var popularGames = [Game]()
    @Published var myGames: [Game]? = nil
    @Published var profileImage: UIImage? = nil
    @Published var appError: AppError? = nil
    private var api: ApiService = ApiService()
    private var lib: FunctionsLibrary = FunctionsLibrary()
    
    func getUser() async{
        do{
            guard let accessToken = try await lib.getAccessToken() else{
                return
            }
            let account: User = try await api.get(accessToken: accessToken, endpoint: .home)
            DispatchQueue.main.async {
                self.user = account
            }
            print("account fetched")
        }
        catch ErrorType.error(let error){
            DispatchQueue.main.async {
                self.appError = error.appError
            }
        }
        catch{
            DispatchQueue.main.async {
                self.appError = AppError(title: "Account Fetch Failed", message: error.localizedDescription)
            }
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
    
    func getScoreLog() async{
        do{
            guard let accessToken = try await lib.getAccessToken() else{
                return
            }
            let scoreLog: ScoreLog = try await api.get(accessToken: accessToken, endpoint: .scoreLog)
            DispatchQueue.main.async {
                self.scoreLog = scoreLog
            }
            print("account fetched")
        }
        catch ErrorType.error(let error){
            DispatchQueue.main.async {
                self.appError = error.appError
            }
        }
        catch{
            DispatchQueue.main.async {
                self.appError = AppError(title: "Account Fetch Failed", message: error.localizedDescription)
            }
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
    
    func getLeaderboard() async{
        do{
            let users: [User] = try await api.get(endpoint: .leaderboard)
            DispatchQueue.main.async {
                self.leaderBoard = users
            }
            print("leaderboard fetched")
        }
        catch ErrorType.error(let error){
            DispatchQueue.main.async {
                self.appError = error.appError
            }
        }
        catch{
            DispatchQueue.main.async {
                self.appError = AppError(title: "Leaderboard Fetch Failed", message: error.localizedDescription)
            }
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
    
    func getPopularGames() async{
        do{
            let games: [Game] = try await api.get(endpoint: .popularGames)
            DispatchQueue.main.async {
                self.popularGames = games
            }
            print("Popular games fetched")
        }
        catch ErrorType.error(let error){
            DispatchQueue.main.async {
                self.appError = error.appError
            }
        }
        catch{
            DispatchQueue.main.async {
                self.appError = AppError(title: "Fetch Failed", message: error.localizedDescription)
            }
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
    
    func setProfileImage() async{
        do{
            guard let accessToken = try await lib.getAccessToken(), let image = profileImage else {
                return
            }
            guard let compressedImage = lib.getCompressedImage(image: image) else {
                return
            }
            
            let data = ImageRequest(imageFile: compressedImage, fileName: "something.jpeg")
            
            let response = try await api.uploadImage(endpoint: .uploadProfile, request: data, accessToken: accessToken)
            print(response)
        }
        catch ErrorType.error(let errorDes){
            DispatchQueue.main.async {
                self.appError = errorDes.appError
            }
            print("Request failed with error: \(errorDes)")
        }
        catch{
            DispatchQueue.main.async {
                self.appError = AppError(title: "Something went wrong", message: error.localizedDescription)
            }
            print("Request failed with error: \(error.localizedDescription)")
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

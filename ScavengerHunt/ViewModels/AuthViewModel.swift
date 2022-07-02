//
//  AuthViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-19.
//

import Foundation
import UIKit

class AuthViewModel: ObservableObject{
    @Published var isAuthenticated = false
    @Published var showLogin = false
    @Published var user: User? = nil
    @Published var profileImage: UIImage? = nil
    private var api: ApiService = ApiService()
    private var lib: FunctionsLibrary = FunctionsLibrary()
    
    func login(email ema: String, password pas: String)async{
        
        do{
            let defaults = UserDefaults.standard
            let body = try JSONEncoder().encode(LoginRequest(email: ema, password: pas))
            
            let tokenObj: TokenObject = try await api.post(body: body, endpoint: .login)
            defaults.set(tokenObj.refreshToken, forKey: "refreshToken")
            defaults.set(tokenObj.accessToken, forKey: "accessToken")
            defaults.set(Date().addingTimeInterval(24 * 60 * 60), forKey: "tokenExpiry")
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.showLogin = false
            }
            print("Logged in")
        }
        catch NetworkError.custom(let error){
            print("Request failed with error: \(error)")
        }
        catch{
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
    
    func getAccount() async{
        do{
            let defaults = UserDefaults.standard
            if(await refreshToken() == false){
                throw NetworkError.custom(error: "Token Refresh error")
            }
            
            guard let accessToken = defaults.string(forKey: "accessToken") else {
                return
            }
            
            let account: User = try await api.get(accessToken: accessToken, endpoint: .home)
            DispatchQueue.main.async {
                self.user = account
            }
            print("account fetched")
        }
        catch NetworkError.custom(let errorDes){
            print("Request failed with error: \(errorDes)")
        }
        catch{
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
    
    func setProfileImage() async{
        do{
            let defaults = UserDefaults.standard
            if(await refreshToken() == false){
                throw NetworkError.custom(error: "Token Refresh error")
            }
            
            guard let accessToken = defaults.string(forKey: "accessToken"), let image = profileImage else {
                return
            }
            guard let compressedImage = lib.getCompressedImage(image: image) else {
                return
            }
            
            let data = ImageRequest(imageFile: compressedImage, fileName: "something.jpeg")
            
            let response = try await api.uploadImage(endpoint: .uploadProfile, request: data, accessToken: accessToken)
            print(response)
        }
        catch NetworkError.custom(let errorDes){
            print("Request failed with error: \(errorDes)")
        }
        catch{
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
    
    public func refreshToken() async -> Bool{
        let defaults = UserDefaults.standard
        
        guard let expiry = defaults.object(forKey: "tokenExpiry"), let accessToken = defaults.string(forKey: "accessToken"), let refreshToken = defaults.string(forKey: "refreshToken") else {
            print("Request failed with error: User not Logged In")
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.showLogin = true
            }
            return false
        }
        
        let expiryToken = expiry as! Date
        
        if(Date.now > expiryToken){
            
            do{
                let body = try JSONEncoder().encode(TokenObject(accessToken: accessToken, refreshToken: refreshToken))
                
                let tokenObj: TokenObject = try await api.post(body: body, endpoint: .refreshToken)
                
                defaults.set(tokenObj.refreshToken, forKey: "refreshToken")
                defaults.set(tokenObj.accessToken, forKey: "accessToken")
                defaults.set(Date().addingTimeInterval(15 * 60), forKey: "tokenExpiry")
                print("token refreshed")
                return true
            }
            catch NetworkError.custom(let errorDes){
                print("Request failed with error: \(errorDes)")
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    self.showLogin = true
                }
                return false
            }
            catch{
                print("Request failed with error: \(error)")
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    self.showLogin = true
                }
                return false
            }
        }
        print("token is already valid")
        return true
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

//
//  LoginViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-18.
//

import Foundation

class LoginViewModel: ObservableObject{
    @Published var isAuthenticated = false
    @Published var showLogin = false
    @Published var appError: AppError? = nil
    private var api: ApiService = ApiService()
    
    func initLogin() async{
        do{
            try await refreshToken()
        }
        catch ErrorType.error(let error){
            DispatchQueue.main.async {
                self.appError = error.appError
            }
        }
        catch{
            DispatchQueue.main.async {
                self.appError = AppError(title: "Login Failed", message: error.localizedDescription)
            }
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
    
    func login(email ema: String, password pas: String)async{
        
        do{
            let defaults = UserDefaults.standard
            let body = try JSONEncoder().encode(LoginRequest(email: ema, password: pas))
            
            let tokenObj: TokenObject = try await api.post(body: body, endpoint: .login)
            defaults.set(tokenObj.refreshToken, forKey: "refreshToken")
            defaults.set(tokenObj.accessToken, forKey: "accessToken")
            defaults.set(Date().addingTimeInterval(24 * 60 * 60), forKey: "tokenExpiry")
            DispatchQueue.main.async {
                self.isAuthenticated.toggle()
            }
            print("Logged in")
        }
        catch ErrorType.error(let error){
            DispatchQueue.main.async {
                self.appError = error.appError
            }
        }
        catch{
            DispatchQueue.main.async {
                self.appError = AppError(title: "Login Failed", message: error.localizedDescription)
            }
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
    
    public func refreshToken() async throws{
        let defaults = UserDefaults.standard
        
        guard let expiry = defaults.object(forKey: "tokenExpiry"), let accessToken = defaults.string(forKey: "accessToken"), let refreshToken = defaults.string(forKey: "refreshToken") else {
            print("Request failed with error: User not Logged In")
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
            throw ErrorType.error(.loginError)
        }
        
        let expiryToken = expiry as! Date
        
        if(Date.now > expiryToken){
            let defaults = UserDefaults.standard
            
            guard let body = try? JSONEncoder().encode(TokenObject(accessToken: accessToken, refreshToken: refreshToken)) else{
                throw ErrorType.error(.processingError)
            }
            
            let tokenObj: TokenObject = try await ApiService().post(body: body, endpoint: .refreshToken)
            
            defaults.set(tokenObj.refreshToken, forKey: "refreshToken")
            defaults.set(tokenObj.accessToken, forKey: "accessToken")
            defaults.set(Date().addingTimeInterval(15 * 60), forKey: "tokenExpiry")
            print("token refreshed")
            return
        }
        
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
        print("token is already valid")
    }
}

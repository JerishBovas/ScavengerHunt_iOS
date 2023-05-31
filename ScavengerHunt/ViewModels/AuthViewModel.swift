//
//  LoginViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-18.
//

import SwiftUI
import AuthenticationServices

class AuthViewModel: ObservableObject{
    @Published var isAuthenticated = false
    @Published var showAlert: Bool = false
    @Published var appError: AppError?
    var accessToken: String = ""
    private var refreshToken: String = ""
    private var tokenExpiry: Date? = nil
    
    private var api: ApiService = ApiService()
    
    init() {
        let defauls = UserDefaults.standard
        self.isAuthenticated = defauls.bool(forKey: "isAuthenticated")
        if let accessToken  = defauls.string(forKey: "accessToken"),
              let refreshToken = defauls.string(forKey: "refreshToken"),
              let tokenExpiry = defauls.object(forKey: "tokenExpiry") {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.tokenExpiry = tokenExpiry as? Date
        }
    }
    
    func signUp(name: String, email: String, password: String) async {
        do{
            let defaults = UserDefaults.standard
            var expiry: Date
            let body = try JSONEncoder().encode(SignUpRequest(name: name, email: email, password: password))
            
            let tokenObj:TokenObject = try await ApiService().post(body: body, endpoint: APIEndpoint.register.description)
            defaults.set(tokenObj.refreshToken, forKey: "refreshToken")
            defaults.set(tokenObj.accessToken, forKey: "accessToken")
            expiry = Date().addingTimeInterval(24 * 60 * 60)
            defaults.set(expiry, forKey: "tokenExpiry")
            defaults.set(true, forKey: "isAuthenticated")
            
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
            self.accessToken = tokenObj.accessToken
            self.refreshToken = tokenObj.refreshToken
            self.tokenExpiry = expiry
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
    
    func login(email ema: String, password pas: String) async {
        do{
            var expiry: Date
            let defaults = UserDefaults.standard
            let body = try JSONEncoder().encode(LoginRequest(email: ema, password: pas))
            
            guard let tokenObj: TokenObject = try await api.post(body: body, endpoint: APIEndpoint.login.description) else {
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                }
                throw AppError(title: "Log-In Error", message: "Please Login Again")
            }
            
            defaults.set(tokenObj.refreshToken, forKey: "refreshToken")
            defaults.set(tokenObj.accessToken, forKey: "accessToken")
            expiry = Date().addingTimeInterval(24 * 60 * 60)
            defaults.set(expiry, forKey: "tokenExpiry")
            defaults.set(true, forKey: "isAuthenticated")
            
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
            self.accessToken = tokenObj.accessToken
            self.refreshToken = tokenObj.refreshToken
            self.tokenExpiry = expiry
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
    
    public func refreshToken() async throws{
        do{
            let defaults = UserDefaults.standard
            var expiry: Date
            
            let body = try JSONEncoder().encode(TokenObject(accessToken: accessToken, refreshToken: refreshToken))
            
            guard let tokenObj: TokenObject = try? await ApiService().post(body: body, endpoint: APIEndpoint.refreshToken.description) else{
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                }
                throw AppError(title: "Log-In Error", message: "Please Login Again")
            }
            
            defaults.set(tokenObj.refreshToken, forKey: "refreshToken")
            defaults.set(tokenObj.accessToken, forKey: "accessToken")
            expiry = Date().addingTimeInterval(24 * 60 * 60)
            defaults.set(expiry, forKey: "tokenExpiry")
            defaults.set(true, forKey: "isAuthenticated")
            
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
            self.accessToken = tokenObj.accessToken
            self.refreshToken = tokenObj.refreshToken
            self.tokenExpiry = expiry
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
}

class SignInWithAppleViewModel: NSObject, ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
      case let appleIdCredential as ASAuthorizationAppleIDCredential:
        if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
          // Apple has autherized the use with Apple ID and password
          registerNewUser(credential: appleIdCredential)
        } else {
          // User has been already exist with Apple Identity Provider
          signInExistingUser(credential: appleIdCredential)
        }
        break
        
      case let passwordCredential as ASPasswordCredential:
        print("\n ** ASPasswordCredential ** \n")
        signinWithUserNamePassword(credential: passwordCredential)
        break
        
      default:
        break
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    print("\n -- ASAuthorizationControllerDelegate -\(#function) -- \n")
    print(error)
    // Give Call Back to UI
  }
}

extension SignInWithAppleViewModel {
  private func registerNewUser(credential: ASAuthorizationAppleIDCredential) {
    // API Call - Pass the email, user full name, user identity provided by Apple and other details.
    // Give Call Back to UI
  }
  
  private func signInExistingUser(credential: ASAuthorizationAppleIDCredential) {
    // API Call - Pass the user identity, authorizationCode and identity token
    // Give Call Back to UI
  }
  
  private func signinWithUserNamePassword(credential: ASPasswordCredential) {
    // API Call - Sign in with Username and password
    // Give Call Back to UI
  }
}

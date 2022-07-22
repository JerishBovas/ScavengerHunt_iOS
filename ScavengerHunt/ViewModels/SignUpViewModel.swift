//
//  SignUpViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-18.
//

import Foundation
import Combine
import SwiftUI

class SignUpViewModel: ObservableObject {
    @EnvironmentObject private var loginVM: LoginViewModel
    @Published var appError: AppError? = nil
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    @Published var isNameCriteriaValid = false
    @Published var isEmailCriteriaValid = false
    @Published var isPasswordCriteriaValid = false
    @Published var showErrors = false
    @Published var canSubmit = false
    private var cancellableSet: Set<AnyCancellable> = []
    
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])")
    let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[^a-zA-Z]).{8,}")
    
    init() {
        $name
            .map{name in
                return !name.isEmpty
            }
            .assign(to: \.isNameCriteriaValid, on: self)
            .store(in: &cancellableSet)
        $email
            .map { email in
                return self.emailPredicate.evaluate(with: email)
            }
            .assign(to: \.isEmailCriteriaValid, on: self)
            .store(in: &cancellableSet)
        
        $password
            .map { password in
                return self.passwordPredicate.evaluate(with: password)
            }
            .assign(to: \.isPasswordCriteriaValid, on: self)
            .store(in: &cancellableSet)
        
        Publishers.CombineLatest3($isNameCriteriaValid, $isEmailCriteriaValid, $isPasswordCriteriaValid)
            .map { isNameCriteriaValid, isEmailCriteriaValid, isPasswordCriteriaValid in
                return (isNameCriteriaValid && isEmailCriteriaValid && isPasswordCriteriaValid)
            }
            .assign(to: \.canSubmit, on: self)
            .store(in: &cancellableSet)
    }
    
    var namePrompt: String{
        isNameCriteriaValid ?
        "" : "Name should not be Empty"
    }
    
    var emailPrompt: String {
        isEmailCriteriaValid ?
            ""
            :
            "Enter a valid email address"
    }
    
    
    
    var passwordPrompt: String {
        isPasswordCriteriaValid ?
            ""
            :
            "Must be at least 8 characters containing at least one upper, one lower and one number."
    }
    
    func signUp() async{
        let defaults = UserDefaults.standard
        do{
            let body = try JSONEncoder().encode(SignUpRequest(name: name, email: email, password: password))
            
            let tokenObj:TokenObject = try await ApiService().post(body: body, endpoint: .register)
            defaults.set(tokenObj.refreshToken, forKey: "refreshToken")
            defaults.set(tokenObj.accessToken, forKey: "accessToken")
            defaults.set(Date().addingTimeInterval(24 * 60 * 60), forKey: "tokenExpiry")
            DispatchQueue.main.async {
                self.loginVM.isAuthenticated = true
                self.loginVM.showLogin = false
            }
        }
        catch ErrorType.error(let error){
            DispatchQueue.main.async {
                self.appError = error.appError
            }
        }
        catch{
            DispatchQueue.main.async {
                self.appError = AppError(title: "Sign Up Failed", message: error.localizedDescription)
            }
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
}

//
//  AccountViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-05-29.
//

import Foundation
import UIKit
import SwiftUI

class ProfileViewModel: ObservableObject{
    private var accessToken: String?
    private var api: ApiService
    private var imgPro: ImageProcessor
    @Published var user: User?
    @Published var profileImage: UIImage?
    @Published var showAlert: Bool = false
    @Published var appError: AppError?
    
    init(){
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken")
        api = ApiService()
        imgPro = ImageProcessor()
        if let data = UserDefaults.standard.data(forKey: "user"),
           let use = try? JSONDecoder().decode(User.self, from: data){
            withAnimation {
                self.user = use
            }
        }
    }
    
    func fetchUser() async{
        if let accessToken = accessToken{
            async let fetchedUser: User? = try? await api.get(accessToken: accessToken, endpoint: APIEndpoint.user.description)
            let user = await fetchedUser
            DispatchQueue.main.async {
                if let user = user {
                    withAnimation(.default) {
                        self.user = user
                    }
                    if let encoded = try? JSONEncoder().encode(user) {
                        UserDefaults.standard.set(encoded, forKey: "user")
                    }
                }
            }
        }
    }
    
    func signOut(authVM: AuthViewModel){
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isAuthenticated")
        defaults.set("", forKey: "accessToken")
        defaults.set("", forKey: "refreshToken")
        authVM.accessToken = ""
        DispatchQueue.main.async {
            withAnimation {
                authVM.isAuthenticated = false
            }
        }
    }
    
    func changeName(name: String) async{
        do{
            guard let accessToken = accessToken else{return}
            if !name.isEmpty{
                let data = try JSONEncoder().encode(name)
                let user: User = try await api.put(accessToken: accessToken, body: data, endpoint: APIEndpoint.userNameUpdate.description)
                DispatchQueue.main.async {
                    withAnimation {
                        self.user = user
                    }
                }
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: "user")
                }
            }
        }
        catch let error as AppError{
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
    
    func setProfileImage() async{
        do{
            guard let image = profileImage,
                    let compressedImage = imgPro.getCompressedImage(image: image, quality: 256),
                    let accessToken = accessToken else {
                throw AppError(title: "Image Error", message: "Please provide a valid image.")
            }
            
            let response: User = try await api.put(imageData: compressedImage, data: nil, endpoint: APIEndpoint.userProfileImage.description, accessToken: accessToken)
            DispatchQueue.main.async {
                withAnimation {
                    self.user = response
                    self.profileImage = nil
                }
            }
            if let encoded = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encoded, forKey: "user")
            }
        }
        catch let error as AppError{
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

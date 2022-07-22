//
//  AuthViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-19.
//

import Foundation
import UIKit

class AuthViewModel: ObservableObject{
    private var loginVM: LoginViewModel = LoginViewModel()
    @Published var user: User? = nil
    @Published var profileImage: UIImage? = nil
    @Published var appError: AppError? = nil
    private var api: ApiService = ApiService()
    private var lib: FunctionsLibrary = FunctionsLibrary()
    
    func getAccount() async{
        do{
            let defaults = UserDefaults.standard
            try await loginVM.refreshToken()
            
            guard let accessToken = defaults.string(forKey: "accessToken") else {
                return
            }
            
            let account: User = try await api.get(accessToken: accessToken, endpoint: .home)
            DispatchQueue.main.async {
                self.user = account
            }
            print("account fetched")
        }
        catch ErrorType.error(let errorDes){
            appError = errorDes.appError
            print("Request failed with error: \(errorDes)")
        }
        catch{
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
    
    func setProfileImage() async{
        do{
            let defaults = UserDefaults.standard
            try await loginVM.refreshToken()
            
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

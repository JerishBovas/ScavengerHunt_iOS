//
//  AccountViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-05-29.
//

import Foundation
import UIKit

class ProfileViewModel: ObservableObject{
    private var accessToken: String?
    private var api: ApiService
    private var imgPro: ImageProcessor
    @Published var user: User
    @Published var profileImage: UIImage? = nil
    
    init(){
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken")
        api = ApiService()
        imgPro = ImageProcessor()
        if let data = UserDefaults.standard.data(forKey: "user"),
           let use = try? JSONDecoder().decode(User.self, from: data){
            self.user = use
        }
        else{
            user = DataService.user
        }
    }
    
    func setProfileImage() async throws{
        guard let image = profileImage else {
            throw AppError(title: "Image format Error", message: "Please verify that your image is in correct format.")
        }
        guard let compressedImage = imgPro.getCompressedImage(image: image, quality: 256) else {
            throw AppError(title: "Internal Error", message: "An error occured when processing the Image.")
        }
        guard let accessToken = accessToken else{
            throw AppError(title: "Authentication Failed", message: "Please try logging in again")
        }
        
        let data = ImageRequest(imageFile: compressedImage, fileName: "something.jpeg")
        
        let response = try await api.uploadImage(endpoint: APIEndpoint.userProfileImage.description, request: data, accessToken: accessToken)
        print(response)
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

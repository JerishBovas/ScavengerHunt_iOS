//
//  ObjectImageProcessingViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-05-17.
//

import Foundation
import UIKit

struct DetectedObjects: Codable{
    var tags: [DetectedObject]
}
struct DetectedObject: Codable{
    var name: String
    var confidence: Double
}

class ImageProcessor{
    private var VISION_KEY: String
    private var VISION_ENDPOINT: String
    private let apiService = ApiService()
    
    init(){
        self.VISION_KEY = ProcessInfo.processInfo.environment["VISION_KEY"] ?? ""
        self.VISION_ENDPOINT = ProcessInfo.processInfo.environment["VISION_ENDPOINT"] ?? ""
    }
    
    public func removeBackground(image: UIImage) async throws-> UIImage{
        let endpoint = "https://\(VISION_ENDPOINT)/computervision/imageanalysis:segment?api-version=2023-02-01-preview&mode=backgroundRemoval"
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(VISION_KEY, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpBody = image.jpegData(compressionQuality: 1.0)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print(response)
        return UIImage(data: data)!
    }
    
    public func detectObjects(imageData: UIImage) async throws -> DetectedObjects{
        let requestURL = URL(string: "https://\(VISION_ENDPOINT)/vision/v3.2/analyze?visualFeatures=Tags")!
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(VISION_KEY, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpBody = imageData.jpegData(compressionQuality: 1.0)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print(String(data: data, encoding: .utf8) ?? "")
        guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode < 300  else  {
            print(response)
            let error = try JSONDecoder().decode(ErrorObject.self, from: data)
            throw AppError(title: error.title, message: error.errors.joined(separator: "\n"))
        }
        
        let result = try JSONDecoder().decode(DetectedObjects.self, from: data)
        return result
    }
    
    public func getCompressedImage(image: UIImage, quality: Int) -> Data?{
        guard var correctImage = image.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        let count = correctImage.count / 1024
        if(count > quality){
            let longQuality = Double(quality) / Double(count)
            let quality = Double(floor(100 * longQuality)/100)
            print(quality)
            
            if let newImage = image.jpegData(compressionQuality: CGFloat(quality)){
                correctImage = newImage
            }
        }
        
        return correctImage
    }
    public func cropImageToSquare(image: UIImage) -> UIImage? {
        var imageHeight = image.size.height
        var imageWidth = image.size.width

        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }

        let size = CGSize(width: imageWidth, height: imageHeight)

        let refWidth : CGFloat = CGFloat(image.cgImage!.width)
        let refHeight : CGFloat = CGFloat(image.cgImage!.height)

        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2

        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        if let imageRef = image.cgImage!.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
        }

        return nil
    }
}

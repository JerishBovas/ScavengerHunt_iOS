//
//  AddItemsViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-05-24.
//

import SwiftUI
import AVFoundation

class AddItemsViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    private var accessToken: String?
    @Published var image: UIImage?
    @Published var croppedImage: UIImage?
    @Published var detectedTags: [String]?
    @Published var showAlert: Bool = false
    @Published var appError: AppError?
    let session = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    private var imageProcessor = ImageProcessor()
    
    override init() {
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken")
    }
    
    func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
                guard let device = AVCaptureDevice.default(for: .video) else {
                    return
                }
                
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    self.session.addInput(input)
                    
                    self.photoOutput = AVCapturePhotoOutput()
                    if let photoOutput = self.photoOutput {
                        self.session.addOutput(photoOutput)
                    }
                } catch {
                    print("Error setting up camera: \(error.localizedDescription)")
                }
                
                self.session.startRunning()
            }
    }
    
    func captureImage() {
        guard let photoOutput = photoOutput else {
            return
        }
        
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Process the captured image data
            processImage(imageData)
        }
    }
    
    private func processImage(_ imageData: Data) {
        guard let img = UIImage(data: imageData), let sqrImg = imageProcessor.cropImageToSquare(image: img), let compressImg = imageProcessor.getCompressedImage(image: sqrImg, quality: 256) else {return}
        image = UIImage(data: compressImg)
    }
    
    func addItem(gameId: String, name: String) async{
        do{
            guard let image = croppedImage, let imageData = image.jpegData(compressionQuality: 1.0) else {
                throw AppError(title: "Data Error", message: "Given data not in correct format")
            }
            
            let data = try! JSONEncoder().encode(Item(name: name))
            
            guard let accessT = accessToken else {
                throw AppError(title: "Authentication Error", message: "Please login in again")
            }
            let itemResp: Item = try await ApiService().post(imageData: imageData, data: data, endpoint: APIEndpoint.item(gameId: gameId).description, accessToken: accessT)
            DispatchQueue.main.async {
                self.appError = AppError(title: "Item Added", message: "Item added successfully.\nName: \(itemResp.name)")
                self.showAlert = true
                self.image = nil
                self.croppedImage = nil
                self.detectedTags = nil
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
    
    func removeBackground() async{
        do{
            let imgData = try await imageProcessor.removeBackground(image: image!)
            DispatchQueue.main.async {
                self.croppedImage = imgData
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
    
    func analyzeImage() async{
        do{
            let detectedObjects = try await imageProcessor.detectObjects(imageData: croppedImage!)
            let shrunkObjects = Array(detectedObjects.tags.prefix(5))
            let shrunkNames = shrunkObjects.map{$0.name.capitalized}
            let updatedTags = [""] + shrunkNames
            DispatchQueue.main.async {
                self.detectedTags = updatedTags
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
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let cameraView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(previewLayer)
        
        return cameraView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

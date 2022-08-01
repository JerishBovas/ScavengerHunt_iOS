//
//  BasicViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-28.
//

import Foundation
import SwiftUI

class FunctionsLibrary{
    private var loginVM: LoginViewModel = LoginViewModel()
    
    public func setFirstTime(_ val: Bool){
        UserDefaults.standard.set(val, forKey: "firstTime")
    }
    
    public func getCompressedImage(image: UIImage) -> Data?{
        guard var correctImage = image.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        let count = correctImage.count / 1024
        if(count > 256){
            let longQuality = Double(256) / Double(count)
            let quality = Double(floor(100 * longQuality)/100)
            print(quality)
            
            if let newImage = image.jpegData(compressionQuality: CGFloat(quality)){
                correctImage = newImage
            }
        }
        
        return correctImage
    }
    
    public func getAccessToken()async throws -> String?{
        let defaults = UserDefaults.standard
        try await loginVM.refreshToken()
        
        guard let accessToken = defaults.string(forKey: "accessToken") else {
            return nil
        }
        return accessToken
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        controller.modalPresentationStyle = .popover
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}

struct CaptureImageView {

    @Binding var isShown: Bool
    @Binding var image: UIImage?
    @Binding var sourceType: UIImagePickerController.SourceType
        
    func makeCoordinator() -> Coordinator {
      return Coordinator(isShown: $isShown, image: $image)
    }
}

extension CaptureImageView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImageView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<CaptureImageView>) {
        
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var isCoordinatorShown: Bool
    @Binding var imageInCoordinator: UIImage?
    
    init(isShown: Binding<Bool>, image: Binding<UIImage?>) {
        _isCoordinatorShown = isShown
        _imageInCoordinator = image
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageInCoordinator = unwrapImage
        isCoordinatorShown = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isCoordinatorShown = false
    }
}

//
//  ProfileView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-28.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State var searchString: String = ""
    @State private var showImagePicker: Bool = false
    @State var isUploadingImage: Bool = false
    @State var picker: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        NavigationView {
            if(authVM.isAuthenticated){
                VStack{
                    Text(authVM.user?.name ?? "Name")
                    if(authVM.profileImage != nil){
                        ZStack{
                            Image(uiImage: authVM.profileImage!)
                                .resizable()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                            Button {
                                showImagePicker.toggle()
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 40, weight: .black))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 200, maxHeight: 200, alignment: .topTrailing)
                            }

                        }
                        Button {
                            isUploadingImage = true
                            Task{
                                await authVM.setProfileImage()
                                isUploadingImage = false
                            }
                        } label: {
                            HStack(spacing: 10){
                                if(isUploadingImage){
                                    Text("Uploading Image")
                                        .font(.headline)
                                    ProgressView()
                                        .font(.headline)
                                        .tint(.white)
                                }else{
                                    Text("Upload Image")
                                        .font(.headline)
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .pickerStyle(.wheel)

                    }
                    else{
                        HStack{
                            Button {
                                picker = .photoLibrary
                                showImagePicker.toggle()
                            } label: {
                                Text("Choose Image")
                            }
                            .buttonStyle(.bordered)
                            Button {
                                picker = .camera
                                showImagePicker.toggle()
                            } label: {
                                Text("Take Picture")
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                }
                .sheet(isPresented: $showImagePicker) {
                    CaptureImageView(isShown: $showImagePicker, image: $authVM.profileImage, sourceType: $picker)
                        .ignoresSafeArea()
                }
                .navigationTitle("Settings")
                .searchable(text: $searchString)
                .onAppear {
                    Task{
                        if authVM.user == nil {
                            await authVM.getAccount()
                        }
                    }
                }
            }
            else{
                Button {
                    authVM.showLogin = true
                } label: {
                    Text("Login")
                }
                .buttonStyle(BorderedButtonStyle())
                .navigationTitle("Settings")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}

extension SettingsView{
    
}

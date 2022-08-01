//
//  ProfileView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-28.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var loginVM: LoginViewModel
    @EnvironmentObject private var homeVM: HomeViewModel
    @State var searchString: String = ""
    @State private var showImagePicker: Bool = false
    @State var isUploadingImage: Bool = false
    @State var picker: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                if(loginVM.isAuthenticated){
                    VStack{
                        Text(homeVM.user?.name ?? "Name")
                        if(homeVM.profileImage != nil){
                            ZStack{
                                Image(uiImage: homeVM.profileImage!)
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
                                    await homeVM.setProfileImage()
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
                            Button {
                                loginVM.isAuthenticated = false
                            } label: {
                                Text("Log Out")
                            }
                            .buttonStyle(BorderedButtonStyle())
                            .navigationTitle("Settings")
                        }

                    }
                    .sheet(isPresented: $showImagePicker) {
                        CaptureImageView(isShown: $showImagePicker, image: $homeVM.profileImage, sourceType: $picker)
                            .ignoresSafeArea()
                    }
                    .searchable(text: $searchString)
                    .onAppear {
                        Task{
                            if homeVM.user == nil {
                                await homeVM.getUser()
                            }
                        }
                    }
                }
                else{
                    Button {
                        loginVM.isAuthenticated = false
                    } label: {
                        Text("Login")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(HomeViewModel())
            .environmentObject(LoginViewModel())
    }
}

extension SettingsView{
    
}

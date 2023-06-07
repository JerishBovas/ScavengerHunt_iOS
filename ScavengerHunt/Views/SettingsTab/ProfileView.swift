//
//  ProfileView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-05-29.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var vm: ProfileViewModel
    @State var user: User
    @State private var name = ""
    @State private var isEditingProfile = false
    @State private var showConfirmation = false
    @State private var showActionSheet = false
    @State private var isShowingImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            Form {
                Section{
                    HStack{
                        Spacer()
                        VStack(spacing: 5){
                            if let image = vm.profileImage{
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        showActionSheet = true
                                    }
                            }else{
                                ImageView(url: user.profileImage)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        showActionSheet = true
                                    }
                            }
                            Text(user.name)
                                .font(.title)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            Text(user.email)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .sheet(isPresented: $isShowingImagePicker) {
                        ImagePicker(selectedImage: $vm.profileImage, sourceType: imageSource)
                    }
                    .confirmationDialog("Edit Picture", isPresented: $showActionSheet) {
                        Button("Take a Picture") {
                            imageSource = .camera
                            isShowingImagePicker = true
                        }
                        Button("Choose from Photos") {
                            imageSource = .photoLibrary
                            isShowingImagePicker = true
                        }
                    }
                }
                .listRowBackground(Color.clear)
                Section(header: Text("Name")) {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .keyboardType(.default)
                        .submitLabel(.done)
                }
                .onAppear{
                    self.name = user.name
                }
                
                Section(header: Text("Security")) {
                    Text(user.email)
                    SecureField("Password", text: .constant("password12345678"))
                        .disabled(true)
//                    Button("Change Password") {
//                        
//                    }
                }
                
                Section(header: Text("Last Updated")) {
                    Text(vm.dateFormatter(dat: user.lastUpdated))
                }
                
                Section {
                    Button {
                        showConfirmation = true
                    } label: {
                        HStack{
                            Spacer()
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .alert(isPresented: $showConfirmation) {
                        Alert(title: Text("Sign Out"), message: Text("Are you sure you want to Sign Out?"), primaryButton: .destructive(Text("Sign Out")){
                            vm.signOut(authVM: authVM)
                        }, secondaryButton: .cancel())
                    }
                }
            }
            .toolbar{
                if name != user.name || vm.profileImage != nil{
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            isLoading = true
                            Task{
                                if name != user.name{
                                    await vm.changeName(name: name)
                                }
                                if vm.profileImage != nil{
                                    await vm.setProfileImage()
                                }
                                isLoading = false
                            }
                        } label: {
                            if isLoading == true{
                                ProgressView()
                            }else{
                                Text("Save")
                            }
                        }

                    }
                }
                else{
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User())
    }
}


//
//  ProfileView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-05-29.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section{
                    HStack{
                        Spacer()
                        VStack(spacing: 5){
                            ImageView(url: vm.user.profileImage)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            Text(vm.user.name)
                                .font(.title)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            Text(vm.user.email)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                Section(header: Text("Account Info")) {
                    TextField("Name", text: $vm.user.name)
                        .disabled(true)
                    TextField("Email", text: $vm.user.email)
                        .disabled(true)
                    Button("Edit Profile") {
                        
                    }
                }
                
                Section(header: Text("Password")) {
                        SecureField("Password", text: .constant("password"))
                        .disabled(true)
                    Button("Change Password") {
                        
                    }
                }
                
                Section(header: Text("Last Updated")) {
                    Text(vm.dateFormatter(dat: vm.user.lastUpdated))
                }
                
                Section {
                    Button {
                        
                    } label: {
                        HStack{
                            Spacer()
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }

                }
            }
            .toolbar{
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveChanges() {
        // Perform the logic to save changes to the user's account
        // For example, send an API request to update the user's data
        
        // After saving changes, you can perform any additional actions if needed
        // such as showing a success message or navigating to another screen
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}


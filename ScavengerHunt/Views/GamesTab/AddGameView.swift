//
//  AddGameView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-06.
//

import SwiftUI
import MapKit
import CoreLocation

struct AddGameView: View {
    var onSubmit: (NewGame, UIImage) async throws -> Void
    @State var game: NewGame = NewGame()
    @State private var uiImage: UIImage?
    @StateObject private var completer = MapSearchCompleter()
    @Environment(\.dismiss) var dismiss
    @State private var tag: String = ""
    @State var showAlert: Bool = false
    @State var appError: AppError?
    @State private var isShowingImagePicker = false
    @FocusState private var isNameFocused: Bool
    @FocusState private var isDescriptionFocused: Bool
    @FocusState private var isAddressFocused: Bool
    @FocusState private var isTagsFocused: Bool
    @State private var isAdding: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $game.name)
                        .focused($isNameFocused)
                        .submitLabel(.next)
                        .onSubmit {
                            isDescriptionFocused = true
                        }
                    TextField("Description", text: $game.description, axis: .vertical)
                        .focused($isDescriptionFocused)
                        .submitLabel(.done)
                        .onChange(of: game.description) { newValue in
                            if let last = newValue.last, last == "\n" {
                                game.description.removeLast()
                                isDescriptionFocused = false
                            }
                        }
                }
                
                Section("Location") {
                    if let _ = completer.place {
                        TextField("Address", text: $game.address, axis: .vertical)
                            .focused($isAddressFocused)
                            .submitLabel(.done)
                            .onChange(of: game.address) { newValue in
                                if let last = newValue.last, last == "\n" {
                                    game.address.removeLast()
                                    isAddressFocused = false
                                }
                            }
                        TextField("Country", text: $game.country)
                            .disabled(true)
                        NavigationLink("Change Location", value: game)
                            .foregroundColor(.accentColor)
                    }
                    else{
                        NavigationLink("Select Location", value: game)
                            .foregroundColor(.accentColor)
                    }
                }
                
                Section("Icon") {
                    HStack {
                        if let image = uiImage {
                            Button {
                                isShowingImagePicker = true
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxHeight: 230)
                                    .cornerRadius(8, corners: .allCorners)
                                    .padding(.vertical, 10)
                            }
                        } else {
                            Button("Select Image") {
                                isShowingImagePicker = true
                            }
                        }
                    }
                    .sheet(isPresented: $isShowingImagePicker) {
                        ImagePicker(selectedImage: $uiImage, sourceType: .photoLibrary)
                    }
                }
                
                Section(content:{
                    Toggle("Keep the Game Private", isOn: $game.isPrivate)
                }, header: {
                    Text("Visibility")
                }, footer: {
                    if(game.isPrivate){
                        Text("Private mode ON")
                    }
                    else{
                        Text("Private mode OFF")
                    }
                })
                
                Section(header: Text("Tags")) {
                    TextField("Add Tag", text: $tag)
                        .focused($isTagsFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            let newTag = tag.trimmingCharacters(in: .whitespaces)
                            if !newTag.isEmpty{
                                game.tags.append(newTag)
                            }
                            tag = ""
                        }
                    
                    ForEach(game.tags, id: \.self) { tag in
                        Text(tag)
                    }
                    .onDelete { offsets in
                        game.tags.remove(atOffsets: offsets)
                    }
                }
            }
            .navigationDestination(for: NewGame.self) { newGame in
                MapView(newGame: newGame, completer: completer)
                    .onDisappear{
                        if let place = completer.place{
                            game.name = place.name ?? ""
                            game.address = "\(place.subThoroughfare == nil ? "" : place.subThoroughfare! + " ")\(place.thoroughfare == nil ? place.subLocality! + ", " : place.thoroughfare! + ", ")\(place.locality == nil ? "" : place.locality! + ", ")\(place.administrativeArea ?? "") \(place.postalCode ?? "")"
                            game.country = place.country ?? ""
                            game.coordinate = Coordinate(latitude: place.location?.coordinate.latitude ?? 0, longitude: place.location?.coordinate.longitude ?? 0)
                        }
                    }
            }
            .alert(appError?.title ?? "", isPresented: $showAlert) {
                Text("OK")
            } message: {
                Text(appError?.message ?? "")
            }
            .navigationTitle("Add Game")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        isAdding = true
                        Task{
                            do{
                                try validateGame()
                                try await onSubmit(game, uiImage!)
                            }catch let error as AppError{
                                DispatchQueue.main.async {
                                    self.appError = error
                                    self.showAlert = true
                                    self.isAdding = false
                                }
                            }catch {
                                DispatchQueue.main.async {
                                    self.appError = AppError(title: "An error occured.", message: error.localizedDescription)
                                    self.showAlert = true
                                    self.isAdding = false
                                }
                            }
                        }
                        dismiss()
                    }
                }
            }
        }
    }
    private func validateGame() throws {
            // Validate game name
            if game.name.trimmingCharacters(in: .whitespaces).isEmpty {
                throw AppError(title: "Invalid Name", message: "Please enter a valid game name.")
            }

            // Validate game description
            if game.description.trimmingCharacters(in: .whitespaces).isEmpty {
                throw AppError(title: "Invalid Description", message: "Please enter a valid game description.")
            }

            // Validate game address
            if game.address.trimmingCharacters(in: .whitespaces).isEmpty {
                throw AppError(title: "Invalid Address", message: "Please enter a valid game address.")
            }

            // Validate game country
            if game.country.trimmingCharacters(in: .whitespaces).isEmpty {
                throw AppError(title: "Invalid Country", message: "Please enter a valid game country.")
            }

            // Validate game coordinate
            if game.coordinate?.latitude == 0 && game.coordinate?.longitude == 0 {
                throw AppError(title: "Invalid Location", message: "Please select a valid game location.")
            }

            // Validate game icon
            if uiImage == nil {
                throw AppError(title: "Invalid Icon", message: "Please select an icon for the game.")
            }
        }
}


struct AddGameView_Previews: PreviewProvider {
    static var previews: some View {
        AddGameView(onSubmit: {_,_ in })
    }
}

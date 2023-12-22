//
//  EditGameView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-25.
//

import SwiftUI
import CoreLocation
import MapKit

struct EditGameView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: GameViewModel
    @State var game: Game
    @State private var uiImage: UIImage?
    @StateObject private var completer = MapSearchCompleter()
    @State private var tag: String = ""
    @State private var showAlert: Bool = false
    @State private var appError: AppError?
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
                        .onChange(of: game.description) { _, newValue in
                            if let last = newValue.last, last == "\n" {
                                game.description.removeLast()
                                isDescriptionFocused = false
                            }
                        }
                }
                
                Section("Location") {
                    TextField("Address", text: $game.address, axis: .vertical)
                        .focused($isAddressFocused)
                        .submitLabel(.done)
                        .onChange(of: game.address) { _, newValue in
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
                            Button {
                                isShowingImagePicker = true
                            } label: {
                                ImageView(url: game.imageName)
                                    .frame(maxHeight: 230)
                                    .cornerRadius(8, corners: .allCorners)
                                    .padding(.vertical, 10)
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
            .disabled(isAdding)
            .navigationDestination(for: Game.self) { newGame in
                MapView(newGame: NewGame(), completer: completer)
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
            .navigationTitle("Edit Game")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        isAdding = true
                        Task{
                            await vm.updateGame(game: game, uiImage: uiImage)
                            DispatchQueue.main.async {
                                dismiss()
                            }
                        }
                    },label:{
                        if isAdding{
                            ProgressView()
                        }else{
                            Text("Save")
                        }
                    })
                }
            }
        }
    }
}

struct EditGameView_Previews: PreviewProvider {
    static var previews: some View {
        EditGameView(game: Game())
    }
}

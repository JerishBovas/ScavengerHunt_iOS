//
//  AddItemsView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-05-17.
//

import SwiftUI
import AVFoundation

struct AddItemsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm: AddItemsViewModel = AddItemsViewModel()
    var game: GameDetail
    @State private var isFetching: Bool = false
    @State private var progressValue: Double = 0.0
    @State private var progressText: String = "Processing"
    @State private var isAdding: Bool = false
    @State private var selectedName: String = ""
    @State private var otherName: String = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if let image = vm.croppedImage{
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width)
            }
            else if let image = vm.image{
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width)
            }
            else{
                CameraPreviewView(session: vm.session)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            }
            Form{
                if let tags = vm.detectedTags{
                    Section("Name") {
                        Picker("Choose a Name", selection: $selectedName) {
                            ForEach(tags, id: \.self) { tag in
                                if tag.isEmpty {
                                    Text("Choose")
                                        .font(.headline)
                                } else {
                                    Text(tag)
                                        .tag(tag)
                                }
                            }
                        }
                        .pickerStyle(.menu)
                        .foregroundColor(.secondary)
                        TextField("Other Name", text: $otherName)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            footerSection
        }
        .alert(vm.appError?.title ?? "", isPresented: $vm.showAlert) {
            Text("OK")
        } message: {
            Text(vm.appError?.message ?? "")
        }
        .ignoresSafeArea()
        .onAppear {
            vm.setupCamera()
        }
    }
}

extension AddItemsView{
    private var footerSection: some View{
        HStack{
            if isAdding{
                HStack(spacing: 10){
                    Spacer()
                    Text("Adding")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    ProgressView()
                    Spacer()
                }
                .foregroundColor(.accentColor)
            }
            else if isFetching{
                VStack{
                    ProgressView(value: progressValue, total: 100, label: {HStack(spacing: 16){
                        Text(progressText)
                        ProgressView()
                    }}, currentValueLabel: {Text("\(Int(progressValue))%")})
                }
                .padding()
            }
            else if let _ = vm.image{
                HStack{
                    Button("Cancel"){
                        dismiss()
                    }
                    .foregroundColor(.red)
                    Spacer()
                    Button(action: {
                        vm.image = nil
                        vm.croppedImage = nil
                        vm.detectedTags = nil
                        selectedName = ""
                        otherName = ""
                    }, label: {
                        Image(systemName: "arrow.counterclockwise.circle")
                            .font(.custom("", size: 50))
                    })
                    Spacer()
                    if let _ = vm.detectedTags{
                        Button("Add") {
                            isAdding = true
                            Task{
                                let name = otherName.isEmpty ? selectedName : otherName
                                await vm.addItem(gameId: game.id, name: name)
                                selectedName = ""
                                otherName = ""
                                isAdding = false
                            }
                        }
                        .font(.title2)
                    }
                    else{
                        Button("Use") {
                            isFetching = true
                            progressValue = 10
                            Task{
                                progressText = "Removing Background"
                                await vm.removeBackground()
                                progressValue = 50
                                progressText = "Analyzing Image"
                                await vm.analyzeImage()
                                progressValue = 90
                                progressText = "Processing"
                                try? await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
                                isFetching = false
                            }
                        }
                        .font(.title2)
                    }
                }
                .padding(30)
            }else{
                Spacer()
                Button(action: {
                    vm.captureImage()
                }, label: {
                    ZStack{
                        Circle()
                            .frame(width: 70)
                        Circle()
                            .stroke(.background, lineWidth: 3.0)
                            .frame(width: 60)
                    }
                })
                Spacer()
            }
        }
        .frame(height: 100)
        .background(.ultraThickMaterial)
    }
}

struct AddItemsView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemsView(game: DataService.gameDetail)
    }
}

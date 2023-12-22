//
//  LiveGameView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 11/14/23.
//

import SwiftUI

struct LiveGameView: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View{
        VStack{
            VideoCaptureView(cameraManager: cameraManager)
        }
        .overlay{
            Text(cameraManager.classificationResult)
                .padding()
                .foregroundStyle(.white)
                .background(Color.black.opacity(0.7))
        }
        .onDisappear(perform: {
            cameraManager.stopSession()
        })
    }
}

#Preview {
    LiveGameView()
}

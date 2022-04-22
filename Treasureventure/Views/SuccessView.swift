//
//  SuccessView.swift
//  Treasureventure
//
//  Created by Jerish Bovas on 2022-04-21.
//

import SwiftUI

struct SuccessView: View {
    
    let image: Image
    let location: Location
    
    var body: some View {
        VStack(spacing: 20.0) {
            Spacer()
            Text("Congratulations, You won the game!")
                .font(.title2)
            image.resizable()
              .frame(width: 250, height: 250)
              .shadow(radius: 10)
              .cornerRadius(20)
            Text("Do you want to share the achievement?")
            Button(action: {
                shareVictory()
            }, label: {
                HStack{
                    Text("Share")
                    Image(systemName: "square.and.arrow.up")
                }
            })
            .buttonStyle(.bordered)
            Spacer()
            NavigationLink(destination: ContentView()) {
                HStack{
                    Text("Back to Home")
                    Image(systemName: "house.fill")
                }
                .font(.headline)
                .frame(width: 150, height: 40)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView(image: Image("goldenkey"), location: LocationsDataService.locations.first!)
    }
}

extension SuccessView {
    private func shareVictory() {
        let heading = "Congratulations from Treasureventure"
        let friend = "Your friend has successfully finished this level"
        let task = "Place name: \(location.name)\nItem found: \(location.item)\nDifficulty: \(location.difficulty.rawValue)"
        let activityVC = UIActivityViewController(activityItems: [heading,friend,task], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

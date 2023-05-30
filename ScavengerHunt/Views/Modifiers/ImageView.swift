//
//  ImageView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-18.
//

import SwiftUI
import NukeUI

struct ImageView: View {
    let url:String
    
    var body: some View {
        LazyImage(url: URL(string: url)) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .animation(.default, value: state.image)
            } else if state.error != nil {
                Image("placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image("placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(url: "")
    }
}

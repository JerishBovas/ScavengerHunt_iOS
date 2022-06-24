//
//  SliderView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import SwiftUI

struct SliderView: View {
    @State private var rating: Double = 1
    var body: some View {
        Form {
            Slider(value: $rating, in: 1...5, step: 1)
            RatingView(rating: .constant(Int(rating)))
        }
    }
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
        SliderView()
    }
}

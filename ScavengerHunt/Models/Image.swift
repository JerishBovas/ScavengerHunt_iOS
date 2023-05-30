//
//  Image.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-03.
//

import Foundation

struct ImageRequest{
    var imageFile: Data
    var fileName: String
}

struct ImageResponse: Decodable{
    var imagePath: String
}

struct ImageObject: Decodable{
    var image: Data
}

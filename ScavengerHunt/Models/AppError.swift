//
//  AppError.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-03.
//

import Foundation

struct AppError: Error, Identifiable{
    var id: UUID
    var title: String
    var message: String
    
    init(id: UUID = UUID(), title: String, message: String) {
        self.id = id
        self.title = title
        self.message = message
    }
}

//
//  Router.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-20.
//

import SwiftUI

class Router: ObservableObject{
    @Published var path = NavigationPath()
    
    func reset(){
        path = NavigationPath()
    }
}

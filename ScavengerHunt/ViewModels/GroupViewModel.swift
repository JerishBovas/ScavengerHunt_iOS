//
//  GameViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation
import MapKit
import SwiftUI

class GroupViewModel: ObservableObject {
    
    @Published var groups = [Group]()
    @State var authVM = AuthViewModel()
    private var api: ApiService = ApiService()
    
    func getGroups() async{
        do{
            let defaults = UserDefaults.standard
            if(await !authVM.refreshToken()){
                return
            }
            
            guard let accessToken = defaults.string(forKey: "accessToken") else {
                return
            }
            
            let groups: [Group] = try await api.get(accessToken: accessToken, endpoint: .group)
            print("Games fetched")
            DispatchQueue.main.async {
                self.groups = groups
            }
        }
        catch NetworkError.custom(let error){
            print("Request failed with error: \(error)")
        }
        catch{
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
}

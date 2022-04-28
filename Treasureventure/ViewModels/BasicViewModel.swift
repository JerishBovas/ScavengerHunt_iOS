//
//  BasicViewModel.swift
//  Treasureventure
//
//  Created by Jerish Bovas on 2022-04-28.
//

import Foundation

class BasicViewModel {
    
    public func setFirstTime(_ val: Bool){
        UserDefaults.standard.set(val, forKey: "firstTime")
    }
}

//
//  DifficultyEnum.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-16.
//

import Foundation

enum Difficulty{
    case Easy, Medium,Hard
    
    func getFromInt(index: Int) -> String{
        switch index{
        case 1:
            return "Easy"
        case 2:
            return "Medium"
        case 3:
            return "Hard"
        default:
            return ""
        }
    }
}

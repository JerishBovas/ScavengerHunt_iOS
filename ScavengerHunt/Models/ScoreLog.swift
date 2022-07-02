//
//  ScoreLog.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-02.
//

import Foundation

struct ScoreLog: Hashable, Codable{
    var datePlayed: String
    var gameName: String
    var score: Int
    
    var id: String{
        return datePlayed + gameName
    }
}

//
//  Sort.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-15.
//

import Foundation

enum Sort: String, CaseIterable, Identifiable {
    case relevance, mostPopular, mostPlayed, hard, easy
    var id: Self { self }
}

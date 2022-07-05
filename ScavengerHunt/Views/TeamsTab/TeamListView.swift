//
//  CardView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import SwiftUI
import UIKit

struct TeamListView: View {
    @State var team: Team
    
    var body: some View {
        NavigationLink(destination: TeamsView()){
            HStack(alignment: .top, spacing: 15){
                AsyncImage(url: URL(string: team.teamIcon)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.random
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading){
                    Text(team.title)
                        .foregroundColor(.primary)
                        .font(.headline)
                    Text(team.description)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
}

struct TeamListView_Previews: PreviewProvider {
    static var previews: some View {
        TeamListView(team: GamesDataService.team)
    }
}

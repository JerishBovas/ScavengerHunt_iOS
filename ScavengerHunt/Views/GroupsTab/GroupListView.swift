//
//  CardView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import SwiftUI
import UIKit

struct GroupListView: View {
    @State var group: Group
    
    var body: some View {
        NavigationLink(destination: GroupsView()){
            HStack(alignment: .top, spacing: 15){
                AsyncImage(url: URL(string: group.groupIcon)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.random
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading){
                    Text(group.title)
                        .foregroundColor(.primary)
                        .font(.headline)
                    Text(group.description)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
}

struct GroupListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView(group: GamesDataService.group)
    }
}

//
//  ListGamesView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-19.
//

import SwiftUI

struct GroupsView: View {
    
    @EnvironmentObject private var vm: GroupViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var showingAbout = false
    @State private var searchText = ""
    @State private var selectedSort: Sort = .relevance
    @State private var isFetchingGroups: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true){
                VStack{
                    HStack{
                        Button {
                            
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }
                        Spacer()
                        HStack(spacing: 0){
                            Text("Sort By: ")
                            Picker("Sort", selection: $selectedSort) {
                                ForEach(Sort.allCases) { sort in
                                    Text(sort.rawValue.capitalized)
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16)))
                    Divider()
                    VStack(alignment: .leading){
                        if(!isFetchingGroups){
                            if(!filteredGroups.isEmpty){
                                ForEach(filteredGroups, id: \.self.id) { group in
                                    GroupListView(group: group)
                                        .padding(.leading, 16)
                                        .animation(.spring(), value: filteredGroups)
                                    Divider()
                                        .padding(.leading, 91)
                                }
                            }
                            else{
                                VStack{
                                    Text("No Match")
                                        .padding(20)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                    Text("Please refine your search")
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }else{
                            HStack(alignment: .center){
                                ProgressView()
                            }
                        }
                    }
                    .onAppear{
                        isFetchingGroups = true
                        Task{
                            if(authVM.user != nil && vm.groups.isEmpty){
                                await vm.getGroups()
                            }
                            isFetchingGroups = false
                        }
                    }
                }
            }
            .navigationTitle("Games")
            .searchable(text: $searchText, prompt: "Search")
            .toolbar(content: {
                ToolbarItem (placement: .navigation)  {
                    EditButton()
                }
                ToolbarItem (placement: .automatic)  {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            })
        }
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsView()
            .environmentObject(GroupViewModel())
            .environmentObject(AuthViewModel())
    }
}

extension GroupsView {
    var filteredGroups: [Group] {
        if searchText.isEmpty {
            return vm.groups
        }
        else {
            return vm.groups.filter {
                $0.title
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

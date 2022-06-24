//
//  HomeView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-28.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var locVM: LocationsViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddLocation: Bool = false
    @State private var isScoreLoading: Bool = false
    @Binding var tabSelection: Int
    var colors: [Color] = [.blue, .teal]
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading) {
                welcomeTitle
                scoreCard
                    .padding()
                LocationsSlide
            }
        }
        .onAppear{
            isScoreLoading = true
            Task{
                if(authVM.user != nil){
                    isScoreLoading = false
                    return
                }
                await authVM.getAccount()
                isScoreLoading = false
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(tabSelection: .constant(2))
            .environmentObject(LocationsViewModel())
            .environmentObject(AuthViewModel())
    }
}

extension HomeView{
    private var welcomeTitle: some View{
        HStack(){
            VStack(alignment: .leading){
                Text("Hello \(authVM.user?.name ?? "")")
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                Text("Welcome Back")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image("goldenkey")
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accentColor)
        }
        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 3, y: 3)
        .padding()
    }
    private var scoreCard: some View{
        VStack(spacing: 0){
            HStack{
                VStack{
                    Spacer()
                    Spacer()
                    Text("Total Score")
                        .font(.headline)
                        .foregroundColor(.pink)
                    Spacer()
                }
            }
            HStack{
                
                if(isScoreLoading){
                    ProgressView()
                        .padding()
                }else{
                    Text(String(authVM.user?.userLog.userScore ?? 100))
                        .font(.system(size: 60))
                        .foregroundColor(.indigo)
                }
            }
            HStack{
                Text("Last Updated: \(authVM.dateFormatter(dat: authVM.user?.userLog.lastUpdated ?? Date.now.description))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            Color.gray.opacity(0.2)
        )
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 3, y: 3)
    }
    
    private var LocationsSlide: some View{
        VStack{
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(locVM.locations, id: \.self.id) { location in
                        CardView(location: location)
                    }
                }
                .padding()
            }
        }
    }
}

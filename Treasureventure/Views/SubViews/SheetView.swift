//
//  SheetView.swift
//  Treasureventure
//
//  Created by Jerish Bovas on 2022-04-27.
//

import SwiftUI

enum SheetMode {
    case quarter
    case half
    case halfQuarter
    case full
}

struct SheetView<Content:View>: View {
    
    let content: () -> Content
    var sheetMode: Binding<SheetMode>
    
    init(sheetMode: Binding<SheetMode>, @ViewBuilder content: @escaping () -> Content){
        self.content = content
        self.sheetMode = sheetMode
    }
    
    var body: some View {
        content()
            .offset(y: calcOffset())
            .animation(.spring())
            .edgesIgnoringSafeArea(.all)
    }
}

struct SheetView_Previews: PreviewProvider {
    static var previews: some View {
        SheetView(sheetMode: .constant(.full)) {
            VStack {
                Text("Hello World")
            }
        }
    }
}

extension SheetView{
    private func calcOffset() -> CGFloat{
        switch sheetMode.wrappedValue {
        case .quarter:
            return (UIScreen.main.bounds.height/4)*3
        case .half:
            return UIScreen.main.bounds.height/2
        case .halfQuarter:
            return (UIScreen.main.bounds.height/4)
        case .full:
            return 0
        }
    }
}

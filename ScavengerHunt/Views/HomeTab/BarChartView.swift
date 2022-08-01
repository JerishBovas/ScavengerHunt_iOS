//
//  BarChartView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-26.
//

import SwiftUI

struct BarChartView: View {
  var data: [Double]
  var colors: [Color]

  var highestData: Double {
    let max = data.max() ?? 1.0
    if max == 0 { return 1.0 }
    return max
  }

  var body: some View {
      ZStack {
          HStack(alignment: .bottom, spacing: 0){
              VStack{
                  VStack{
                      ForEach(1...5, id: \.self) { _ in
                          Divider()
                          Spacer()
                      }
                  }
                  Divider()
                      .frame(height: 1.5)
                      .overlay(.secondary)
              }
              HStack{
                  Divider()
                      .frame(width: 1.5)
                      .overlay(.secondary)
                  VStack{
                      Text("100")
                          .font(.caption)
                          .foregroundColor(.secondary)
                      Spacer()
                      Text("80")
                          .font(.caption)
                          .foregroundColor(.secondary)
                      Spacer()
                      Text("60")
                          .font(.caption)
                          .foregroundColor(.secondary)
                      Spacer()
                      Text("40")
                          .font(.caption)
                          .foregroundColor(.secondary)
                      Spacer()
                      Text("20")
                          .font(.caption)
                          .foregroundColor(.secondary)
                      Spacer()
                  }
              }
          }
          .frame(height: 200)
          VStack {
              Spacer()
              HStack(alignment: .bottom) {
                  Spacer()
                ForEach(data.indices, id: \.self) { index in
                  let width = (400 / CGFloat(data.count)) - 50.0
                  let height = 200 * data[index] / 100

                  BarView(datum: data[index], colors: colors)
                    .frame(width: width, height: height, alignment: .bottom)
                    Spacer()
                }
                  Spacer()
              }
          }
      }
  }
}

struct BarView: View {
  var datum: Double
  var colors: [Color]

  var gradient: LinearGradient {
    LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom)
  }

  var body: some View {
    Rectangle()
      .fill(gradient)
      .opacity(datum == 0.0 ? 0.0 : 1.0)
  }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView(data: [20.0, 25.0], colors: [.green, .blue, .black])
    }
}

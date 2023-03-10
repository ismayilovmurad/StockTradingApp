//
//  Intro.swift
//  StockTradingApp
//
//  Created by Murad Ismayilov on 10.03.23.
//

import SwiftUI

struct Intro: View {
    var body: some View {
        Label(" Ficus", systemImage: "chart.bar.xaxis")
            .foregroundColor(.mint)
            .font(.largeTitle)
            .padding(.bottom, 20)
    }
}

struct Intro_Previews: PreviewProvider {
    static var previews: some View {
        Intro()
    }
}

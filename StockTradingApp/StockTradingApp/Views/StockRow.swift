//
//  StockRow.swift
//  StockTradingApp
//
//  Created by Murad Ismayilov on 10.03.23.
//

import SwiftUI

struct StockRow: View {
    
    let stockName: String
    @Binding var selected: Set<String>
    
    var body: some View {
        
        Button(action: {
            
            if !selected.insert(stockName).inserted {
                selected.remove(stockName)
            }
            
        }, label: {
            
            HStack {
                HStack {
                    if selected.contains(stockName) {
                        Image(systemName: "checkmark")
                    }
                }
                .frame(width: 20)
                
                Text(stockName).fontWeight(.bold)
            }
            
        })
    }
}

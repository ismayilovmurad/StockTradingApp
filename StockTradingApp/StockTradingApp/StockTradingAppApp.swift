//
//  StockTradingAppApp.swift
//  StockTradingApp
//
//  Created by Murad Ismayilov on 10.03.23.
//

import SwiftUI

@main
struct StockTradingAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(stockListFetcher: StockListFetcher(), liveStockPriceFetcher: LiveStockPriceFetcher())
        }
    }
}

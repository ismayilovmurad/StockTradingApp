//
//  ContentView.swift
//  StockTradingApp
//
//  Created by Murad Ismayilov on 10.03.23.
//

import SwiftUI

/// Displays a list of stock stocks.
struct ContentView: View {
    let stockListFetcher: StockListFetcher
    let liveStockPriceFetcher: LiveStockPriceFetcher
    /// The list of stocks available on the server.
    @State var stocks: [String] = []
    /// The currently selected stocks.
    @State var selected: Set<String> = []
    /// Description of the latest error to display to the user.
    @State var lastErrorMessage = "" {
        didSet { isDisplayingError = true }
    }
    @State var isDisplayingError = false
    @State var isDisplayingTicker = false
    
    var body: some View {
        NavigationStack {
            // The list of stock stocks.
            List {
                Section(content: {
                    if stocks.isEmpty {
                        ProgressView().padding()
                    }
                    ForEach(stocks, id: \.self) { stockName in
                        StockRow(stockName: stockName, selected: $selected)
                    }
                    .font(.headline)
                }, header: Intro.init)
            }
            .listStyle(.plain)
            .statusBar(hidden: true)
            .toolbar {
                Button("Live ticker") {
                    if !selected.isEmpty {
                        isDisplayingTicker = true
                    }
                }
                .disabled(selected.isEmpty)
            }
            .alert("Error", isPresented: $isDisplayingError, actions: {
                Button("Close", role: .cancel) { }
            }, message: {
                Text(lastErrorMessage)
            })
            .padding(.horizontal)
            // MARK: onAppear(...) runs code synchronously, task(priority:_:) allows us to call asynchronous functions.
            .task {
                // MARK: Just like onAppear(_:), task(priority:_:) called each time the view appears onscreen. That’s why we start by making sure we don’t have stocks already.
                guard stocks.isEmpty else { return }
                
                // MARK: Call the async function. As before, we use both try and await to signify that the method might either throw an error or asynchronously return a value. We assign the result to stocks, and … that’s all we need to do.
                do {
                    stocks = try await stockListFetcher.fetchStockList()
                } catch {
                    // MARK: Swift catches the error, regardless of which thread throws it. We simply write our error handling code as if our code is entirely synchronous.
                    lastErrorMessage = error.localizedDescription
                }
            }
            .navigationDestination(isPresented: $isDisplayingTicker) {
                LiveStockPriceView(selectedStocks: Array(selected).sorted())
                    .environmentObject(liveStockPriceFetcher)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(stockListFetcher: StockListFetcher(), liveStockPriceFetcher: LiveStockPriceFetcher())
    }
}

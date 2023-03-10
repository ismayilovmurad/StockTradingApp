//
//  LiveStockPriceView.swift
//  StockTradingApp
//
//  Created by Murad Ismayilov on 10.03.23.
//

import SwiftUI

// MARK: For LiveStockPriceView, the same approach won’t work because we can’t wait for the request to complete and only then display the data. The data needs to keep coming in indefinitely and bring in those price updates.

/// Displays a list of stocks and shows live price updates.
struct LiveStockPriceView: View {
    
    let selectedStocks: [String]
    
    @EnvironmentObject var model: LiveStockPriceFetcher
    
    @Environment(\.presentationMode) var presentationMode
    
    /// Description of the latest error to display to the user.
    @State var lastErrorMessage = "" {
        didSet { isDisplayingError = true }
    }
    
    @State var isDisplayingError = false
    
    var body: some View {
        List {
            Section(content: {
                // Show the list of selected stocks
                ForEach(model.livePrices, id: \.name) { stockName in
                    HStack {
                        Text(stockName.name)
                        Spacer().frame(maxWidth: .infinity)
                        Text(String(format: "%.3f", arguments: [stockName.value]))
                    }
                }
            }, header: {
                Label(" Live", systemImage: "clock.arrow.2.circlepath")
                    .foregroundColor(.mint)
                    .font(.largeTitle)
                    .padding(.bottom, 20)
            })
        }
        .alert("Error", isPresented: $isDisplayingError, actions: {
            Button("Close", role: .cancel) { }
        }, message: {
            Text(lastErrorMessage)
        })
        .listStyle(.plain)
        .font(.headline)
        .padding(.horizontal)
        // MARK: Since we start the entire process inside task(_:), the async task is the parent of all those other tasks, regardless of their execution thread or suspension state. The task(_:) view modifier in SwiftUI takes care of canceling our asynchronous code when its view goes away. Thanks to structured concurrency, all asynchronous tasks are also canceled when the user navigates out of the screen.
        .task {
            do {
                // MARK: Our code calls fetchLiveStockPrice(_:) asynchronously. In turn, fetchLiveStockPrice(_:) asynchronously awaits URLSession.bytes(from:delegate:), which returns an async sequence that we iterate over.
                try await model.fetchLiveStockPrice(selectedStocks)
            } catch {
                // MARK: We get a URLError from the ongoing URLSession that fetches the live updates. If we use other modern APIs, they might throw a CancellationError instead.
                if let error = error as? URLError,
                   error.code == .cancelled {
                    return
                }
                
                lastErrorMessage = error.localizedDescription
            }
        }
    }
}

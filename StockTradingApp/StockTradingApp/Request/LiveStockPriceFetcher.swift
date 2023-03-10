//
//  LivePriceFetcher.swift
//  StockTradingApp
//
//  Created by Murad Ismayilov on 10.03.23.
//

import Foundation

@MainActor
class LiveStockPriceFetcher: ObservableObject {
    
    // MARK: A URL session that lets requests run indefinitely so we can receive live updates from server. Instead of using the shared URL session, we use a custom pre-configured session called liveURLSession, which makes requests that never expire or time out. This lets us keep receiving a super-long server response indefinitely.
    private lazy var liveURLSession: URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = .infinity
        return URLSession(configuration: configuration)
    }()
    
    /// Current live updates.
    @Published
    private(set) var livePrices: [Stock] = []
    
    /// Start live updates for the provided stock stocks.
    func fetchLiveStockPrice(_ selectedStocks: [String]) async throws {
        
        guard let url = URL(string: "http://localhost:8080/littlejohn/ticker?\(selectedStocks.joined(separator: ","))") else {
            throw "The URL could not be created."
        }
        
        // MARK: URLSession.bytes(from:delegate:) is similar to the API we used in the fetchStockList(). However, instead of data, it returns an asynchronous sequence that we can iterate over time. It’s assigned to stream in our code.
        let (stream, response) = try await liveURLSession.bytes(from: url)
        
        // MARK: Verify the server response
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw "The server responded with an error."
        }
        
        // MARK: stream is a sequence of bytes that the server sends as a response. lines is an abstraction of that sequence that gives us that response’s lines of text, one by one. Asynchronous sequences are similar to the “vanilla” Swift sequences from the standard library. The hook of asynchronous sequences is that we can iterate over their elements asynchronously as more and more elements become available over time.
        for try await line in stream.lines {
            
            // MARK: We’ll iterate over the lines and decode each one as JSON. If the decoder successfully decodes the line as a list of prices, we sort them and assign them to livePrices to render them onscreen. If the decoding fails, JSONDecoder simply throws an error.
            let sortedLivePrices = try JSONDecoder()
                .decode([Stock].self, from: Data(line.utf8))
                .sorted(by: { $0.name < $1.name })
            
            // MARK: If we code "livePrices = sortedLivePrices" we'll most likely see some price updates, we'll also notice glitches and a big purple warning in our code editor saying Publishing changes from background threads is not allowed.... Luckily, we can switch to the main thread any time we need to. Replace the line livePrices = sortedLivePrices with the following code. MainActor is a type that runs code on the main thread. We can easily run any code with it by calling MainActor.run(_:)
            await MainActor.run {
                livePrices = sortedLivePrices
                print("Updated: \(Date())")
            }
        }
    }
}

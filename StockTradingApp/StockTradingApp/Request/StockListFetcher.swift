//
//  StockListFetcher.swift
//  StockTradingApp
//
//  Created by Murad Ismayilov on 10.03.23.
//

import Foundation

@MainActor
class StockListFetcher: ObservableObject {
    
    // MARK: The async keyword in the method’s definition lets the compiler know that the code runs in an asynchronous context. In other words, it says that the code might suspend and resume at will. Also, regardless of how long the method takes to complete, it ultimately returns a value much like a synchronous method does.
    func fetchStockList() async throws -> [String] {
        
        guard let url = URL(string: "http://localhost:8080/littlejohn/symbols")
        else {
            throw "The URL could not be created."
        }
        
        // MARK: Calling the async method URLSession.data(from:delegate:) suspends fetchStockList() and resumes it when it gets the data back from the server. Using await gives the runtime a suspension point: a place to pause our method, consider if there are other tasks to run first and then continue running our code. Call URLSession and fetch data from the book server. At each suspension point — that is, every time we see the await keyword — the thread could potentially change.
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // MARK: Verify the server response
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw "The server responded with an error."
        }
        
        // MARK: Decode the response data as a list of Strings, return the fetched data
        return try JSONDecoder().decode([String].self, from: data)
    }
}

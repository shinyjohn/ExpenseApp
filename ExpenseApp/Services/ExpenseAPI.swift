//
//  ExpenseAPI.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import Foundation

struct RemoteExpense: Decodable, Sendable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

protocol ExpenseAPIProtocol: Sendable {
    func fetchExpenses() async throws -> [RemoteExpense]
}

struct ExpenseAPI: ExpenseAPIProtocol {
    var baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!
    var session: URLSession = .shared

    func fetchExpenses() async throws -> [RemoteExpense] {
        let url = baseURL.appending(path: "posts")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20

        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            throw APIError.invalidResponse
        }
        return try JSONDecoder().decode([RemoteExpense].self, from: data)
    }
}

enum APIError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        "The server returned an unexpected response. Please try again."
    }
}


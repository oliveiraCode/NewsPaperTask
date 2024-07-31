//
//  SubscriptionService.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import Foundation

import Foundation

enum ServiceError: Error {
    case requestFailed(Error)
    case invalidResponse
    case httpError(statusCode: Int)
    case noData
    case decodingError(Error)
}

protocol SubscriptionServiceType {
    func fetchData(completion: @escaping (Result<Response, ServiceError>) -> Void)
}

final class SubscriptionService: SubscriptionServiceType {
    private let url = URL(string: "https://api.jsonbin.io/v3/qs/66a950f0e41b4d34e41961f8")!

    func fetchData(completion: @escaping (Result<Response, ServiceError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                completion(.failure(.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}

//
//  NetworkingClient.swift
//  PullToRefresh
//
//  Created by Shreyas Rajapurkar on 04/12/22.
//

import Foundation

protocol Resource {
    var scheme: String { get }
    var relativePath: String { get }
    var queryItems: [URLQueryItem] { get }
    var httpMethod: String { get }
}

class SuccessResource: Resource {
    var scheme: String = "https"
    var relativePath: String = "api.mocklets.com/p68348/success_case"
    var queryItems: [URLQueryItem]
    var httpMethod: String = "GET"
    
    init(queryItems: [URLQueryItem] = []) {
        self.queryItems = queryItems
    }
}

class FailureResource: Resource {
    var scheme: String = "https"
    var relativePath: String = "api.mocklets.com/p68348/failure_case"
    var queryItems: [URLQueryItem]
    var httpMethod: String = "GET"
    
    init(queryItems: [URLQueryItem] = []) {
        self.queryItems = queryItems
    }
}

class NetworkingClient {
    public static func performRequest<T: Decodable>(resource: Resource, completion: @escaping (Result<T, Error>) -> ()) {
        var urlComponents = URLComponents()
        urlComponents.scheme = resource.scheme
        urlComponents.path = resource.relativePath
        urlComponents.queryItems = resource.queryItems

        guard let url = urlComponents.url else {
            print("Unable to construct URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = resource.httpMethod
    
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }

            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        dataTask.resume()
    }
}


//
//  BaseService.swift
//  MVVM-POC
//
//  Created by Bernardo Silva on 01/04/20.
//  Copyright © 2020 Bernardo. All rights reserved.
//

import Combine
import Foundation

public enum SessionError: Error {
    case unknownError
}

open class BaseService {

    open var configuration: URLSessionConfiguration

    open func request<T: Decodable>(router: Router, completion: @escaping (Result<T, Error>) -> ()) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = router.host
        components.path = router.path
        components.queryItems = router.parameters
        
        guard let url = components.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method
        
        let session = URLSession(configuration: configuration)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            
            guard let data = data else {
                if let sessionError = error {
                    completion(.failure(sessionError))
                } else {
                    completion(.failure(SessionError.unknownError))
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(T.self, from: data)

                completion(.success(responseObject))
            } catch {
                completion(.failure(error))
            }

            
        }
        dataTask.resume()
    }

    public init(configuration: URLSessionConfiguration = .default) {
        self.configuration = configuration
    }

}

@available(iOS 13, macOS 10.15, *)
extension BaseService {

    open func requestPublisher<T: Decodable>(router: Router) -> AnyPublisher<T, Error> {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = router.host
        components.path = router.path
        components.queryItems = router.parameters
        
        guard let url = components.url else { return Fail(outputType: T.self, failure: NSError()).eraseToAnyPublisher() }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method
        
        let pub = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
        return pub
    }

}

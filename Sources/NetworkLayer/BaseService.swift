//
//  BaseService.swift
//  MVVM-POC
//
//  Created by Bernardo Silva on 01/04/20.
//  Copyright © 2020 Bernardo. All rights reserved.
//

import Combine
import Foundation

public class BaseService {

    open func request<T: Decodable>(router: Router, completion: @escaping (Result<T, Error>) -> ()) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = router.host
        components.path = router.path
        components.queryItems = router.parameters
        
        guard let url = components.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            
            guard let data = data,  error == nil else {
                completion(.failure(error!))
                return
            }
            
            let responseObject = try! JSONDecoder().decode(T.self, from: data)
            
            completion(.success(responseObject))
            
        }
        dataTask.resume()
    }

    public init() { }

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

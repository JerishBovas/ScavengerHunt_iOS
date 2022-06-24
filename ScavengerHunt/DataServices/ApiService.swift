//
//  WebService.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-19.
//

import Foundation

enum NetworkError: Error{
    case invalidURL
    case custom(error:String)
}

class ApiService{
    
    func getLocations(accessToken: String) async throws -> [Location]{
        var request = URLRequest(url: URL(string: "https://scavengerhuntapis.azurewebsites.net/api/location")!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return try await fetchApi(request: request)
    }
    
    func getAccount(accessToken: String)async throws -> User{
        var request = URLRequest(url: URL(string: "https://scavengerhuntapis.azurewebsites.net/api/home")!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return try await fetchApi(request: request)
    }
    
    func login(email: String, password: String) async throws -> TokenObject{
        let body = LoginRequest(email: email, password: password)
        
        var request = URLRequest(url: URL(string: "https://scavengerhuntapis.azurewebsites.net/api/auth/login")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        return try await fetchApi(request: request)
    }
    
    func refreshToken(accessToken: String, refreshToken: String) async throws -> TokenObject{
        let body = TokenObject(accessToken: accessToken, refreshToken: refreshToken)
        
        var request = URLRequest(url: URL(string: "https://scavengerhuntapis.azurewebsites.net/api/auth/refreshtoken")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        return try await fetchApi(request: request)
    }
    
    func fetchApi<D: Decodable>(request: URLRequest) async throws -> D{
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200  else  {
            let error = try JSONDecoder().decode(ErrorObject.self, from: data)
            print(error)
            throw NetworkError.custom(error: error.title)
        }
        
        let tokenObj = try JSONDecoder().decode(D.self, from: data)
        
        return tokenObj
    }
}

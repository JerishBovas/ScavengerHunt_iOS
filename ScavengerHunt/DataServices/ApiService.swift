//
//  WebService.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-19.
//

import Foundation

enum NetworkError: Error{
    case custom(error:String)
}

class ApiService{
    
    func get<T: Decodable>(endpoint: APIEndpoint) async throws -> T{
        var request = URLRequest(url: URL(string: endpoint.description)!)
        request.httpMethod = "GET"
        
        return try await fetchApi(request: request)
    }
    
    func get<T: Decodable>(accessToken: String, endpoint: APIEndpoint) async throws -> T{
        var request = URLRequest(url: URL(string: endpoint.description)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return try await fetchApi(request: request)
    }
    
    func post<T: Decodable>(body: Encodable, endpoint: APIEndpoint) async throws -> T{
        var request = URLRequest(url: URL(string: endpoint.description)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        return try await fetchApi(request: request)
    }
    
    func post<T: Decodable>(accessToken: String, body: Encodable, endpoint: APIEndpoint) async throws -> T{
        var request = URLRequest(url: URL(string: endpoint.description)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        return try await fetchApi(request: request)
    }
    
    func put(accessToken: String, body:Encodable, endpoint: APIEndpoint) async throws{
        var request = URLRequest(url: URL(string: endpoint.description)!)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        return try await fetchApi(request: request)
    }
    
    func delete(accessToken: String, endpoint: APIEndpoint) async throws{
        var request = URLRequest(url: URL(string: endpoint.description)!)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return try await fetchApi(request: request)
    }
    
    func fetchApi<T: Decodable>(request: URLRequest) async throws -> T{
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print(String(data: data, encoding: .utf8) ?? "")
        guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode < 300  else  {
            let error = try JSONDecoder().decode(ErrorObject.self, from: data)
            print(error)
            throw NetworkError.custom(error: error.title)
        }
        
        if response.statusCode == 204{
            throw NetworkError.custom(error: "Not Content")
        }
        
        let tokenObj = try JSONDecoder().decode(T.self, from: data)
        
        return tokenObj
    }
    
    func fetchApi(request: URLRequest) async throws{
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print(String(data: data, encoding: .utf8) ?? "")
        guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode < 300  else  {
            let error = try JSONDecoder().decode(ErrorObject.self, from: data)
            print(error)
            throw NetworkError.custom(error: error.title)
        }
    }
    
    func uploadImage(endpoint: APIEndpoint, request: ImageRequest, accessToken: String) async throws -> ImageResponse{
        var urlRequest = URLRequest(url: URL(string: endpoint.description)!)
        let boundary = "Boundary-\(UUID().uuidString)"
        
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
        
        var requestData = Data()
        
        requestData.append("--\(boundary)\r\n" .data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"ImageFile\"; filename=\"\(request.fileName)\"\r\n" .data(using: .utf8)!)
        requestData.append("Content-Type: image/jpeg \r\n\r\n" .data(using: .utf8)!)
        requestData.append(request.imageFile as Data)
        requestData.append("\r\n--\(boundary)--\r\n" .data(using: .utf8)!)
        
        urlRequest.addValue("\(requestData.count)", forHTTPHeaderField: "content-length")
        
        urlRequest.httpBody = requestData
        
        return try await fetchApi(request: urlRequest)
    }
}

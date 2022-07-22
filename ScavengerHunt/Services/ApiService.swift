//
//  WebService.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-19.
//

import Foundation
enum ErrorType: Error{
    case error(_ error: ApiError)
}
enum ApiError{
    case processingError
    case unauthorizedError
    case badRequestError
    case serverError
    case loginError
    case custom(title: String, message: String)
    
    var appError: AppError {
        switch self{
        case .processingError:
            return AppError(title: "Something went wrong", message: "Something went wrong.  Please try again or contact developer.")
        case .unauthorizedError:
            return AppError(title: "Permission Denied", message: "You are not permitted to do this action. Try Logging In again.")
        case .badRequestError:
            return AppError(title: "Try Again", message: "Something went wrong. Please try again.")
        case .serverError:
            return AppError(title: "Try again later", message: "Something went wrong in our side.  Please try back later.")
        case .loginError:
            return AppError(title: "Login Failed", message: "Please try logging in again")
        case .custom(let title, let message):
            return AppError(title: title, message: message)
        }
    }
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
    
    func post<T: Decodable>(body: Data, endpoint: APIEndpoint) async throws -> T{
        var request = URLRequest(url: URL(string: endpoint.description)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return try await fetchApi(request: request)
    }
    
    func post<T: Decodable>(accessToken: String, body: Data, endpoint: APIEndpoint) async throws -> T{
        var request = URLRequest(url: URL(string: endpoint.description)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return try await fetchApi(request: request)
    }
    
    func post(body: Data, endpoint: APIEndpoint) async throws{
        var request = URLRequest(url: URL(string: endpoint.description)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        try await fetchApi(request: request)
    }
    
    func post(accessToken: String, body: Data, endpoint: APIEndpoint) async throws{
        var request = URLRequest(url: URL(string: endpoint.description)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        try await fetchApi(request: request)
    }
    
    func put(accessToken: String, body: Data, endpoint: APIEndpoint) async throws{
        var request = URLRequest(url: URL(string: endpoint.description)!)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
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
            print(response)
            let error = try JSONDecoder().decode(ErrorObject.self, from: data)
            throw ErrorType.error( .custom(title: error.title, message: error.errors.joined(separator: "\n")))
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
            throw ErrorType.error( .custom(title: error.title, message: error.errors.joined(separator: "\n")))
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

//
//  WebService.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-19.
//

import Foundation

struct ErrorObject: Decodable, Error{
    var title: String
    var status: Int
    var errors: Set<String>
}

class ApiService{
    
    func get<T: Decodable>(endpoint: String) async throws -> T{
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "GET"
        
        return try await fetchApi(request: request)
    }
    
    func get<T: Decodable>(accessToken: String, endpoint: String) async throws -> T{
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return try await fetchApi(request: request)
    }
    
    func post(body: Data, endpoint: String) async throws{
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        try await fetchApi(request: request)
    }
    
    func post(accessToken: String, body: Data, endpoint: String) async throws{
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        try await fetchApi(request: request)
    }
    
    func post<T: Decodable>(body: Data, endpoint: String) async throws -> T{
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return try await fetchApi(request: request)
    }
    
    func post<T: Decodable>(accessToken: String, body: Data, endpoint: String) async throws -> T{
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return try await fetchApi(request: request)
    }
    
    func post<T:Decodable>(imageData: Data, data: Data, endpoint: String, accessToken: String) async throws -> T{
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"json\"\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)

        // add image data to the request body
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpeg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        // end the request body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        return try await fetchApi(request: request)
    }
    
    func put(accessToken: String, body: Data, endpoint: String) async throws{
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return try await fetchApi(request: request)
    }
    func put<T:Decodable>(accessToken: String, body: Data, endpoint: String) async throws -> T{
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return try await fetchApi(request: request)
    }
    func put<T:Decodable>(imageData: Data?, data: Data?, endpoint: String, accessToken: String) async throws -> T{
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        if let data = data{
            //add data to the request body
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"json\"\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n".data(using: .utf8)!)
        }

        if let imageData = imageData{
            // add image data to the request body
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpeg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        // end the request body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        return try await fetchApi(request: request)
    }
    
    func delete(accessToken: String, endpoint: String) async throws{
        var request = URLRequest(url: URL(string: endpoint)!)
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
            throw AppError(title: error.title, message: error.errors.joined(separator: "\n"))
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
            throw AppError(title: error.title, message: error.errors.joined(separator: "\n"))
        }
    }
}

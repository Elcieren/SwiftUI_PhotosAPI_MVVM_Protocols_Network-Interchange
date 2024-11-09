//
//  Webservice.swift
//  SwiftUI_PhotosAPI_MVVM_Protocols_Network Interchange
//
//  Created by Eren Elçi on 9.11.2024.
//

import Foundation

enum NetworkError : Error {
    case invalidUrl
    case invalidServerResponse
}


class Webservice :  NetworkService {
    var typ : String = "Webservice"
    func download(_ source: String) async throws -> [Photo] {
        
        guard let url = URL(string: source) else { throw NetworkError.invalidUrl }
        
        let (data , response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse , response.statusCode == 200 else { throw NetworkError.invalidServerResponse }
        
        return try JSONDecoder().decode([Photo].self, from: data)
        
        
    }
    
}

//
//  Localservice.swift
//  SwiftUI_PhotosAPI_MVVM_Protocols_Network Interchange
//
//  Created by Eren Elçi on 9.11.2024.
//

import Foundation


class Localservice : NetworkService {
    var typ : String = "Localservice"
    
    
    func download(_ source: String) async throws -> [Photo] {
        
        guard let path = Bundle.main.path(forResource: source, ofType: "json") else { fatalError("Resource not found") }
        let data = try Data(contentsOf: URL(filePath: path))
        
        return try JSONDecoder().decode([Photo].self, from: data)
    }
    
    
}

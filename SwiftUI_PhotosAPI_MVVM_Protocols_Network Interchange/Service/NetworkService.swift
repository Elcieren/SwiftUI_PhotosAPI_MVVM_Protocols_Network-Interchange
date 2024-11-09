//
//  NetworkService.swift
//  SwiftUI_PhotosAPI_MVVM_Protocols_Network Interchange
//
//  Created by Eren Elçi on 9.11.2024.
//

import Foundation


protocol NetworkService {
    func download(_ source: String) async throws -> [Photo]
    var typ : String { get }
}

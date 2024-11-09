//
//  PhotosViewModel.swift
//  SwiftUI_PhotosAPI_MVVM_Protocols_Network Interchange
//
//  Created by Eren Elçi on 9.11.2024.
//

import Foundation


class  PhotosViewListModel : ObservableObject {
    @Published var photosList = [PhotosViewModel]()
    
   // let webservice = Webservice()
   // let localservie = Localservice()
    var service: NetworkService
    
    init(service: NetworkService) {
        self.service = service
    }
    
    func dowloadPhotos() async  {
        var source = ""
        
        if service.typ == "Webservice"{
            source = Constants.Urls.photosUrl
        } else {
            source = Constants.Paths.baseUrl
        }
        
        do {
            let photo = try await service.download(source)
            DispatchQueue.main.async {
                self.photosList = photo.map(PhotosViewModel.init)
            }
        } catch {
            
        }
    }
    
    
    
}




struct  PhotosViewModel {
    let photos: Photo
    
    var albumId: Int {
        photos.albumID
    }
    
    var id: Int {
        photos.id
    }
    
    var title : String {
        photos.title
    }
    
    var thumbnailURL: String {
        photos.thumbnailURL
    }
    
    
    
}

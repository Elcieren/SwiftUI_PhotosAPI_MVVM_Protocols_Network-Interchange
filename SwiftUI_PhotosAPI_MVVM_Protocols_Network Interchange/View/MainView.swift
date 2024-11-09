//
//  ContentView.swift
//  SwiftUI_PhotosAPI_MVVM_Protocols_Network Interchange
//
//  Created by Eren Elçi on 9.11.2024.
//

import SwiftUI

struct MainView: View {
    @State private var isCanliVeriButtonPressed = false
    @State private var isLocalVeriButtonPressed = false
    @ObservedObject var photosViewListModel : PhotosViewListModel
    
    
    init(){
        self.photosViewListModel = PhotosViewListModel(service: Localservice())
    }
    
    var body: some View {
        NavigationStack {
            List(photosViewListModel.photosList,id: \.id) { photo in
                HStack{
                    AsyncImage(url: URL(string: photo.thumbnailURL)) { phase in
                        if let image = phase.image {
                            image.resizable().frame(width: 50, height: 50)
                                .scaledToFit()
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        } else if phase.error != nil {
                            Text("Goruntu yuklenemedi")
                        } else {
                            ProgressView()
                        }
                        
                    }
                    
                    VStack{
                        Text(String(photo.id)).font(.title3).frame(maxWidth: .infinity, alignment: .bottomLeading)
                        Text(photo.title).font(.title3).frame(maxWidth: .infinity, alignment: .bottomLeading)
                        
                    }
                }
               
                
            }.task {
                await photosViewListModel.dowloadPhotos()
            }.navigationTitle("Photo")
             .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isCanliVeriButtonPressed = true
                            isLocalVeriButtonPressed = false
                        }
                        
                        photosViewListModel.service = Webservice()
                        Task {
                        await photosViewListModel.dowloadPhotos()
                         }
                    } label: {
                        Text("Canli Veri")
                        .scaleEffect(isCanliVeriButtonPressed ? 1.2 : 1.0)
                            
                                    
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isLocalVeriButtonPressed = true
                            isCanliVeriButtonPressed = false
                        }
                        photosViewListModel.service = Localservice()
                        Task {
                            await photosViewListModel.dowloadPhotos()
                        }
                    } label: {
                        Text("Local Veri")
                            .scaleEffect(isLocalVeriButtonPressed ? 1.2 : 1.0)
                        
                    }

                }
            }
        }
    }
}

#Preview {
    MainView()
}

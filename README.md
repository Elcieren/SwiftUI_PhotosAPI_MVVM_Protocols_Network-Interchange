## SwiftUI_PhotosAPI_MVVM_Protocols_Network-Interchange
| Remote veri  Local veri |
|---------|
| ![Video 1](https://github.com/user-attachments/assets/869d1c86-e1ea-4401-8249-e52098242967) | 


 <details>
    <summary><h2>Uygulamanın Amacı ve Senaryo Mantığı</h2></summary>
    Proje Amacı
   Bu uygulama, iki farklı veri kaynağından (local JSON dosyası ve canlı web servisi) veri çekmek için yapılandırılmıştır. Amaç, arka uç (backend) tarafında yapılan değişiklikleri hızlıca test edebilmek ve veri akışını bir satırla değiştirebilmek. Geliştirilen senaryoya göre, arka uç geliştiren kişiyle iletişim kurarak, uygulama içinde yapılan JSON verisi değişikliklerini hızlıca görebilmek hedeflenmiştir. Bu nedenle, LocalService ve WebService sınıfları farklı veri çekme yöntemlerini implement eder, ancak ana yapı değişmeden kalır. Bu senaryoda, uygulama sadece hangi veri kaynağından veri çekeceğini belirler ve bu kaynak, kolayca değiştirilebilir.
  </details>  


  <details>
    <summary><h2>MVVM Yapısı</h2></summary>
     MVVM (Model-View-ViewModel) yapısı, uygulamanın veri ile ilgili iş mantığının View ve Model arasında temiz bir ayrım yaparak yönetilmesine olanak tanır. Bu yapı, uygulamanın daha kolay yönetilmesini, test edilmesini ve bakımının yapılmasını sağlar.
     - Model
     - View
     - Viewmodel
  </details> 

  <details>
    <summary><h2>Model (Data Model)</h2></summary>
    Photo struct'ı, JSON verisini karşılayan modeldir. Bu model, bir fotoğrafın bilgilerini (albumID, id, title, url, thumbnailURL) içeriyor.
    Codable protokolü sayesinde JSON verileri bu modele dönüştürülebilir.
    
    ```
    struct Photo: Codable {
    let albumID: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailURL: String

    enum CodingKeys: String, CodingKey {
        case albumID = "albumId"
        case id, title, url
        case thumbnailURL = "thumbnailUrl"
    }
    }

    ```
  </details> 


  <details>
    <summary><h2>View</h2></summary>
   PhotosView yapısında, kullanıcıya fotoğrafları listeleyen bir UI elemanı olan List var.
   PhotosViewListModel'i gözlemleyerek verilerin UI'ye bağlanmasını sağlıyoruz.
   PhotosViewListModel'i başlatırken bir Localservice kullanıyoruz. Bu, uygulama başlatıldığında verilerin lokal olarak çekileceğini gösteriyor. Web servisi kullanmak için tek yapmanız gereken, Localservice'i Webservice ile değiştirmek.
    
    ```
    struct PhotosView: View {
    @ObservedObject var photosViewListModel: PhotosViewListModel
    
    init() {
        self.photosViewListModel = PhotosViewListModel(service: Localservice())
    }
    
    var body: some View {
        List(photosViewListModel.photosList, id: \.id) { photo in
            VStack {
                Text(photo.title).font(.title3).foregroundStyle(.blue).frame(maxWidth:.infinity , alignment: .leading)
                Image(systemName: "photo").frame(maxWidth: .infinity, alignment: .leading)
                Text(photo.thumbnailURL).font(.title3).foregroundStyle(.red).frame(maxWidth: .infinity, alignment: .leading)
            }
        }.task {
            await photosViewListModel.dowloadPhotos()
        }
    }
    }

    ```
  </details> 


  <details>
    <summary><h2>ViewModel</h2></summary>
  PhotosViewListModel, bir NetworkService'ı alarak web servisi veya lokal veri kaynağını seçiyor.
  Veriyi çekerken downloadPhotos fonksiyonunu kullanarak, veriyi async olarak indiriyor ve ardından photosList'i güncelliyor.
  photosList'i güncelleyerek UI'yi yeniden render ediyor.
    
    ```
    class PhotosViewListModel: ObservableObject {
    @Published var photosList = [PhotosViewModel]()
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
            // Error handling can be added here
        }
    }
    }



    ```
  </details> 

  

  
  <details>
    <summary><h2>Webservice Sınıfı</h2></summary>
   Webservice sınıfı, NetworkService protokolünü benimseyerek veri çekme işini gerçekleştiriyor. download fonksiyonu, belirtilen URL üzerinden JSON verisini çekip, bunu Photo modeline decode eder.
    
    ```
    class Webservice: NetworkService {
    var typ: String = "Webservice"
    
    func download(_ source: String) async throws -> [Photo] {
        guard let url = URL(string: source) else { throw NetworkError.invalidUrl }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw NetworkError.invalidServerResponse }
        return try JSONDecoder().decode([Photo].self, from: data)
    }
    }

    ```
  </details> 

  <details>
    <summary><h2>LocalService</h2></summary>
   Localservice, yerel kaynaklardan veri çekmek için kullanılır. Burada JSON dosyasını Bundle'dan alarak veriyi decode ediyor.
    
    ```
    class Localservice: NetworkService {
    var typ: String = "Localservice"
    
    func download(_ source: String) async throws -> [Photo] {
        guard let path = Bundle.main.path(forResource: source, ofType: "json") else { fatalError("Resource not found") }
        let data = try Data(contentsOf: URL(filePath: path))
        return try JSONDecoder().decode([Photo].self, from: data)
    }
    }
    ```
  </details> 


  


  <details>
    <summary><h2>NetworkService</h2></summary>
   Webservice ve Localservice, veriyi çekmek için kullanılan iki farklı sınıftır.
   Webservice, internet üzerinden veri çekmek için kullanılır. Bu sınıfın içinde URL üzerinden fotoğrafları çeken bir method var.
   Localservice, cihazdaki yerel dosyalardan veri çekmek için kullanılır. JSON dosyasındaki veriyi okur ve onu decode ederek geriye döner.
    
    ```
    protocol NetworkService {
    func download(_ source: String) async throws -> [Photo]
    var typ : String { get }
     }

    ```
  </details>

  <details>
    <summary><h2>Constants</h2></summary>
   Constants sınıfında sabit URL'ler ve dosya yolları bulunuyor. Bu sayede URL'leri her yerde tekrar tekrar yazmak yerine merkezi bir yerden yönetebiliyoruz
    
    ```
    class Constants {
    struct Paths {
        static let baseUrl = "photos"
    }
    
    struct Urls {
        static let mainUrl = "https://jsonplaceholder.typicode.com"
        static  let photosUrl = "\(mainUrl)/photos"
    }
    }


    ```
  </details>

  


<details>
    <summary><h2>Uygulama Görselleri </h2></summary>
    
    
 <table style="width: 100%;">
    <tr>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Remote veri</h4>
            <img src="https://github.com/user-attachments/assets/52fa83ec-87d5-43f9-81bb-35ddfc7ffdf2" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Local veri<</h4>
            <img src="https://github.com/user-attachments/assets/6a7baefd-ff26-4066-af17-b815533a8e19" style="width: 100%; height: auto;">
        </td>
    </tr>
</table>
  </details> 

import Alamofire

protocol MusicLibraryDataProviderDelegate: AnyObject {
    func didFinish(trackList: [SongInfo])
}

protocol MusicLibraryDataProviderProtocol {
    func start()
    func update(searchText: String?)
    func loadNext()
    func reset()
}

class MusicLibraryDataProvider {
    
    // MARK: - Constants
    
    struct Constants {
        static let emptyResponseCodes: Set<Int> = [200, 204, 205, 403]
        static let defaultSearchString: String = "hello"
        static let defaultMusicLibraryQuery: String = "https://itunes.apple.com/search?term=hello&limit=25"
        static let limit: Int = 25
    }
    
    
    // MARK: - Properties
    
    weak var delegate: MusicLibraryDataProviderDelegate?
    private var offset: Int = .zero
    private var searchText: String = Constants.defaultSearchString
    private var songInfo: [SongInfo] = []
    
    
    // MARK: - Private methods
    
    private func getURL(songTitle: String) -> String {
        let formattedSongTitle = songTitle.replacingOccurrences(of: " ", with: "_")
        let url = "https://itunes.apple.com/search?term=\(formattedSongTitle)&limit=25&offset=\(offset)"
        
        return url
    }
    
    private func getData(url: String) {
        AF.request(url, 
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: nil).validate().responseData(emptyResponseCodes: Constants.emptyResponseCodes) 
        { [weak self] response in
            guard let self else {
                return
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(TrackList.self, from: data)
                    self.deleteRepeatSongs(newSongArray: json.results.filter { $0.kind == .song })
                    self.delegate?.didFinish(trackList: self.songInfo)
                } catch {
                    print(error)
                }
            case .failure(let error):
                if self.offset >= Constants.limit {
                    self.offset -= Constants.limit
                }
                
                if (response.data?.count ?? .zero) > .zero {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func deleteRepeatSongs(newSongArray: [SongInfo]) {
        var tempNewSongArray = newSongArray
        
        tempNewSongArray.removeAll { [weak self] song in
            guard let self else {
                return false
            }
            
            if self.songInfo.contains(song) {
                return true
            } else {
                return false
            }
        }
        
        songInfo.append(contentsOf: tempNewSongArray)
    }
    
}


// MARK: - Extension

extension MusicLibraryDataProvider: MusicLibraryDataProviderProtocol {
    
    // MARK: - MusicLibraryDataProviderProtocol
    
    func start() {
        getData(url: Constants.defaultMusicLibraryQuery)
    }
    
    func update(searchText: String?) {
        guard let searchText else {
            return
        }
        
        songInfo = []
        offset = .zero
        self.searchText = searchText
        getData(url: getURL(songTitle: searchText))
    }
    
    func loadNext() {
        offset += Constants.limit
        getData(url: getURL(songTitle: searchText))
    }
    
    func reset() {
        songInfo = []
        offset = .zero
        searchText = Constants.defaultSearchString
        getData(url: getURL(songTitle: searchText))
    }
    
}

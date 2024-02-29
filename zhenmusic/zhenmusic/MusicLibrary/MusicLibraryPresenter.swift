class MusicLibraryPresenter {
    
    // MARK: - Properties
    
    weak var view: MusicLibraryView?
    
    private var dataProvider: MusicLibraryDataProvider?
    private var searchedURL = "https://itunes.apple.com/search?term=hello"
    
    
    // MARK: - Init
    
    init(view: MusicLibraryView) {
        self.view = view
        
        self.view?.viewDidLoadView = { [weak self] in
            self?.view?.loadingStatus(isHidden: false)
            self?.start()
        }
    }
    
    
    // MARK: - Private methods
    
    private func start() {
        setUpCallbacks()
        setUpDataProvider()
    }
    
    private func setUpCallbacks() {
        view?.didSearch = { [weak self] requestedSong in
            self?.view?.loadingStatus(isHidden: false)
            self?.dataProvider?.update(searchText: requestedSong)
        }
        
        view?.didTapCancelButton = { [weak self] in
            self?.dataProvider?.reset()
        }
        
        view?.didScrollToEnd = { [weak self] in
            self?.dataProvider?.loadNext()
        }
    }
    
    private func setUpDataProvider() {
        let dataProvider = MusicLibraryDataProvider()
        dataProvider.delegate = self
        self.dataProvider = dataProvider
        self.dataProvider?.start()
    }
    
}


// MARK: - Extension

extension MusicLibraryPresenter: MusicLibraryDataProviderDelegate {
    
    // MARK: - MusicLibraryDataProviderDelegate
    
    func didFinish(trackList: [SongInfo]) {
        view?.display(viewModel: trackList)
        view?.loadingStatus(isHidden: true)
    }
    
}

import UIKit
import SnapKit

protocol MusicLibraryView: UIViewController {
    var viewDidLoadView: (() -> Void)? { get set }
    var didSearch: ((String) -> Void)? { get set }
    var didTapCancelButton: (() -> Void)? { get set }
    var didScrollToEnd: (() -> Void)? { get set }
    
    func display(viewModel: [SongInfo])
    func loadingStatus(isHidden: Bool)
}

class MusicLibraryViewController: UIViewController, ViewProtocol {
    
    // MARK: - Constants
    
    struct Constants {
        static let tableViewCellHeight: CGFloat = 60
        static let searchTableViewTopOffset: CGFloat = 160
        static let titleLabelFontSize: CGFloat = 32
    }

    
    // MARK: - Callbacks
    
    var retain: Any?
    var viewDidLoadView: (() -> Void)?
    var didSearch: ((String) -> Void)?
    var didTapCancelButton: (() -> Void)?
    var didScrollToEnd: (() -> Void)?
    
    
    // MARK: - Properties
    
    private lazy var titleLabel = UILabel()
    private lazy var searchTableView = UITableView()
    private lazy var musicSearchBar = UISearchBar()
    private lazy var loadingIndicator = UIActivityIndicatorView()
    private lazy var loadingView = UIView()
    private lazy var identifier: String = "cell"
    private var tracklistInfo: [SongInfo]?
    
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if tracklistInfo == nil {
            viewDidLoadView?()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutSubviews()
    }
    
    
    // MARK: - Private methods
    
    private func setupViews() {
        view.addSubview(searchTableView)
        view.addSubview(musicSearchBar)
        view.addSubview(titleLabel)
        view.addSubview(loadingView)
        loadingView.addSubview(loadingIndicator)
        
        view.backgroundColor = .white
        
        let backButton = UIBarButtonItem()
        navigationItem.backBarButtonItem = backButton
        backButton.tintColor = .white
        backButton.title = "Назад"
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.register(MusicLibraryCell.self, forCellReuseIdentifier: identifier)

        musicSearchBar.placeholder = "Название песни..."
        musicSearchBar.searchBarStyle = .minimal
        musicSearchBar.showsSearchResultsButton = true
        musicSearchBar.delegate = self
        
        titleLabel.text = "Поиск"
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        titleLabel.font = .boldSystemFont(ofSize: Constants.titleLabelFontSize)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        
        loadingView.backgroundColor = .white
        loadingView.isHidden = true
        
        loadingIndicator.style = .large
    }
    
    private func layoutSubviews() {
        searchTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.searchTableViewTopOffset)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        musicSearchBar.snp.makeConstraints { make in
            make.bottom.equalTo(searchTableView.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalTo(searchTableView)
            make.height.width.equalTo(searchTableView)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(loadingView)
        }
        
    }

}


// MARK: - Extension

extension MusicLibraryViewController: MusicLibraryView {
    
    // MARK: - MusicLibraryView
    
    func display(viewModel: [SongInfo]) {
        tracklistInfo = viewModel
        searchTableView.reloadData()
    }
    
    func loadingStatus(isHidden: Bool) {
        loadingView.isHidden = isHidden
        if !loadingView.isHidden {
            loadingIndicator.startAnimating()
        }
    }
    
}

extension MusicLibraryViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let song = tracklistInfo?[indexPath.row] else {
            return
        }
        
        let viewModel = MusicPlayerViewController.Model(artistName: song.artistName,
                                                        trackName: song.trackName,
                                                        image: song.artworkUrl100,
                                                        trackPreview: song.previewUrl)
        
        let screen = ScreenManager().getMusicPlayerScreen(viewModel: viewModel)
        
        navigationController?.pushViewController(screen, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tracksArray = tracklistInfo else {
            return
        }
        
        if indexPath.row + 1 == tracksArray.count {
            didScrollToEnd?()
        }
    }
    
}

extension MusicLibraryViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tracksArray = tracklistInfo else {
            return .zero
        }
        return tracksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchTableView.dequeueReusableCell(withIdentifier: identifier) as? MusicLibraryCell,
              let song = tracklistInfo?[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.config(viewModel: MusicLibraryCell.Model(kind: song.kind,
                                                      artistName: song.artistName,
                                                      collectionName: song.collectionName,
                                                      trackName: song.trackName,
                                                      image: song.artworkUrl100))
        return cell
    }
    
}

extension MusicLibraryViewController: UISearchBarDelegate {
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let search = musicSearchBar.text, search.count >= 3 else {
            return
        }
        
        didSearch?(search)
        self.musicSearchBar.endEditing(true)
    } 
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == .zero {
            didTapCancelButton?()
            self.musicSearchBar.endEditing(true)
        }
    }
    
}

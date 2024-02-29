import UIKit

class ScreenManager {
    
    private let masterNavigation = UINavigationController()
    private var screen: MusicLibraryScreen?
    private var playerScreen: MusicPlayerScreen?
    
    func getRootScreen() -> UINavigationController {
        let musicLibraryVC = MusicLibraryViewController()
        let musicLibraryPresenter = MusicLibraryPresenter(view: musicLibraryVC)
        screen = MusicLibraryScreen(view: musicLibraryVC, presenter: musicLibraryPresenter)
        masterNavigation.viewControllers = [musicLibraryVC]
        
        return masterNavigation
    }
    
    func getMusicPlayerScreen(viewModel: MusicPlayerViewController.Model) -> UIViewController {
        let musicPlayerVC = MusicPlayerViewController()
        let musicPLayerPresenter = MusicPlayerPresenter(view: musicPlayerVC)
        musicPLayerPresenter.config(viewModel: viewModel)
        playerScreen = MusicPlayerScreen(view: musicPlayerVC, presenter: musicPLayerPresenter)
        
        return musicPlayerVC
    }
    
}

class Screen<View: ViewProtocol, Presenter> {
    let view: View
    let presenter: Presenter
    
    public init(view: View, presenter: Presenter) {
        self.view = view
        self.presenter = presenter
        
        view.retain = presenter
    }
}

protocol ViewProtocol: UIViewController {
    var retain: Any? { get set }
} 

typealias MusicLibraryScreen = Screen<MusicLibraryViewController, MusicLibraryPresenter>
typealias MusicPlayerScreen = Screen<MusicPlayerViewController, MusicPlayerPresenter>

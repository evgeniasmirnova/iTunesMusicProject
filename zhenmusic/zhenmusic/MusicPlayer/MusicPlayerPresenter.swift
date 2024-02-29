import AVFoundation

class MusicPlayerPresenter {
    
    // MARK: - Properties
    
    weak var view: MusicPlayerView?
    private var audioPlayer: AVPlayer?
    private var viewModel: MusicPlayerViewController.Model?
    private var observer: NSKeyValueObservation?
    
    
    // MARK: - Init
    
    init(view: MusicPlayerView) {
        self.view = view
        
        self.view?.viewDidLoadView = { [weak self] in
            self?.start()
        }
    }
    
    
    // MARK: - Private methods
    
    private func start() {
        setUpCallbacks()
        updateView()
    }
    
    private func setUpCallbacks() {
        view?.didTapPlay = { [weak self] in
            self?.play()
        }
        
        view?.didTapPause = { [weak self] in
            self?.pause()
        }
        
        view?.didChangeVolume = { [weak self] newValue in
            self?.changeVolume(newValue: newValue)
        }
        
        view?.didChangeTrackTime = { [weak self] newValue in
            self?.changeTrackTime(newValue: newValue)
        }
        
        view?.viewDidDisappearCallback = { [weak self] in
            self?.pause()
        }
    }
    
    private func updateView() {
        guard let viewModel else {
            return
        }
        
        view?.showLoading(isHidden: false)
        view?.display(viewModel: viewModel)
    }
    
    private func initPlayer(trackURL: String?) {
        guard let trackURL,
              let url = URL(string: trackURL) else {
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        
        self.observer = playerItem.observe(\.status,
                                            options:  [.new],
                                            changeHandler: { [weak self] (playerItem, _) in
            if playerItem.status == .readyToPlay {
                self?.setTrackTime()
                self?.setMaxTime()
                self?.view?.showLoading(isHidden: true)
                self?.observer?.invalidate()
            }
        })
    }
    
    private func play() {
        audioPlayer?.play()
    }
    
    private func pause() {
        audioPlayer?.pause()
    }
    
    private func setTrackTime() {
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(didChangeTimer),
                             userInfo: nil,
                             repeats: true)
    }
    
    private func setMaxTime() {
        guard let currentItem = audioPlayer?.currentItem else {
            return
        }
        
        let maximumValue = Float(CMTimeGetSeconds(currentItem.duration))
        view?.setTrackTime(maximum: maximumValue)
    }
    
    private func changeVolume(newValue: Float) {
        audioPlayer?.volume = newValue
    }
    
    private func changeTrackTime(newValue: Float) {
        let cmTime = CMTimeMakeWithSeconds(Float64(newValue), preferredTimescale: 1000)
        audioPlayer?.seek(to: cmTime)
    }
    

    // MARK: - ObjC methods
    
    @objc
    func didChangeTimer() {
        guard let audioPlayer else {
            return
        }
        
        view?.setTime(currentTime: Float(CMTimeGetSeconds(audioPlayer.currentTime())))
    }
    
    @objc
    func didTrackStatusUpdate(status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            setMaxTime()
        default:
            break
        }
    }
    
    
    // MARK: - Methods
    
    func config(viewModel: MusicPlayerViewController.Model) {
        self.viewModel = viewModel
        initPlayer(trackURL: viewModel.trackPreview)
    }
    
}

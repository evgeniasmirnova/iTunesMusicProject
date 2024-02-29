import UIKit
import SnapKit
import Kingfisher

protocol MusicPlayerView: UIViewController {
    var viewDidLoadView: (() -> Void)? { get set }
    var didTapPlay: (() -> Void)? { get set }
    var didTapPause: (() -> Void)? { get set }
    var didChangeVolume: ((Float) -> Void)? { get set }
    var didChangeTrackTime: ((Float) -> Void)? { get set }
    var viewDidDisappearCallback: (() -> Void)? { get set }
    var stopLoading: (() -> Void)? { get set }
    
    func setTime(currentTime: Float)
    func setTrackTime(maximum: Float)
    func showLoading(isHidden: Bool)
    func display(viewModel: MusicPlayerViewController.Model)
}

class MusicPlayerViewController: UIViewController, ViewProtocol {
    
    // MARK: - Constants
    
    struct Constants {
        static let coverImageViewSize: CGFloat = 350
        static let coverImageViewTopOffset: CGFloat = 150
        static let buttonWidth: CGFloat = 30
        static let buttonHeight: CGFloat = 25
        static let timeLabelWidth: CGFloat = 50
        static let greatMargin: CGFloat = 36
        static let bigMargin: CGFloat = 24
        static let smallMargin: CGFloat = 12
        static let timeLabelHeight: CGFloat = 15
        static let volumeSliderWidth: CGFloat = 250
        static let slaiderBottomOffset: CGFloat = -45
        static let titleFontSize: CGFloat = 22
        static let subTitleFontSize: CGFloat = 14
        static let cornerRadius: CGFloat = 15
        static let borderWidth: CGFloat = 1.0
    }
    
    
    // MARK: - Callbacks
    
    var retain: Any?
    var viewDidLoadView: (() -> Void)?
    var didTapPlay: (() -> Void)?
    var didTapPause: (() -> Void)?
    var didChangeVolume: ((Float) -> Void)?
    var didChangeTrackTime: ((Float) -> Void)?
    var viewDidDisappearCallback: (() -> Void)?
    var stopLoading: (() -> Void)?
    
    
    // MARK: - Properties
    
    private lazy var coverImageView = UIImageView()
    private lazy var musicPlayerSlider = UISlider()
    private lazy var volumeSlider = UISlider()
    private lazy var authorLabel = UILabel()
    private lazy var songTitleLabel = UILabel()
    private lazy var favoriteButton = UIButton()
    private lazy var randomButton = UIButton()
    private lazy var thumbImage = UIImage(named: "minus")
    private lazy var playImage = UIImage(named: "play")
    private lazy var pauseImage = UIImage(named: "pause")
    private lazy var forwardImage = UIImage(named: "forward")
    private lazy var rewindImage = UIImage(named: "rewind")
    private lazy var favoriteImage = UIImage(named: "favorite")
    private lazy var highVolumeImage = UIImage(named: "high-volume")
    private lazy var lowVolumeImage = UIImage(named: "low-volume")
    private lazy var randomImage = UIImage(named: "random")
    private lazy var favoriteSelectedImage = UIImage(named: "favorite-selected")
    private lazy var playButton = UIButton(type: .custom)
    private lazy var forwardButton = UIButton(type: .custom)
    private lazy var rewindButton = UIButton(type: .custom)
    private lazy var leftTimeLabel = UILabel()
    private lazy var rightTimeLabel = UILabel()
    private lazy var loadingIndicator = UIActivityIndicatorView()
    private lazy var loadingView = UIView()
    private lazy var backgroundView: UIView = {
        let view = UIView()
        let colorTop = UIColor.clear.cgColor
        let colorBottom = UIColor.black.cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds

        view.layer.insertSublayer(gradientLayer, at: .zero)
        view.alpha = 0.5
        
        return view
    }()
    
    
    // MARK: - Model
    
    struct Model {
        let artistName: String
        let trackName: String?
        let image: String?
        let trackPreview: String?
    }
    
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewDidLoadView?()
        showLoading(isHidden: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewDidDisappearCallback?()
    }
    
    
    // MARK: - Private methods
    
    private func layoutSubviews() {
        backgroundView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        coverImageView.snp.makeConstraints { make in
            make.height.equalTo(Constants.coverImageViewSize)
            make.width.equalTo(Constants.coverImageViewSize)
            make.top.equalToSuperview().offset(Constants.coverImageViewTopOffset)
            make.centerX.equalToSuperview()
        }
        
        musicPlayerSlider.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Constants.timeLabelWidth)
            make.width.equalTo(Constants.coverImageViewSize)
            make.top.equalTo(authorLabel.snp.bottom).offset(Constants.bigMargin)
        }
        
        songTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(Constants.coverImageViewSize)
            make.top.equalTo(coverImageView.snp.bottom).offset(Constants.greatMargin)
            make.centerX.equalToSuperview()
        }
        
        authorLabel.snp.makeConstraints { make in
            make.width.equalTo(Constants.coverImageViewSize)
            make.top.equalTo(songTitleLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        playButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(Constants.buttonWidth)
            make.top.equalTo(musicPlayerSlider.snp.bottom).offset(Constants.bigMargin)
        }
        
        forwardButton.snp.makeConstraints { make in
            make.height.width.equalTo(Constants.buttonWidth)
            make.top.equalTo(playButton)
            make.left.equalTo(playButton.snp.right).offset(Constants.greatMargin)
        }
        
        rewindButton.snp.makeConstraints { make in
            make.height.width.equalTo(Constants.buttonWidth)
            make.top.equalTo(playButton)
            make.right.equalTo(playButton.snp.left).offset(-Constants.greatMargin)
        }
        
        volumeSlider.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(Constants.slaiderBottomOffset)
            make.centerX.equalToSuperview()
            make.width.equalTo(Constants.volumeSliderWidth)
            make.height.equalTo(Constants.buttonHeight)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(songTitleLabel.snp.bottom)
            make.height.width.equalTo(Constants.buttonHeight)
            make.right.equalTo(randomButton.snp.left).offset(-Constants.smallMargin)
        }
        
        randomButton.snp.makeConstraints { make in
            make.top.equalTo(favoriteButton)
            make.height.width.equalTo(Constants.buttonHeight)
            make.right.equalToSuperview().offset(-Constants.bigMargin)
        }
        
        leftTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(musicPlayerSlider.snp.bottom).offset(-Constants.smallMargin)
            make.left.equalTo(musicPlayerSlider)
            make.width.equalTo(Constants.timeLabelWidth)
            make.height.equalTo(Constants.timeLabelHeight)
        }
        
        rightTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(musicPlayerSlider.snp.bottom).offset(-Constants.smallMargin)
            make.right.equalTo(musicPlayerSlider)
            make.width.equalTo(Constants.timeLabelWidth)
            make.height.equalTo(Constants.timeLabelHeight)
        }
        
        loadingView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setUpViews() {
        view.addSubview(backgroundView)
        view.addSubview(coverImageView)
        view.addSubview(authorLabel)
        view.addSubview(songTitleLabel)
        view.addSubview(musicPlayerSlider)
        view.addSubview(playButton)
        view.addSubview(forwardButton)
        view.addSubview(rewindButton)
        view.addSubview(volumeSlider)
        view.addSubview(favoriteButton)
        view.addSubview(randomButton)
        view.addSubview(leftTimeLabel)
        view.addSubview(rightTimeLabel)
        view.addSubview(loadingView)
        loadingView.addSubview(loadingIndicator)
        
        view.backgroundColor = .white
        
        coverImageView.layer.cornerRadius = Constants.cornerRadius
        coverImageView.layer.masksToBounds = false
        coverImageView.layer.borderWidth = Constants.borderWidth
        coverImageView.layer.borderColor = UIColor.clear.cgColor
        coverImageView.clipsToBounds = true
        
        songTitleLabel.textColor = .white
        songTitleLabel.textAlignment = .left
        songTitleLabel.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        
        authorLabel.textColor = .white
        authorLabel.textAlignment = .left
        authorLabel.font = .systemFont(ofSize: Constants.titleFontSize)
        
        musicPlayerSlider.setThumbImage(UIImage(), for: .normal)
        musicPlayerSlider.maximumTrackTintColor = .lightGray
        musicPlayerSlider.minimumTrackTintColor = .white
        musicPlayerSlider.addTarget(self, action: #selector(didChangeTimeValue), for: .valueChanged)
        
        volumeSlider.setThumbImage(UIImage(), for: .normal)
        volumeSlider.maximumTrackTintColor = .lightGray
        volumeSlider.minimumTrackTintColor = .white
        volumeSlider.minimumValueImage = lowVolumeImage
        volumeSlider.maximumValueImage = highVolumeImage
        volumeSlider.value = 0.5
        volumeSlider.addTarget(self, action: #selector(didChangeVolumeValue), for: .valueChanged)
        
        playButton.setImage(playImage, for: .normal)
        playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        
        forwardButton.setImage(forwardImage, for: .normal)
        rewindButton.setImage(rewindImage, for: .normal)
        
        favoriteButton.setImage(favoriteImage, for: .normal)
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        
        randomButton.setImage(randomImage, for: .normal)
        
        leftTimeLabel.textAlignment = .left
        leftTimeLabel.textColor = .white
        leftTimeLabel.font = .systemFont(ofSize: Constants.subTitleFontSize)
        
        rightTimeLabel.textAlignment = .right
        rightTimeLabel.textColor = .white
        rightTimeLabel.font = .systemFont(ofSize: Constants.subTitleFontSize)
        
        loadingView.backgroundColor = .white
        loadingView.isHidden = true
        
        loadingIndicator.style = .large
    }
    
    
    // MARK: - Methods
    
    func display(viewModel: Model) {
        guard let image = viewModel.image?.replacingOccurrences(of: "100x100", 
                                                                with: "400x400") else {
            return
        }
        
        let url = URL(string: image)
        coverImageView.kf.setImage(with: url) { [weak self] _ in
            DispatchQueue.main.async {
                self?.view.backgroundColor = self?.coverImageView.image?.averageColor
            }
        }
        
        songTitleLabel.text = viewModel.trackName
        authorLabel.text = viewModel.artistName
    }
    

    // MARK: - ObjC methods

    @objc
    func didTapPlayButton() {
        if playButton.currentImage == playImage {
            playButton.setImage(pauseImage, for: .normal)
            didTapPlay?()
        } else {
            playButton.setImage(playImage, for: .normal)
            didTapPause?()
        }
    }
    
    @objc
    func didTapFavorite() {
        if favoriteButton.currentImage == favoriteImage {
            favoriteButton.setImage(favoriteSelectedImage, for: .normal)
        } else {
            favoriteButton.setImage(favoriteImage, for: .normal)
        }
    }
    
    @objc
    func didChangeVolumeValue() {
        didChangeVolume?(volumeSlider.value)
    }
    
    @objc
    func didChangeTimeValue() {
        didChangeTrackTime?(musicPlayerSlider.value)
    }

}


// MARK: - Extensions

extension MusicPlayerViewController: MusicPlayerView {
    
    // MARK: - MusicPlayerView
    
    func setTime(currentTime: Float) {
        musicPlayerSlider.value = currentTime
        if currentTime < 10 {
            leftTimeLabel.text = "00:0\(Int(round(currentTime)))"
        } else {
            leftTimeLabel.text = "00:\(Int(round(currentTime)))"
        }
    }
    
    func setTrackTime(maximum: Float) {
        musicPlayerSlider.minimumValue = .zero
        musicPlayerSlider.maximumValue = maximum
        rightTimeLabel.text = "00:\(Int(round(maximum)))"
    }
    
    func showLoading(isHidden: Bool) {
        loadingView.isHidden = isHidden
        if !loadingView.isHidden {
            loadingIndicator.startAnimating()
        }
    }
    
}

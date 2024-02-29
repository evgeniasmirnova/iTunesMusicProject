import UIKit
import SnapKit
import Kingfisher

class MusicLibraryCell: UITableViewCell {
    
    // MARK: - Constants
    
    struct Constants {
        static let smallOffset: CGFloat = 12
        static let coverImageViewSize: CGFloat = 45
        static let coverImageViewTopOffset: CGFloat = 8
        static let titleLabelFontSize: CGFloat = 15
        static let cornerRadius: CGFloat = 5
        static let borderWidth: CGFloat = 1.0
    }
    
    // MARK: - Properties
    
    private lazy var titleLabel = UILabel()
    private lazy var artistAndAlbumLabel = UILabel()
    private lazy var coverImageView = UIImageView()
    
    
    // MARK: - Model
    
    struct Model {
        let kind: Kind?
        let artistName: String
        let collectionName: String?
        let trackName: String?
        let image: String?
    }
    
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.smallOffset)
            make.left.equalTo(coverImageView.snp.right).offset(Constants.smallOffset)
            make.right.equalToSuperview().offset(-Constants.smallOffset)
        }
        
        artistAndAlbumLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Constants.smallOffset)
            make.left.equalTo(coverImageView.snp.right).offset(Constants.smallOffset)
            make.right.equalToSuperview().offset(-Constants.smallOffset)
        }
        
        coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Constants.smallOffset)
            make.top.equalToSuperview().offset(Constants.coverImageViewTopOffset)
            make.size.equalTo(Constants.coverImageViewSize)
        }
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(artistAndAlbumLabel)
        addSubview(coverImageView)
        
        titleLabel.textAlignment = .left
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: Constants.titleLabelFontSize)
        titleLabel.lineBreakMode = .byTruncatingTail
        
        artistAndAlbumLabel.textAlignment = .left
        artistAndAlbumLabel.textColor = .darkGray
        artistAndAlbumLabel.font = .systemFont(ofSize: Constants.titleLabelFontSize)
        artistAndAlbumLabel.lineBreakMode = .byTruncatingTail
        
        coverImageView.layer.cornerRadius = Constants.cornerRadius
        coverImageView.layer.masksToBounds = false
        coverImageView.layer.borderWidth = Constants.borderWidth
        coverImageView.layer.borderColor = UIColor.clear.cgColor
        coverImageView.clipsToBounds = true
    }
    
    
    // MARK: - Methods
    
    func config(viewModel: Model) {
        titleLabel.text = viewModel.trackName
        
        artistAndAlbumLabel.text = "\(viewModel.artistName) \u{2022} \(viewModel.collectionName ?? "")"
        
        if let image = viewModel.image {
            let url = URL(string: image)
            coverImageView.kf.setImage(with: url)
        }
    }
    
}

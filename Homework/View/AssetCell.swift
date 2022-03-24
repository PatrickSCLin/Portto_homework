//
//  AssetCell.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/22.
//

import Kingfisher
import UIKit

class AssetCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        return $0
    }(UIImageView())
    
    lazy var nameLabel: UILabel = {
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    // MARK: Public Methods
    
    func bind(_ info: AssetInfo) {
        let url = try? info.image_url?.asURL()
        imageView.kf.setImage(with: url)
        nameLabel.text = info.name
    }
    
    // MARK: Private Methods
    
    private func setupStyle() {
        contentView.layer.borderColor = UIColor.darkGray.cgColor
        contentView.layer.borderWidth = 1
    }
    
    private func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: Init Methods
    
    override func prepareForReuse() {
        imageView.image = nil
        nameLabel.text = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStyle()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

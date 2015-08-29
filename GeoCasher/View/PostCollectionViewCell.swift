//
//  PostCollectionViewCell.swift
//  GeoCasher
//
//  Created by Jeremy Lawrence on 8/29/15.
//  Copyright © 2015 Ziewvater. All rights reserved.
//

import UIKit
import Alamofire

/// Collection view cell that displays image and location information for a Post
class PostCollectionViewCell: UICollectionViewCell {
    
    weak var imageView: UIImageView!
    weak var locationNameLabel: UILabel!
    
    // MARK: - UICollectionViewCell
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .whiteColor()
        
        let imageView = UIImageView(frame: bounds)
        contentView.addSubview(imageView)
        imageView.contentMode = .ScaleAspectFit
        imageView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
        self.imageView = imageView
        
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFontOfSize(14) // Made size 14 instead of 10 for legibility. 10 was too small, seemed out of place
        nameLabel.textColor = .whiteColor()
        contentView.addSubview(nameLabel)
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self).offset(20)
            make.bottom.equalTo(self).offset(-20)
        }
        self.locationNameLabel = nameLabel
        
        let gradient = GradientBackingView()
        contentView.insertSubview(gradient, belowSubview: nameLabel)
        gradient.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel).offset(-nameLabel.font.pointSize)
            make.left.right.bottom.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        // initWithCoder used for archiving/initialization from storyboard. Not implemented for this example but declaration needed to avoid compiler error
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    // MARK: - View setup
    
    func setUpWithPost(post: Post) {
        locationNameLabel.text = post.location.name
        Alamofire.request(.GET, post.imageURL).response { [weak self] (request, response, data, error) in
                self?.imageView.image = UIImage(data: data!, scale:1)
        }
    }
}

/// Acts as a backdrop for light-colored text labels. Intended to boost legibility of text over images.
class GradientBackingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clearColor().CGColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.85).CGColor
        ]
        gradient.locations = [0, 0.35, 1]
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }
}

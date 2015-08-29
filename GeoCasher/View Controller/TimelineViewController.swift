//
//  TimelineViewController.swift
//  GeoCasher
//
//  Created by Jeremy Lawrence on 8/27/15.
//  Copyright © 2015 Ziewvater. All rights reserved.
//

import UIKit
import SnapKit

let HeaderFontSize: CGFloat = 14
let PostCollectionViewCellIdentifier = "PostCell"

class TimelineViewController: UIViewController {

    var header: UIView!
    var collectionView: UICollectionView!
    
    var posts = [Post]()
    
    override func loadView() {
        super.loadView()
        
        // Header and header label
        header = UIView()
        header.backgroundColor = .whiteColor()
        view.addSubview(header)
        header.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(topLayoutGuide)
            make.leading.equalTo(view.snp_leading)
            make.trailing.equalTo(view.snp_trailing)
            make.height.equalTo(100)
        }
        let titleLabel = UILabel()
        titleLabel.text = "GeoCasher"
        titleLabel.font = UIFont.systemFontOfSize(HeaderFontSize)
        header.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(header).offset(CGPoint(x: 0,
                y: CGRectGetMaxY(UIApplication.sharedApplication().statusBarFrame)))
        }
        
        // Collection View
        let flowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRectNull, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(header.snp_bottom)
            make.bottom.equalTo(bottomLayoutGuide)
            make.left.right.equalTo(view)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.registerClass(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCellIdentifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImageFetcher.fetchPosts({ [weak self] (posts: [Post]) in
            self?.posts = posts
            self?.collectionView.reloadData()
            }, errorHandler: { (error) in
                NSLog("Error fetching posts: \(error)")
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
            appWindowWidth = UIApplication.sharedApplication().keyWindow?.bounds.width else {
                NSLog("No window? Something is wrong")
                return
        }
        flowLayout.itemSize = CGSize(width: appWindowWidth, height: appWindowWidth)
    }
}

extension TimelineViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PostCollectionViewCellIdentifier, forIndexPath: indexPath) as? PostCollectionViewCell else {
            return UICollectionViewCell()
        }
        let post = posts[indexPath.item]
        cell.setUpWithPost(post)
        return cell
    }
}

extension TimelineViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let post = posts[indexPath.item]
        let postLocationVC = PostLocationViewController()
        postLocationVC.post = post
        let nav = UINavigationController(rootViewController: postLocationVC)
        presentViewController(nav, animated: true, completion: nil)
    }
}

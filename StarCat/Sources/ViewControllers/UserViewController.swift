//
//  UserViewController.swift
//  StarCat
//
//  Created by Ryohei Ikegami on 2016/01/10.
//  Copyright © 2016年 seanchas116. All rights reserved.
//

import UIKit
import RxSwift

class UserViewController: UITableViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var homepageLabel: UILabel!
    @IBOutlet weak var followButton: RoundButton!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    var userSummary: UserSummary?
    let viewModel = UserViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.avatarImage.bindTo(avatarImageView.rx_image).addDisposableTo(disposeBag)
        viewModel.name.bindTo(nameLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.login.bindTo(loginLabel.rx_text).addDisposableTo(disposeBag)
        
        viewModel.location.map { $0 ?? "" }.bindTo(locationLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.location.map { $0 == nil }.bindTo(locationLabel.rx_hidden).addDisposableTo(disposeBag)
        viewModel.homepage.map { $0?.URLString ?? "" }.bindTo(homepageLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.homepage.map { $0 == nil }.bindTo(locationLabel.rx_hidden).addDisposableTo(disposeBag)
        
        viewModel.followersCount.map { String($0) }.bindTo(followersLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.followingCount.map { String($0) }.bindTo(followingLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.starsCount.map { String($0) }.bindTo(starsLabel.rx_text).addDisposableTo(disposeBag)
        
        if let summary = userSummary {
            viewModel.setSummary(summary)
            viewModel.load().then {
                self.tableView.layoutIfNeeded()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

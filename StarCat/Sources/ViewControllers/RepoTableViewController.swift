//
//  RepoTableViewController.swift
//  StarCat
//
//  Created by Ryohei Ikegami on 2016/01/17.
//  Copyright © 2016年 seanchas116. All rights reserved.
//

import UIKit
import Wirework

class RepoTableViewController: UITableViewController {
    
    var pagination: Pagination<RepoViewModel>!
    var paginator: TableViewPaginator<RepoViewModel>!
    let bag = SubscriptionBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(UINib(nibName: "RepoCell", bundle: nil), forCellReuseIdentifier: "RepoCell")
        
        paginator = TableViewPaginator<RepoViewModel>(
            tableViewController: self,
            pagination: pagination,
            cellIdentifier: "RepoCell"
        ) { [weak self] row, elem, cell in
            let repoCell = cell as! RepoCell
            repoCell.viewModel.repo.value = elem.repo.value
            repoCell.onActorTapped = { actor in
                self?.navigationController?.pushStoryboard("User", animated: true) { next in
                    (next as! UserViewController).userSummary = actor
                }
            }
        }
        paginator.whenSelected.subscribe { [unowned self] repoVM in
            if let repo = repoVM?.repo.value {
                self.navigationController?.pushRepo(repo)
            }
        }.addTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

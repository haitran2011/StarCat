//
//  UserViewModel.swift
//  StarCat
//
//  Created by Ryohei Ikegami on 2016/01/10.
//  Copyright © 2016年 seanchas116. All rights reserved.
//

import Foundation
import Wirework
import Haneke
import PromiseKit

class UserRepoPagination: Pagination<RepoViewModel> {
    var userName: String?
    
    override func fetch(page: Int) -> Promise<[RepoViewModel]> {
        if let userName = userName {
            return SearchRepoRequest(query: "user:\(userName)", sort: .Stars, perPage: 30, page: page).send()
                .then { repos in repos.map { repo in RepoViewModel(repo: repo) } }
        } else {
            return Promise([])
        }
    }
}

class UserViewModel {
    let user = Variable<User?>(nil)
    let summary = Variable<UserSummary?>(nil)
    let name: Property<String>
    let avatarImage: Property<UIImage?>
    let login: Property<String>
    let location: Property<String?>
    let homepage: Property<Link?>
    let followersCount: Property<Int>
    let followingCount: Property<Int>
    let starsCount: Property<Int>
    let githubURL: Property<Link?>
    
    let bag = SubscriptionBag()
    
    init() {
        let summary = combine(user, self.summary) { $0?.summary ?? $1 }
        login = summary.map { $0?.login ?? "" }
        name = user.map { $0?.name ?? "" }
        avatarImage = summary.mapAsync(nil) { summary -> Promise<UIImage?> in
            if let summary = summary {
                return Shared.imageCache.fetch(URL: summary.avatarURL.URL).promise().then { $0 }
            } else {
                return Promise(nil)
            }
        }
        location = user.map { $0?.location }
        homepage = user.map { $0?.blog }
        followersCount = user.map { $0?.followers ?? 0 }
        followingCount = user.map { $0?.following ?? 0 }
        starsCount = summary.mapAsync(0) { summary -> Promise<Int> in
            if let summary = summary {
                return GetUserStarsCountRequest(userName: summary.login).send()
            } else {
                return Promise(0)
            }
        }
        
        githubURL = login.map { Link(string: "https://github.com/\($0)") }
    }
    
    func load() -> Promise<Void> {
        return GetUserRequest(login: login.value).send().then { self.user.value = $0 }
    }
    
    func loadCurrentUser() -> Promise<Void> {
        return GetCurrentUserRequest().send().then { self.user.value = $0 }
    }
}
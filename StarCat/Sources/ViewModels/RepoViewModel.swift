//
//  RepoViewModel.swift
//  StarCat
//
//  Created by Ryohei Ikegami on 2015/12/28.
//  Copyright © 2015年 seanchas116. All rights reserved.
//

import Foundation
import Wirework
import Haneke
import SwiftDate
import PromiseKit

class RepoViewModel {
    let repo = Variable<Repo?>(nil)
    let name: Property<String>
    let fullName: Property<String>
    let starsCount = Variable(0)
    let starred = Variable(false)
    let description: Property<String>
    let language: Property<String?>
    let avatarImage: Property<UIImage?>
    let ownerName: Property<String>
    let homepage: Property<Link?>
    let pushedAt: Property<NSDate>
    let githubURL: Property<Link?>
    
    let event = Variable<Event?>(nil)
    let eventActor: Property<UserSummary?>
    let eventActorName: Property<String>
    let eventTime: Property<NSDate?>
    let readme = Variable<String>("")
    
    let bag = SubscriptionBag()
    
    init() {
        name = repo.map { $0?.name ?? "" }
        fullName = repo.map { $0?.fullName ?? "" }
        repo.map { $0?.starsCount ?? 0 }.bindTo(starsCount).addTo(bag)
        description = repo.map { $0?.description ?? "" }
        language = repo.map { $0?.language }
        ownerName = repo.map { $0?.owner.login ?? "" }
        homepage = repo.map { $0?.homepage }
        pushedAt = repo.map { $0?.pushedAt ?? NSDate() }
        githubURL = fullName.map { Link(string: "https://github.com/\($0)") }
        eventActor = event.map { event in
            event.flatMap { e -> UserSummary? in
                switch e.content {
                case .Star(let user, _):
                    return user
                default:
                    return nil
                }
            }
        }
        eventActorName = eventActor.map { $0?.login ?? "" }
        eventTime = event.map { $0?.createdAt }
        
        avatarImage = repo.mapAsync(nil) { (repo: Repo?) in
            if let repo = repo {
                return Shared.imageCache.fetch(URL: repo.owner.avatarURL.URL).promise().then { $0 }
            } else {
                return Promise(nil)
            }
        }
        
        repo.bindTo { [weak self] repo in
            if let fullName = repo?.fullName {
                CheckStarredRequest(repoName: fullName).send().then {
                    self?.starred.value = $0
                }
            }
        }.addTo(bag)
    }
    
    convenience init(repo: Repo) {
        self.init()
        self.repo.value = repo
    }
    
    func fetchReadme() {
        GetReadmeRequest(fullName: "\(ownerName.value)/\(name.value)").send()
            .then { readme in
                self.readme.value = readme
            }
    }
    
    func toggleStar() -> Promise<Void> {
        if let fullName = self.repo.value?.fullName {
            if self.starred.value {
                return RemoveStarRequest(repoName: fullName).send().then { _ -> Void in
                    self.starred.value = false
                    self.starsCount.value -= 1
                }
            } else {
                return AddStarRequest(repoName: fullName).send().then { _ -> Void in
                    self.starred.value = true
                    self.starsCount.value += 1
                }
            }
        }
        return Promise()
    }
}
//
//  User.swift
//  StarCat
//
//  Created by Ryohei Ikegami on 2016/01/10.
//  Copyright © 2016年 seanchas116. All rights reserved.
//

import Foundation

enum UserType {
    case user
    case organization
}

struct User {
    let type: UserType
    let id: Int
    let login: String
    let name: String?
    let avatarURL: URL
    let company: String?
    let location: String?
    let blog: URL?
    let email: String?
    let followers: Int
    let following: Int
    
    var summary: UserSummary {
        return UserSummary(id: id, login: login, avatarURL: avatarURL, type: type)
    }
}

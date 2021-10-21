//
//  RealmUser.swift
//  Realm-Backup-Sample
//
//  Created by 大西玲音 on 2021/10/21.
//

import RealmSwift

struct User {
    let name: String
}

final class RealmUser: Object {
    @objc dynamic var name: String = ""
}

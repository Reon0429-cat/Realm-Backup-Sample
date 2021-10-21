//
//  UserUseCase.swift
//  Realm-Backup-Sample
//
//  Created by 大西玲音 on 2021/10/21.
//

import RealmSwift

class UserUseCase {
    private var realm = try! Realm()
    private var objects: Results<RealmUser> {
        realm.objects(RealmUser.self)
    }
    var users: Results<RealmUser> {
        return objects
    }
    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    func delete(at index: Int) {
        let object = objects[index]
        try! realm.write {
            realm.delete(object)
        }
    }
    func createUser(name: String) {
        let user = RealmUser()
        user.name = name
        try! realm.write {
            realm.add(user)
        }
    }
    func backup(documentURL: URL) {
        do {
            realm.beginWrite()
            try realm.writeCopy(toFile: documentURL)
            realm.cancelWrite()
        } catch {
            print("DEBUG_PRINT: ", error.localizedDescription)
        }
    }
    func updateRealm(realm: Realm) {
        self.realm = realm
    }
}


//
//  UserUseCase.swift
//  Realm-Backup-Sample
//
//  Created by 大西玲音 on 2021/10/21.
//

import RealmSwift

final class UserUseCase {
    
    private var realm = try! Realm()
    private var objects: Results<RealmUser> {
        realm.objects(RealmUser.self)
    }
    
    var users: [User] {
        return objects.map { User(name: $0.name) }
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
    
    func getRealmFileURL() -> URL? {
        guard let fileURL = Realm.Configuration.defaultConfiguration.fileURL else {
            print("DEBUG_PRINT: ",
                  NSError(domain: "Realmのファイルパスが取得できませんでした。",
                          code: -1,
                          userInfo: nil)
            )
            return nil
        }
        return fileURL
    }
    
    func updateRealm(fileURL: URL) {
        do {
            let configuration = Realm.Configuration(fileURL: fileURL)
            Realm.Configuration.defaultConfiguration = configuration
            let realm = try Realm(configuration: configuration)
            self.realm = realm
        } catch {
            print("DEBUG_PRINT: ", error.localizedDescription)
        }
    }
    
}


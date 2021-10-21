//
//  ViewController.swift
//  Realm-Backup-Sample
//
//  Created by 大西玲音 on 2021/10/21.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let userUseCase = UserUseCase()
    private var users: Results<RealmUser> { userUseCase.users }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.nib,
                           forCellReuseIdentifier: CustomTableViewCell.identifier)
        
    }
    
    @IBAction func backup(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        let fileName = "TaskR_backup_file_" + formatter.string(from: Date()) + ".txt"
        let documentURL = try! FileManager.default.url(for: .documentDirectory,
                                                          in: .userDomainMask,
                                                          appropriateFor: nil,
                                                          create: true)
            .appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: documentURL)
        userUseCase.backup(documentURL: documentURL)
        let documentPickerVC = UIDocumentPickerViewController(
            forExporting: [documentURL],
            asCopy: true
        )
        documentPickerVC.modalPresentationStyle = .fullScreen
        present(documentPickerVC, animated: true)
    }
    
    @IBAction func restore(_ sender: Any) {
        let documentPickerVC = UIDocumentPickerViewController(forOpeningContentTypes: [.text],
                                                              asCopy: true)
        documentPickerVC.delegate = self
        documentPickerVC.allowsMultipleSelection = false
        documentPickerVC.modalPresentationStyle = .fullScreen
        present(documentPickerVC, animated: true)
    }
    
    @IBAction func createUser(_ sender: Any) {
        userUseCase.createUser(name: "reon\(userUseCase.users.count)")
        tableView.reloadData()
    }
}

extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            guard let realmFileURL = Realm.Configuration.defaultConfiguration.fileURL else {
                print("DEBUG_PRINT: ", NSError(domain: "Realmのファイルパスが取得できませんでした。", code: -1, userInfo: nil))
                return
            }
            let urlString = url.path.replacingOccurrences(of: ".txt", with: "")
            let sourceURLString = url.path
            let destinationString = NSString(
                string: NSString(
                    string: sourceURLString
                ).deletingLastPathComponent
            ).appendingPathComponent(
                NSString(
                    string: urlString
                ).lastPathComponent
            )
            do {
                // file:// をつけるためにfileURLWithPathでstring->URL
                if !FileManager.default.fileExists(atPath: destinationString) {
                    try FileManager.default.copyItem(at: URL(fileURLWithPath: sourceURLString),
                                                     to: URL(fileURLWithPath: destinationString))
                }
                try FileManager.default.removeItem(at: realmFileURL)
                try FileManager.default.copyItem(at: URL(fileURLWithPath: destinationString),
                                                 to: realmFileURL)
                let configuration = Realm.Configuration(fileURL: URL(fileURLWithPath: destinationString))
                Realm.Configuration.defaultConfiguration = configuration
                let realm = try! Realm(configuration: configuration)
                userUseCase.updateRealm(realm: realm)
            } catch {
                print("DEBUG_PRINT: ", error.localizedDescription)
            }
            tableView.reloadData()
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CustomTableViewCell.identifier
        ) as! CustomTableViewCell
        cell.tag = indexPath.row
        let user = users[indexPath.row]
        cell.configure(name: user.name) { row in
            self.userUseCase.delete(at: row)
            tableView.reloadData()
        }
        return cell
    }
    
}


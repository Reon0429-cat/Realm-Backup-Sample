//
//  ViewController.swift
//  Realm-Backup-Sample
//
//  Created by 大西 玲音 on 2021/10/21.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let userUseCase = UserUseCase()
    private var users: [User] { userUseCase.users }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
    }
    
}

// MARK: - func
private extension ViewController {
    
    func createFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        let fileName = "TaskR_backup_file_" + formatter.string(from: Date()) + ".txt"
        return fileName
    }
    
}

// MARK: - IBAction func
private extension ViewController {
    
    @IBAction func backup(_ sender: Any) {
        let fileName = createFileName()
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

// MARK: - UIDocumentPickerDelegate
extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let sourceURLPathString = url.path
        let destinationURLPathString = url.deletingPathExtension().path
        let sourceURL = URL(fileURLWithPath: sourceURLPathString)
        let destinationURL = URL(fileURLWithPath: destinationURLPathString)
        do {
            if !FileManager.default.fileExists(atPath: destinationURLPathString) {
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            }
            guard let realmFileURL = userUseCase.getRealmFileURL() else { return }
            try FileManager.default.removeItem(at: realmFileURL)
            try FileManager.default.copyItem(at: destinationURL, to: realmFileURL)
            userUseCase.updateRealm(fileURL: destinationURL)
        } catch {
            print("DEBUG_PRINT: ", error.localizedDescription)
        }
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return users.count
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

// MARK: - setup
private extension ViewController {
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.nib,
                           forCellReuseIdentifier: CustomTableViewCell.identifier)
    }
    
}

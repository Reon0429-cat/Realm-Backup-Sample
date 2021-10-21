//
//  CustomTableViewCell.swift
//  Realm-Backup-Sample
//
//  Created by 大西玲音 on 2021/10/21.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
    
    var deleteEvent: ((Int) -> Void)?
    
    func configure(name: String,
                   deleteEvent: @escaping ((Int) -> Void)) {
        self.deleteEvent = deleteEvent
        nameLabel.text = name
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        deleteEvent?(self.tag)
    }
    
}

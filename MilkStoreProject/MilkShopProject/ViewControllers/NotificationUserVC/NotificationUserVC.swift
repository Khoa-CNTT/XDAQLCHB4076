//
//  NotificationUserVC.swift
//  MilkShopProject
//
//  Created by CongDev on 11/5/25.
//

import UIKit

class NotificationUserVC: BaseViewController {

    @IBOutlet weak var notificationTbView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(notificationTbView, NotiTableCell.self)
    }
}

extension NotificationUserVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: NotiTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

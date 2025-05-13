//
//  ClientsVC.swift
//  MilkShopProject
//
//  Created by CongDev on 11/5/25.
//

import UIKit

class ClientsVC: BaseViewController {
    
    @IBOutlet weak var clientTableView: UITableView!
    
    private var users: [(name: String, phone: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(clientTableView, ClientCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAllUser()
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.back()
    }
    
    func fetchAllUser() {
        FirebaseDataFetcher.shared.fetchAllUsers { name, phone, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.users.append((name: name, phone: phone))
            
            DispatchQueue.main.async {
                self.clientTableView.reloadData()
            }
        }
    }
}

extension ClientsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ClientCell.self, for: indexPath)
        let user = users[indexPath.row]
        cell.configure(user.name, user.phone)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}



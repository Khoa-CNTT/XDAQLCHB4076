//
//  AddressVC.swift
//  MilkShopProject
//
//  Created by CongDev on 5/5/25.
//

import UIKit
import FirebaseAuth

protocol AddressVCDelegate: AnyObject {
    func callBackAddress(address: String)
}

class AddressVC: BaseViewController {
    
    @IBOutlet weak var addressTableView: UITableView!
    
    private var addresses: [String] = []
    weak var delegate: AddressVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(addressTableView, AddressCell.self)
        fetchAddress()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        self.back()
    }
    
    private func fetchAddress() {
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseDataFetcher().fetchUserAddresses(uid: uid) { addresses, error in
                if let addresses = addresses {
                    self.addresses = addresses
                    self.addressTableView.reloadData()
                } else if let error = error {
                    print("Lỗi khi lấy địa chỉ: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension AddressVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.isEmpty ? 1 : addresses.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: AddressCell.self, for: indexPath)
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        if isLastRow {
            cell.addAddressButton.isHidden = false
            cell.addressLabel.isHidden = true
        } else {
            cell.addAddressButton.isHidden = true
            cell.addressLabel.isHidden = false
            cell.addressLabel.text = addresses[indexPath.row]
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        if isLastRow {
            let vc = AddAddressVC()
            self.present(vc: vc)
        } else {
            self.delegate?.callBackAddress(address: addresses[indexPath.row])
            self.back()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        return isLastRow ? 66 : UITableView.automaticDimension
    }
}

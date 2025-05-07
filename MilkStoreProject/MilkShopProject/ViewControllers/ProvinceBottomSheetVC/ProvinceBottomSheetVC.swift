//
//  ProvinceBottomSheetVC.swift
//  MilkShopProject
//
//  Created by CongDev on 6/5/25.
//

import UIKit

enum SelectionType {
    case province
    case district
    case ward
}

class ProvinceBottomSheetVC: BaseViewController {
    
    @IBOutlet weak var nameProvinceLabel: UILabel!
    @IBOutlet weak var provinceTableView: UITableView!
    
    var items: [String] = []
    var selectionType: SelectionType = .province
    var onSelect: ((String) -> Void)?
    var selectedItem: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(provinceTableView, ProvinceCell.self)
    }
    
    override func setupUI() {
        switch selectionType {
        case .province:
             nameProvinceLabel.text = "Tỉnh/ Thành phố"
        case .district:
            nameProvinceLabel.text = "Quận/ Huyện"
        case .ward:
            nameProvinceLabel.text = "Phường/ Xã"
        }
    }
    
    @IBAction func didTapDimissButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension ProvinceBottomSheetVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ProvinceCell.self, for: indexPath)
        let name = items[indexPath.row]
        let isSelected = name == selectedItem
        cell.configure(name: name, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedValue = items[indexPath.row]
        selectedItem = selectedValue
        tableView.reloadData()
        onSelect?(selectedValue)
        dismiss(animated: true, completion: nil)
    }
}

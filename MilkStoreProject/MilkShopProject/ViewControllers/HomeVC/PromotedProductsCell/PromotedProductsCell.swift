//
//  PromotedProductsCell.swift
//  MilkShopProject
//
//  Created by CongDev on 7/4/25.
//

import UIKit

class PromotedProductsCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register product cell
        collectionView.register(nibWithCellClass: ProductsCell.self)
        
        // Setup horizontal scrolling
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 160, height: 220)
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    //        func configure(with products: [Product]) {
    //            self.products = products
    //            collectionView.reloadData()
    //        }
}

extension PromotedProductsCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ProductsCell.self, for: indexPath)
        //        cell.configure(with: products[indexPath.item])
        return cell
    }
}

//
//  RecommendedProductsCell.swift
//  MilkShopProject
//
//  Created by CongDev on 7/4/25.
//

import UIKit

class RecommendedProductsCell: UITableViewCell {
    
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
        
        // Setup grid layout with 2 items per row
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = (UIScreen.main.bounds.width - 48) / 2
            layout.itemSize = CGSize(width: width, height: 230)
            layout.minimumLineSpacing = 16
            layout.minimumInteritemSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }
    
//    func configure(with products: [Product]) {
//        self.products = products
//        collectionView.reloadData()
//    }
}

extension RecommendedProductsCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ProductsCell.self, for: indexPath)
//        cell.configure(with: products[indexPath.item])
        return cell
    }
}

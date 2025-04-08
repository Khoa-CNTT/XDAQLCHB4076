//
//  UICollectionVIew+.swift
//  AIPhotoProject

import Foundation
import UIKit

extension UICollectionView {
    
    private var layout: UICollectionViewFlowLayout {
        return self.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    public var itemSize: CGSize {
        get { return self.layout.estimatedItemSize }
        set { self.layout.estimatedItemSize = newValue }
    }
    
    public var minSpacing: (CGFloat, CGFloat) {
        get { return (self.layout.minimumInteritemSpacing, self.layout.minimumLineSpacing)}
        set {
            self.layout.minimumInteritemSpacing = newValue.0
            self.layout.minimumLineSpacing = newValue.1
        }
    }
    
    public var spacingForCell: CGFloat {
        get { return self.layout.minimumInteritemSpacing }
        set { self.layout.minimumInteritemSpacing = newValue }
    }
    
    public var spacingForLine: CGFloat {
        get { return self.layout.minimumLineSpacing }
        set { self.layout.minimumLineSpacing = newValue }
    }
    
    public var inset: UIEdgeInsets {
        get { return self.layout.sectionInset }
        set { self.layout.sectionInset = newValue }
    }
    
    public func dequeue<T: UICollectionViewCell>(aClass: T.Type, for indexPath: IndexPath) -> T? {
        let name = String(describing: aClass)
        return dequeueReusableCell(withReuseIdentifier: name, for: indexPath) as? T
    }
    
    public func cellForItem<T: UICollectionViewCell>(_ aClass: T.Type, for indexPath: IndexPath) -> T? {
        return cellForItem(at: indexPath) as? T
    }
    
    
    public func configure(_ viewController: UIViewController) {
        self.delegate = viewController as? UICollectionViewDelegate
        self.dataSource = viewController as? UICollectionViewDataSource
    }
    
    public func configure(_ cell: UITableViewCell) {
        self.delegate = cell as? UICollectionViewDelegate
        self.dataSource = cell as? UICollectionViewDataSource
    }
    
    public func configure(_ collectionViewCell: UICollectionViewCell) {
        self.delegate = collectionViewCell as? UICollectionViewDelegate
        self.dataSource = collectionViewCell as? UICollectionViewDataSource
    }
}

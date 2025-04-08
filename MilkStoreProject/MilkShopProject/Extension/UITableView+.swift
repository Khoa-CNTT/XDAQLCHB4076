//
//  UITableView+.swift
//  AIPhotoProject

import Foundation
import UIKit

extension UITableView {
    func register<T: UITableViewCell>(nibWithCellClass name: T.Type, at bundleClass: AnyClass? = nil) {
        let identifier = String(describing: name)
        var bundle: Bundle?

        if let bundleName = bundleClass {
            bundle = Bundle(for: bundleName)
        }

        register(UINib(nibName: identifier, bundle: bundle), forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError("Couldn't find UITableViewCell for \(String(describing: name)), make sure the cell is registered with table view")
        }
        return cell
    }
    
    enum Direction {
        case top
        case bottom
    }
    
    
    func scroll(to direction: Direction, animated: Bool) {
        if direction == .top {
            scrollToTopTableView(animated: animated)
        } else {
            scrollToBottomTableView(animated: animated)
        }
    }
    
    public func scrollToBottomTableView(animated: Bool) {
        DispatchQueue.main.async { [unowned self] in
            let indexPath = IndexPath(
                row: numberOfRows(inSection: numberOfSections-1) - 1,
                section: numberOfSections - 1)
            if hasRowAtIndexPath(indexPath: indexPath) {
                scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
    private func scrollToTopTableView(animated: Bool) {
        DispatchQueue.main.async { [unowned self] in
            let indexPath = IndexPath(row: 0, section: 0)
            if hasRowAtIndexPath(indexPath: indexPath) {
                scrollToRow(at: indexPath, at: .top, animated: animated)
            }
        }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}

extension UITableView {
    public func cellForRow<T: UITableViewCell>(_ aClass: T.Type, in indexPath: IndexPath) -> T? {
        return cellForRow(at: indexPath) as? T
    }
    
    public func register<T: UITableViewCell>(_ aClass: T.Type, bundle: Bundle? = nil) {
        let name = String(describing: aClass)
        let nib = UINib(nibName: name, bundle: bundle)
        register(nib, forCellReuseIdentifier: name)
    }
    
//    public func register<T: UITableViewCell>(_ aClass: T.Type) {
//        register(aClass.nib, forCellReuseIdentifier: aClass.identifier)
//    }
    
    public func register<T: UITableViewHeaderFooterView>(_ aClass: T.Type, bundle: Bundle? = nil) {
        let name = String(describing: aClass)
        let nib = UINib(nibName: name, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: name)
    }
    
    public func register<T: UITableViewHeaderFooterView>(aClass: T.Type) {
        let name = String(describing: aClass)
        register(aClass, forHeaderFooterViewReuseIdentifier: name)
    }
    
    public func dequeue<T: UITableViewCell>(_ aClass: T.Type) -> T? {
        let name = String(describing: aClass)
        return dequeueReusableCell(withIdentifier: name) as? T
    }
    
    public func dequeue<T: UITableViewHeaderFooterView>(_ aClass: T.Type) -> T? {
        let name = String(describing: aClass)
        return dequeueReusableHeaderFooterView(withIdentifier: name) as? T
    }
    
    public func dequeue<T: UITableViewCell>(_ aClass: T.Type, for indexPath: IndexPath) -> T? {
        let name = String(describing: aClass)
        return dequeueReusableCell(withIdentifier: name, for: indexPath) as? T
    }
    
    public func configure(_ viewController: UIViewController) {
        self.delegate = viewController as? UITableViewDelegate
        self.dataSource = viewController as? UITableViewDataSource
    }
    
    func showLoadingFooter(){
        let loadingFooter = UIActivityIndicatorView(style: .medium)
        loadingFooter.frame.size.height = 60
        loadingFooter.hidesWhenStopped = true
        loadingFooter.startAnimating()
        tableFooterView = loadingFooter
    }
    
    func hideLoadingFooter(){
        let tableContentSufficentlyTall = (contentSize.height > frame.size.height)
        let atBottomOfTable = (contentOffset.y >= contentSize.height - frame.size.height)
        if atBottomOfTable && tableContentSufficentlyTall {
            UIView.animate(withDuration: 0.2, animations: {
                self.contentOffset.y = self.contentOffset.y - 60
            }, completion: { finished in
                self.tableFooterView = UIView()
            })
        } else {
            self.tableFooterView = UIView()
        }
    }
    
    func isLoadingFooterShowing() -> Bool {
        return tableFooterView is UIActivityIndicatorView
    }
}



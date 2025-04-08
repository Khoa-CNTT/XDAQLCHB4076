//
//  HomeVC.swift
//  MilkShopProject
//
//  Created by CongDev on 30/3/25.
//

import UIKit
import JXPageControl

class HomeVC: BaseViewController {
    
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var pageController: JXPageControlScale!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var homeClsView: UICollectionView!
    
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            pageController.progress = CGFloat(currentPage)
        }
    }
    private var arrDataStep: [String] = [
        "imgOnboard_1",
        "imgOnboard_2"
    ]
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    override func setupUI() {
        handleSetupCollectionView()
        setupPageControl()
        setupAutoScroll()
    }
    
    private func handleSetupCollectionView() {
        self.homeClsView.register(nibWithCellClass: OnboardClsCell.self)
        self.homeClsView.dataSource = self
        self.homeClsView.delegate = self
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = arrDataStep.count
        pageController.numberOfPages = arrDataStep.count
        pageController.inactiveColor = .systemGray
        pageController.activeColor = .systemBlue
        pageController.activeSize = CGSize(width: 16, height: 8)
        pageController.inactiveSize = CGSize(width: 8, height: 8)
    }
    
    private func setupAutoScroll() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(autoScrollToNextItem), userInfo: nil, repeats: true)
    }
    
    @objc private func autoScrollToNextItem() {
        if currentPage < arrDataStep.count - 1 {
            currentPage += 1
        } else {
            currentPage = 0
        }
        
        let indexPath = IndexPath(item: currentPage, section: 0)
        homeClsView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func setupTableView() {
        productTableView.delegate = self
        productTableView.dataSource = self
        
        // Register cell types
        productTableView.register(cellWithClass: RecommendedProductsCell.self)
        productTableView.register(cellWithClass: PromotedProductsCell.self)
    }
    
    private func fetchData() {
        // Fill with your API call or mock data
    }
}

extension HomeVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: OnboardClsCell.self, for: indexPath)
        cell.onboardImageView.image = UIImage(named: arrDataStep[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.width
        let height = collectionView.height
        
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - TableView DataSource & Delegate
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withClass: PromotedProductsCell.self)
//            cell.configure(with: promotedProducts)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: RecommendedProductsCell.self)
//            cell.configure(with: recommendedProducts)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = section == 0 ? .white : UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 1.0)
        
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32, height: 50))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = section == 0 ? UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 1.0) : .white
        titleLabel.text = section == 0 ? "KHUYẾN MẠI NỔI BẬT" : "SẢN PHẨM DÀNH CHO BẠN"
        
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 240
        } else {

            let productCount = 10
            let rowCount = (productCount + 1) / 2
            return CGFloat(rowCount * 250)
        }
    }
}

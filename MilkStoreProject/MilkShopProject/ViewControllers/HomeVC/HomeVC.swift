//
//  HomeVC.swift
//  MilkShopProject
//
//  Created by CongDev on 30/3/25.
//

import UIKit
import JXPageControl

class HomeVC: BaseViewController {
    
    @IBOutlet weak var containerFreshMilkView: UIView!
    @IBOutlet weak var freshMilkClsView: UICollectionView!
    @IBOutlet weak var productPromotionClsView: UICollectionView!
    @IBOutlet weak var pageController: JXPageControlScale!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var homeClsView: UICollectionView!
    
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            pageController.progress = CGFloat(currentPage)
        }
    }
    private var arrDataStep: [String] = ["imgOnboard_1","imgOnboard_2"]
    var timer: Timer?
    var milk: Milks?
    private var freshMilkData: [DataMilk] = []
    private var promotionMilkData: [DataMilk] = []
    private var isDropwDownFreshMilkOpen: Bool = false {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        milk = loadMilksFromJSON()
        
        if let dataMilk = milk?.dataMilk {
            freshMilkData = dataMilk.filter { $0.type == "Sữa tươi" }
            promotionMilkData = dataMilk.filter { $0.type == "Sản phẩm khuyến mại" }
        }
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
    
    //MARK: Events
    @IBAction func didTapDropdownMenu(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            self.containerFreshMilkView.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        default:
            print("Default")
        }
    }
    
    //MARK: Method
    private func handleSetupCollectionView() {
        self.homeClsView.register(nibWithCellClass: OnboardClsCell.self)
        self.homeClsView.dataSource = self
        self.homeClsView.delegate = self
        
        self.productPromotionClsView.register(nibWithCellClass: ProductsCell.self)
        self.productPromotionClsView.dataSource = self
        self.productPromotionClsView.delegate = self
        
        self.freshMilkClsView.register(nibWithCellClass: ProductsCell.self)
        self.freshMilkClsView.dataSource = self
        self.freshMilkClsView.delegate = self
        
        // Trong handleSetupCollectionView()
        if let layout = freshMilkClsView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            freshMilkClsView.isPagingEnabled = true
            freshMilkClsView.decelerationRate = .fast
            freshMilkClsView.showsHorizontalScrollIndicator = false
        }
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
}

extension HomeVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case homeClsView:
            return 2
        case freshMilkClsView:
            return freshMilkData.count
        default:
            return promotionMilkData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case homeClsView:
            let cell = collectionView.dequeueReusableCell(withClass: OnboardClsCell.self, for: indexPath)
            cell.onboardImageView.image = UIImage(named: arrDataStep[indexPath.row])
            return cell
        case productPromotionClsView:
            let cell = collectionView.dequeueReusableCell(withClass: ProductsCell.self, for: indexPath)
            
            cell.configCell(products: promotionMilkData[indexPath.row])
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withClass: ProductsCell.self, for: indexPath)
            cell.configCell(products: freshMilkData[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case homeClsView:
            let width = collectionView.width
            let height = collectionView.height
            
            return CGSize(width: width, height: height)
        case productPromotionClsView:
            return CGSize(width: (UIScreen.main.bounds.width - 30) / 2, height: collectionView.height)
        default:
            let pageWidth = collectionView.frame.width
            let itemWidth = (pageWidth - 8) / 2
            let itemHeight = (collectionView.frame.height - 8) / 2
            
            return CGSize(width: itemWidth, height: itemHeight)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == freshMilkClsView else { return }

        let layout = freshMilkClsView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidth = layout.itemSize.width
        let spacing = layout.minimumLineSpacing
        
        // Calculate the width of 2 columns (not 4)
        let pageWidth = (cellWidth + spacing) * 2
        
        // Calculate which page to snap to
        let targetX = targetContentOffset.pointee.x
        let newTargetX = round(targetX / pageWidth) * pageWidth
        
        targetContentOffset.pointee = CGPoint(x: newTargetX, y: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}


//
//  HomeVC.swift
//  MilkShopProject
//
//  Created by CongDev on 30/3/25.
//

import UIKit
import JXPageControl

class HomeVC: BaseViewController {
    
    @IBOutlet weak var creamClsView: UICollectionView!
    @IBOutlet weak var fruitMilkDrinkClsView: UICollectionView!
    @IBOutlet weak var naturalFruitJuiceClsView: UICollectionView!
    @IBOutlet weak var naturalYogurtClsView: UICollectionView!
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
    private var freshMilkData: [DataMilkObject] = []
    private var promotionMilkData: [DataMilkObject] = []
    private var creamData: [DataMilkObject] = []
    private var naturalFruitJuices: [DataMilkObject] = []
    private var naturalYogurts: [DataMilkObject] = []
    private var fruitMilkDrinks: [DataMilkObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDataFromRealm()
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
    
    @IBAction func didTapCartButton(_ sender: Any) {
        let vc = CartVC()
        self.push(vc)
    }
    
    @IBAction func didTapSearchButton(_ sender: Any) {
        let vc = SearchProductVC()
        let nav = UINavigationController(rootViewController: vc)
        self.present(vc: nav)
    }
    
    //MARK: Method
    private func handleSetupCollectionView() {
        setUpCollectionView(homeClsView, OnboardClsCell.self)
        setUpCollectionView(productPromotionClsView, ProductsCell.self)
        setUpCollectionView(freshMilkClsView, ProductsCell.self)
        setUpCollectionView(naturalYogurtClsView, ProductsCell.self)
        setUpCollectionView(naturalFruitJuiceClsView, ProductsCell.self)
        setUpCollectionView(creamClsView, ProductsCell.self)
        setUpCollectionView(fruitMilkDrinkClsView, ProductsCell.self)
        
        let horizontalPagingCollections: [UICollectionView] = [
                freshMilkClsView,
                naturalYogurtClsView,
                naturalFruitJuiceClsView,
                fruitMilkDrinkClsView,
                creamClsView
            ]
        
        horizontalPagingCollections.forEach {  setupHorizontalPagingLayout(for:  $0 )}
    }
    
    private func setupHorizontalPagingLayout(for collectionView: UICollectionView) {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .zero
            
            collectionView.isPagingEnabled = true
            collectionView.decelerationRate = .fast
            collectionView.showsHorizontalScrollIndicator = false
        }
    }
    
    private func fetchDataFromRealm() {
        let dataMilkObject = RealmManager.shared.getAll(for: DataMilkObject.self)
        
        print("count: \(dataMilkObject.count)")
        freshMilkData = dataMilkObject.filter { $0.type == "Sữa tươi" }
        promotionMilkData = dataMilkObject.filter { $0.type == "Sản phẩm khuyến mại" }
        creamData = dataMilkObject.filter { $0.type == "Kem" }
        naturalYogurts = dataMilkObject.filter { $0.type == "Sữa chua tự nhiên" }
        naturalFruitJuices = dataMilkObject.filter { $0.type == "Nước trái cây tự nhiên" }
        fruitMilkDrinks = dataMilkObject.filter { $0.type == "Nước uống sữa trái cây" }
        
        DispatchQueue.main.async { [weak self] in
            self?.freshMilkClsView.reloadData()
            self?.productPromotionClsView.reloadData()
            self?.creamClsView.reloadData()
            self?.naturalYogurtClsView.reloadData()
            self?.naturalFruitJuiceClsView.reloadData()
            self?.fruitMilkDrinkClsView.reloadData()
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
        case naturalYogurtClsView:
            return naturalYogurts.count
        case naturalFruitJuiceClsView:
            return naturalFruitJuices.count
        case fruitMilkDrinkClsView:
            return fruitMilkDrinks.count
        case creamClsView:
            return creamData.count
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
        case freshMilkClsView:
            let cell = collectionView.dequeueReusableCell(withClass: ProductsCell.self, for: indexPath)
            cell.configCell(products: freshMilkData[indexPath.row])
            return cell
        case naturalYogurtClsView:
            let cell = collectionView.dequeueReusableCell(withClass: ProductsCell.self, for: indexPath)
            cell.configCell(products: naturalYogurts[indexPath.row])
            return cell
        case naturalFruitJuiceClsView:
            let cell = collectionView.dequeueReusableCell(withClass: ProductsCell.self, for: indexPath)
            cell.configCell(products: naturalFruitJuices[indexPath.row])
            return cell
        case fruitMilkDrinkClsView:
            let cell = collectionView.dequeueReusableCell(withClass: ProductsCell.self, for: indexPath)
            cell.configCell(products: fruitMilkDrinks[indexPath.row])
            return cell
        case creamClsView:
            let cell = collectionView.dequeueReusableCell(withClass: ProductsCell.self, for: indexPath)
            cell.configCell(products: creamData[indexPath.row])
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withClass: ProductsCell.self, for: indexPath)
            cell.configCell(products: promotionMilkData[indexPath.row])
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
            let itemWidth = (pageWidth) / 2
            let itemHeight = (collectionView.frame.height - 8) / 2
            
            return CGSize(width: itemWidth, height: itemHeight)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
        currentPage = Int(scrollView.contentOffset.x)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case freshMilkClsView:
            self.pushVC(dataMilk: freshMilkData[indexPath.row])
        case productPromotionClsView:
            self.pushVC(dataMilk: promotionMilkData[indexPath.row])
        case naturalYogurtClsView:
            self.pushVC(dataMilk: naturalYogurts[indexPath.row])
        case naturalFruitJuiceClsView:
            self.pushVC(dataMilk: naturalFruitJuices[indexPath.row])
        case fruitMilkDrinkClsView:
            self.pushVC(dataMilk: fruitMilkDrinks[indexPath.row])
        case creamClsView:
            self.pushVC(dataMilk: creamData[indexPath.row])
        default:
            break
        }
    }
    
    private func pushVC(dataMilk: DataMilkObject) {
        let detailVC = DetailProductsVC(dataMilk: dataMilk)
        self.push(detailVC)
    }
    
}


//
//  UIImageView+.swift
//  AIPhotoProject

import Foundation
import UIKit
import Kingfisher
import Photos
import Nuke

extension UIImageView {
    
    func loadFlag(_ flagUrlString: String) {
        guard let url = URL(string: "http://" + flagUrlString) else { return }
        kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ]) { _ in }
    }
    
    //
    func loadImageOri(anotherUrl: String?,
                      withBackgroundImageColor color: UIColor = .lightGray,
                      placeholder: UIImage? = nil, isShowIndicator: Bool = true) {
        guard let urlString = anotherUrl, let url = URL(string: urlString) else { return }
        if isShowIndicator {
            kf.indicatorType = .activity
            kf.indicator?.startAnimatingView()
        }
        kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage,
            ]) { result in
                switch result {
                case let .success(value):
                    self.image = value.image
                    self.kf.indicator?.stopAnimatingView()
                    break
                case .failure:
                    //                self.image = R.image.ic_userDummy()
                    self.kf.indicator?.stopAnimatingView()
                    break
                }
            }
    }
    
    func loadImageFromUrl(_ stringUrl: String?) {
        guard let stringUrl = stringUrl , let url = URL(string: stringUrl) else {return}
        kf.indicator?.startAnimatingView()
        kf.setImage(
            with: url,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage,
            ]) { result in
                switch result {
                case let .success(value):
                    self.image = value.image
                    self.kf.indicator?.stopAnimatingView()
                    break
                case .failure:
                    //                self.image = R.image.ic_userDummy()
                    self.kf.indicator?.stopAnimatingView()
                    break
                }
            }
    }
    
    func loadImageResize(anotherUrl: String?, withBackgroundImageColor color: UIColor = .lightGray, size: CGSize = CGSize(width: 80.0 , height: 80.0) ) {
        guard let urlString = anotherUrl, let url = URL(string: urlString) else {
            return
        }
        let activityIndicator = self.activityIndicator
        DispatchQueue.main.async {
            activityIndicator.startAnimating()
        }
        let resizingProcessor = ResizingImageProcessor(referenceSize: size)
        kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage,
                .processor(resizingProcessor)
            ]) { result in
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                }
            }
    }
    
    private var activityIndicator: UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.darkGray
        self.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let centerX = NSLayoutConstraint(item: self,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0)
        let centerY = NSLayoutConstraint(item: self,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerY,
                                         multiplier: 1,
                                         constant: 0)
        self.addConstraints([centerX, centerY])
        return activityIndicator
    }
    
    func loadGifOriginNoCache(anotherUrl: String?, handler: @escaping (Bool) -> Void) {
        guard let urlString = anotherUrl, let url = URL(string: urlString) else {
            return
        }
        kf.setImage(
            with: url,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5))
            ]) { result in
                switch result {
                case .success:
                    handler(true)
                case .failure:
                    handler(false)
                }
            }
    }
    
    func loadGifWithCompletion(anotherUrl: String?, handler: @escaping (Bool) -> Void) {
        guard let urlString = anotherUrl, let url = URL(string: urlString) else {
            return
        }
        kf.setImage(
            with: url,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ]) { result in
                switch result {
                case .success:
                    handler(true)
                case .failure:
                    handler(false)
                }
            }
    }
    func imageFrame()->CGRect{
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        }else{
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
    func blur(withStyle style: UIBlurEffect.Style = .light, alpha: Float) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = CGFloat(alpha)
        // for supporting device rotation
        addSubview(blurEffectView)
        clipsToBounds = true
    }
    
    func loadImage(anotherUrl: String?, withBackgroundImageColor color: UIColor = .lightGray) {
        guard let urlString = anotherUrl, let url = URL(string: urlString) else {
            return
        }
        let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: 100.0 , height: 100.0))
        kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage,
                .processor(resizingProcessor)
            ]) { result in
                switch result {
                case .success:
                    break
                case .failure:
                    break
                }
            }
    }
    func loadOriginImage(anotherUrl: String?) {
        guard let urlString = anotherUrl, let url = URL(string: urlString) else {
            return
        }
        kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ]) { result in
                switch result {
                case .success:
                    break
                case .failure:
                    break
                }
            }
    }
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(CGRect(origin: .zero, size: size))
        }
    }
}

extension UIImageView {
    func alphaAtPoint(_ point: CGPoint) -> CGFloat {
        
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let alphaInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: alphaInfo) else {
            return 0
        }
        
        context.translateBy(x: -point.x, y: -point.y);
        
        layer.render(in: context)
        
        let floatAlpha = CGFloat(pixel[3])
        
        return floatAlpha
    }
    
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
    
    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
}

extension UIImageView {
    func load(_ asset: PHAsset?,
              contentMode: PHImageContentMode = .aspectFill,
              options: PHImageRequestOptions? = nil,
              completion: ((Bool) -> Void)?) {
        
        guard let asset = asset else {
            completion?(false)
            return
        }
        
        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, info in
            self.image = image
            completion?(true)
        }
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: self.size,
            contentMode: contentMode,
            options: options,
            resultHandler: resultHandler)
    }
    
    func load(_ data: Data) {
        guard let image = data.toImage() else { return }
        self.image = image
    }
    
    var toKB: Double {
        guard let image = self.image,
              let data = image.jpegData(compressionQuality: 1) else { return 0 }
        
        return Double(data.count) / 1000
    }
    
    //NUKE:
    //    func loadImageWithNuke(_ urlString : String) {
    //        guard let url = URL.init(string: urlString) else {
    //            return
    //        }
    //        let activityIndicator = self.activityIndicator
    //        DispatchQueue.main.async {
    //            activityIndicator.startAnimating()
    //        }
    //        //        let options = ImageLoadingOptions(placeholder: UIImage(named: "place_holder_image"))
    //
    //        Nuke.loadImage(with: url, into: self, progress: { response, completed, total in
    //        }) { result in
    //            activityIndicator.stopAnimating()
    //            activityIndicator.removeFromSuperview()
    //            switch result {
    //            case .success(_): break
    //            case .failure(let error):
    //                print("__Err", error)
    //                self.downloadImage(urlString)
    //            }
    //        }
    //    }
    //    //
    //    func downloadImage(_ urlString : String){
    //        image = nil
    //        guard let url = URL.init(string: urlString) else {
    //            return
    //        }
    //        let activityIndicator = self.activityIndicator
    //        DispatchQueue.main.async {
    //            activityIndicator.startAnimating()
    //        }
    //        let resource = ImageResource(name: "",bundle: Bundle())
    //
    //        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
    //            switch result {
    //            case .success(let value):
    //                print("Image: \(value.image). Got from: \(value.cacheType)")
    //                self.image = value.image
    //            case .failure(let error):
    //                print("__ErrorKf: \(error)")
    //                self.image =  UIImage.init(named: "place_holder_image")
    //                //                self.loadImageFromUrl(urlString)
    //            }
    //            DispatchQueue.main.async {
    //                activityIndicator.stopAnimating()
    //                activityIndicator.removeFromSuperview()
    //            }
    //        }
    //    }
}

extension UIImageView {
    
    func makeRounded() {
        layer.masksToBounds = false
        layer.borderColor = UIColor.clear.cgColor
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
    
    func loadBase64Image(_ base64String: String?) {
        guard let base64String = base64String else { return }
        
        if base64String.hasPrefix("data:image") {
            let components = base64String.components(separatedBy: ",")
            if components.count > 1, let data = Data(base64Encoded: components[1]) {
                self.image = UIImage(data: data)
            }
        } else if let data = Data(base64Encoded: base64String) {
            self.image = UIImage(data: data)
        }
    }
}

extension UIImageView {
    func loadImage(from urlString: String?) {
        guard let urlString = urlString else { return }
        
        if urlString.hasPrefix("data:image") {
            self.loadBase64Image(urlString)
        } else {
            let url = URL(string: urlString)
            self.kf.indicatorType = .activity
            self.kf.setImage(with: url)
        }
    }
}

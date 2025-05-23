import UIKit
import Kingfisher

extension UIImageView {
    func loadImage(from urlString: String?) {
        guard let urlString = urlString else { return }
        
        if urlString.hasPrefix("data:image") {
            // Load ảnh từ base64
            let components = urlString.components(separatedBy: ",")
            if components.count > 1, let data = Data(base64Encoded: components[1]) {
                self.image = UIImage(data: data)
            }
        } else {
            // Load ảnh từ URL
            if let url = URL(string: urlString) {
                self.kf.setImage(with: url)
            }
        }
    }
} 
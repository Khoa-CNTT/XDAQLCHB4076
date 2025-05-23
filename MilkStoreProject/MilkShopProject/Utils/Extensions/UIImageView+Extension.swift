import UIKit

extension UIImageView {
    func loadBase64Image(_ base64String: String?) {
        guard let base64String = base64String else { return }
        
        if base64String.hasPrefix("data:image") {
            // Xử lý chuỗi base64 có prefix
            let components = base64String.components(separatedBy: ",")
            if components.count > 1, let data = Data(base64Encoded: components[1]) {
                self.image = UIImage(data: data)
            }
        } else if let data = Data(base64Encoded: base64String) {
            // Xử lý chuỗi base64 thông thường
            self.image = UIImage(data: data)
        }
    }
} 
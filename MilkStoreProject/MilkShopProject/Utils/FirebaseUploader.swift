import Foundation
import FirebaseCore
import FirebaseFirestore

class FirebaseUploader {
    private let db: Firestore
    
    init() {
        db = Firestore.firestore()
    }
    
    func readAndUploadProducts(from jsonFile: String) {
        do {
            guard let fileURL = Bundle.main.url(forResource: jsonFile, withExtension: "json") else {
                print("Không tìm thấy file JSON")
                return
            }
            
            let jsonData = try Data(contentsOf: fileURL)
            
            let milks = try JSONDecoder().decode(Milks.self, from: jsonData)
            
            guard let dataMilkList = milks.dataMilk else {
                print("Không có dữ liệu dataMilk")
                return
            }
            
            for dataMilk in dataMilkList {
                let updatedDataMilk = dataMilk
                if updatedDataMilk.idProduct == nil {
                    let ramdomID = generateRandomID(type: updatedDataMilk.type ?? "default")
                    updatedDataMilk.idProduct = ramdomID
                }
                updatedDataMilk.quantity = updatedDataMilk.quantity ?? Int.random(in: 1...100)
                
                if let priceString = updatedDataMilk.price {
                    updatedDataMilk.priceSell = self.convertPriceToInt(priceString)
                    updatedDataMilk.priceInput = self.convertPriceToInt(priceString) ?? 0 - 10000
                }
                
                if let priceInput = updatedDataMilk.priceInput, let quantity = updatedDataMilk.quantity {
                    updatedDataMilk.totalImport = priceInput * quantity
                }
                updatedDataMilk.totalSell = updatedDataMilk.totalSell ?? 0
                updatedDataMilk.sell = updatedDataMilk.sell ?? 0
                
                self.uploadProduct(updatedDataMilk)
            }
        } catch {
            print("Lỗi khi đọc hoặc xử lý JSON: \(error)")
        }
    }
    
    private func uploadProduct(_ product: DataMilk) {
        do {
            print("Dang Upload san pham vao firebase")
            let docRef = db.collection("milks").document()
            try docRef.setData(from: product) { error in
                if let error = error {
                    print("❌ Lỗi khi thêm sản phẩm: \(error)")
                } else {
                    print("✅ Đã thêm sản phẩm thành công với ID: \(docRef.documentID)")
                }
            }
        } catch {
            print("Lỗi khi chuyển đổi sản phẩm thành dictionary: \(error)")
        }
    }
    
    private func convertPriceToInt(_ priceString: String) -> Int? {
        let cleanedPrice = priceString.replacingOccurrences(of: " đ", with: "")
        let cleanedPriceWithoutDot = cleanedPrice.replacingOccurrences(of: ".", with: "")
        
        return Int(cleanedPriceWithoutDot)
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode object"])
        }
        return dictionary
    }
}

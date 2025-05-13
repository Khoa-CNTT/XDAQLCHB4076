import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class FirebaseUploader {
    static let shared = FirebaseUploader()
    
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

extension FirebaseUploader {
    func updateUserProfile(
        name: String,
        email: String,
        phoneNumber: String,
        currentPassword: String,
        completion: @escaping (Error?) -> Void
    ) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy người dùng"]))
            return
        }

        if email != user.email {
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)
            user.reauthenticate(with: credential) { result, error in
                if let error = error {
                    completion(error)
                    return
                }
                user.sendEmailVerification(beforeUpdatingEmail: email) { error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    completion(NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Vui lòng kiểm tra email mới và xác thực để hoàn tất đổi email. Sau khi xác thực, email đăng nhập sẽ được cập nhật."]))
                }
            }
        } else {
            self.updateUserInFirestore(name: name, email: email, phoneNumber: phoneNumber, completion: completion)
        }
    }

    private func updateUserInFirestore(
        name: String,
        email: String,
        phoneNumber: String,
        completion: @escaping (Error?) -> Void
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy ID người dùng"]))
            return
        }

        let userRef = db.collection("usernew").document(userId)
        userRef.updateData([
            "username": name,
            "email": email,
            "phone": phoneNumber
        ]) { error in
            completion(error)
        }
    }

    func changeUserPassword(
        oldPassword: String,
        newPassword: String,
        completion: @escaping (Error?) -> Void
    ) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy người dùng"]))
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                completion(error)
                return
            }
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    completion(error)
                    return
                }
                self.updateUserPasswordInFirestore(newPassword: newPassword, completion: completion)
            }
        }
    }

    private func updateUserPasswordInFirestore(
        newPassword: String,
        completion: @escaping (Error?) -> Void
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy ID người dùng"]))
            return
        }
        let userRef = db.collection("usernew").document(userId)
        userRef.updateData([
            "password": newPassword
        ]) { error in
            completion(error)
        }
    }
    
    func updateProductAfterPurchase(productId: String, quantityPurchased: Int, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("milks").whereField("idProduct", isEqualTo: productId).getDocuments { snapshot, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let document = snapshot?.documents.first else {
                completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sản phẩm không tìm thấy"]))
                return
            }
            
            let currentQuantity = document.data()["quantity"] as? Int ?? 0
            let currentSell = document.data()["sell"] as? Int ?? 0
            let currentTotalSell = document.data()["totalSell"] as? Double ?? 0
            
            let newQuantity = currentQuantity - quantityPurchased
            let newSell = currentSell + quantityPurchased
            let newTotalSell = currentTotalSell + (document.data()["priceSell"] as? Double ?? 0) * Double(quantityPurchased)
            
            document.reference.updateData([
                "quantity": newQuantity,
                "sell": newSell,
                "totalSell": newTotalSell
            ]) { error in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func deleteProductFromFirebase(idProduct: String, completion: @escaping (Error?) -> Void) {
        
        db.collection("milks").whereField("idProduct", isEqualTo: idProduct).getDocuments { snapshot, error in
            if let error = error {
                completion(error)
                return
            }
            guard let document = snapshot?.documents.first else {
                completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy sản phẩm trên Firebase"]))
                return
            }
            document.reference.delete { error in
                completion(error)
            }
        }
    }
}

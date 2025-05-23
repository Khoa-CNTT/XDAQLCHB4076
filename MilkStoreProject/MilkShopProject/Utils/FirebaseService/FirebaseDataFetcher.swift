import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseDataFetcher {
    
    static let shared = FirebaseDataFetcher()
    
    private let db: Firestore
    
    init() {
        db = Firestore.firestore()
    }
    
    
    func fetchAllMilks(completion: @escaping (Milks?, Error?) -> Void) {
        db.collection("milks").getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let snapshot = snapshot else {
                completion(nil, NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Không có dữ liệu"]))
                return
            }
            
            var dataMilkList: [DataMilk] = []
            
            for document in snapshot.documents {
                do {
                    let dataMilk = try document.data(as: DataMilk.self)
                    dataMilkList.append(dataMilk)
                } catch {
                    print("Lỗi khi chuyển đổi document: \(error)")
                }
            }
            
            let milks = Milks()
            milks.dataMilk = dataMilkList
            completion(milks, nil)
        }
    }
    
    func fetchProduct(by id: String, completion: @escaping ((DataMilk?) -> Void)) {
        db.collection("milks")
            .whereField("idProduct", isEqualTo: id)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching product: \(error)")
                    completion(nil)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("No product found with idProduct: \(id)")
                    completion(nil)
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    let milk = try JSONDecoder().decode(DataMilk.self, from: jsonData)
                    completion(milk)
                } catch {
                    print("Decode error: \(error)")
                    completion(nil)
                }
            }
    }
    
    func updateUserAddress(uid: String, newAddress: String, completion: ((Error?) -> Void)? = nil) {
        let userRef = db.collection("usernew").document(uid)
        
        userRef.updateData([
            "address": FieldValue.arrayUnion([newAddress])
        ]) { error in
            if let error = error {
                print("[HL-LOG] Update address error: \(error.localizedDescription)")
            } else {
                print("[HL-LOG] Address updated successfully.")
            }
            completion?(error)
        }
    }
    
    func deleteUserAddress(uid: String, addressToDelete: String, completion: ((Error?) -> Void)? = nil) {
        let userRef = db.collection("usernew").document(uid)
        
        userRef.updateData([
            "address": FieldValue.arrayRemove([addressToDelete])
        ]) { error in
            if let error = error {
                print("[HL-LOG] Delete address error: \(error.localizedDescription)")
            } else {
                print("[HL-LOG] Address deleted successfully.")
            }
            completion?(error)
        }
    }
    
    func fetchUserAddresses(uid: String, completion: @escaping ([String]?, Error?) -> Void) {
        let userRef = db.collection("usernew").document(uid)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let addressArray = document.data()?["address"] as? [String] {
                    completion(addressArray, nil)
                } else {
                    completion([], nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func fetchAllUsers(completion: @escaping (String, String, Error?) -> Void) {
        
        db.collection("usernew").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                completion("", "", error)
            } else {
                snapshot?.documents.forEach { document in
                    let name = document.data()["username"] as? String ?? "Unknown"
                    let phone = document.data()["phone"] as? String ?? "Unknown"
                    
                    completion(name, phone, nil)
                }
            }
        }
    }
    
    func fetchOrders(for userId: String, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        db.collection("order").whereField("iduser", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            var orders: [[String: Any]] = []
            snapshot?.documents.forEach { document in
                var data = document.data()
                data["documentID"] = document.documentID
                orders.append(data)
            }
            
            completion(orders, nil)
        }
    }
    
    func fetchAllOrders(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        db.collection("order").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            var orders: [[String: Any]] = []
            snapshot?.documents.forEach { document in
                var data = document.data()
                data["documentID"] = document.documentID
                orders.append(data)
            }
            
            completion(orders, nil)
        }
    }
    
    func fetchAllNotifications(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        db.collection("notification")
            .whereField("role", isEqualTo: true)
            .getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            var notifications: [[String: Any]] = []
            snapshot?.documents.forEach { document in
                var data = document.data()
                data["documentID"] = document.documentID
                notifications.append(data)
            }
            completion(notifications, nil)
        }
    }
    
    func fetchNotifications(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found")
            return
        }
        
        db.collection("notification")
            .whereField("role", isEqualTo: false)
            .whereField("name", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            var notifications: [[String: Any]] = []
            snapshot?.documents.forEach { document in
                var data = document.data()
                data["documentID"] = document.documentID
                notifications.append(data)
            }
            completion(notifications, nil)
        }
    }
    
    func updateNotificationSeenStatus(notificationId: String, completion: ((Error?) -> Void)? = nil) {
        db.collection("notification").document(notificationId).updateData([
            "isSeen": true
        ]) { error in
            if let error = error {
                print("Error updating notification status: \(error.localizedDescription)")
            } else {
                print("Notification status updated successfully")
            }
            completion?(error)
        }
    }
    
    func fetchOrderById(idOrder: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        db.collection("order").document(idOrder).getDocument { document, error in
            if let error = error {
                print("Error fetching order: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                print("Order not found")
                completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Order not found"]))
                return
            }
            
            completion(document.data(), nil)
        }
    }
}

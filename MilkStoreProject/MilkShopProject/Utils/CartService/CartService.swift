//
//  CartService.swift
//  MilkShopProject
//
//  Created by CongDev on 30/4/25.
//

import FirebaseFirestore
import FirebaseAuth

class CartService {
    
    static let shared = CartService()
    
    private let db = Firestore.firestore()
    private var cartRef: CollectionReference {
        return db.collection("cart")
    }
    
    private init() {}
    
    func addProduct(productId: String, quantity: Int, completion: ((Error?) -> Void)? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        cartRef
            .whereField("iduser", isEqualTo: userId)
            .whereField("idproduct", isEqualTo: productId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion?(error)
                    return
                }
                
                if let doc = snapshot?.documents.first {
                    let currentQuantity = doc.data()["quantity"] as? Int ?? 0
                    let newQuantity = currentQuantity + quantity
                    
                    doc.reference.updateData(["quantity": newQuantity]) { error in
                        if let error = error {
                            print("Error updating quantity: \(error.localizedDescription)")
                        } else {
                            print("✅ Quantity updated to \(newQuantity)")
                        }
                    }
                } else {
                    let newItem: [String: Any] = [
                        "idproduct": productId,
                        "iduser": userId,
                        "quantity": quantity
                    ]
                    self.cartRef.addDocument(data: newItem, completion: completion)
                }
            }
    }
    
    func updateCartItem(for userId: String, productId: String, quantity: Int, completion: @escaping (Error?) -> Void) {
        let data = ["quantity": quantity]
        Firestore.firestore().collection("cart")
            .whereField("iduser", isEqualTo: userId)
            .whereField("idproduct", isEqualTo: productId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(error)
                    return
                }
                guard let doc = snapshot?.documents.first else {
                    completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy item"]))
                    return
                }
                doc.reference.updateData(data, completion: completion)
            }
    }
    
    func deleteCartItem(for userId: String, productId: String, completion: @escaping (Error?) -> Void) {
        Firestore.firestore().collection("cart")
            .whereField("iduser", isEqualTo: userId)
            .whereField("idproduct", isEqualTo: productId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(error)
                    return
                }
                guard let doc = snapshot?.documents.first else {
                    completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy item"]))
                    return
                }
                doc.reference.delete(completion: completion)
            }
    }
    
    func fetchCartItems(for userId: String, completion: @escaping ([QueryDocumentSnapshot]?, Error?) -> Void) {
        cartRef.whereField("iduser", isEqualTo: userId).getDocuments { snapshot, error in
            completion(snapshot?.documents, error)
        }
    }
    
    func removeAllItemsInCart(for userId: String, completion: @escaping (Error?) -> Void) {
        let cartRef = Firestore.firestore().collection("cart")
        cartRef.whereField("iduser", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(error)
                return
            }
            
            snapshot?.documents.forEach { document in
                document.reference.delete() { error in
                    if let error = error {
                        print("Error deleting cart item: \(error.localizedDescription)")
                    } else {
                        print("Cart item deleted successfully")
                    }
                }
            }
            
            completion(nil)
        }
    }
}

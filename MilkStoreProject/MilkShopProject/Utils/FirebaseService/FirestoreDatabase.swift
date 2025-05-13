//
//  FirestoreDatabase.swift
//  aiimagegeneration
//
//  Created by IC CREATORY  (FOUNDER) on 25/11/2023.
//

//import Firebase
import Firebase
import Foundation

class FirestoreDatabaseManager {
    class var shared: FirestoreDatabaseManager {
        struct Singleton {
            static let instance = FirestoreDatabaseManager()
        }
        return Singleton.instance
    }

    // Account Info

    func writeAccountInfoDataToFirestore(account_info: AccountInfoModel) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Không lấy được UID")
            return
        }
        
        print("[HL-LOG] Đang cố gắng ghi vào Firestore với dữ liệu: \(account_info)")
        let db = Firestore.firestore()
        let accountInfoRef = db.collection("usernew").document(uid)

        accountInfoRef.setData(account_info.dictionary) { error in
            if let error = error {
                print("[HL-LOG] Lỗi khi ghi tài liệu: \(error)")
            } else {
                print("[HL-LOG] Tài liệu đã được ghi thành công!")
            }
        }
    }

    func getDocumentByID(collectionName: String, documentID: String, completion: @escaping (DocumentSnapshot?, Error?) -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection(collectionName)
        let documentRef = collectionRef.document(documentID)
        documentRef.getDocument { document, error in
            if let error = error {
                print("[HL-LOG] Error getting document: \(error)")
                completion(nil, error)
            } else {
                if let document = document {
                    completion(document, nil)
                } else {
                    print("[HL-LOG] Document does not exist")
                    completion(nil, nil)
                }
            }
        }
    }

    func getAllAccountInfoDataFromFirestore(completion: @escaping ([AccountInfoModel]) -> Void) {
        let db = Firestore.firestore()
        let accountInfoCollectionRef = db.collection("account_info")

        accountInfoCollectionRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("[HL-LOG] Error getting documents: \(error)")
                completion([])
            } else {
                var accountInfoModels: [AccountInfoModel] = []

                for document in querySnapshot!.documents {
                    do {
                        if let accountInfoData = document.data() as? [String: Any] {
                            if let accountInfoModel = try AccountInfoModel(dictionary: accountInfoData) {
                                accountInfoModels.append(accountInfoModel)
                            } else {
                                print("[HL-LOG] AccountInfo: Error decoding document data")
                            }
                        }
                    } catch {
                        print("[HL-LOG] AccountInfo: Error decoding document data: \(error)")
                    }
                }
                completion(accountInfoModels)
            }
        }
    }

    func updateAccountInfoDataToFirestore(accountInfo: AccountInfoModel, documentID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let accountInfoData = accountInfo.dictionary
        db.collection("account_info").document(documentID).setData(accountInfoData) { error in
            if let error = error {
                print("[HL-LOG] AccountInfo: Error updating document: \(error)")
                completion(error)
            } else {
                print("[HL-LOG] AccountInfo: Document successfully updated")
                completion(nil)
            }
        }
    }
}

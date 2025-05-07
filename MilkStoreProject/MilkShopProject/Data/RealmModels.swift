import Foundation
import RealmSwift

// Realm wrapper cho DataMilk
class RealmDataMilk: Object {
    @Persisted(primaryKey: true) var idProduct: String?
    @Persisted var type: String?
    @Persisted var nameMilk: String?
    @Persisted var imgMilk: String?
    @Persisted var price: String?
    @Persisted var priceInput: Int = 0
    @Persisted var priceSell: Int = 0
    @Persisted var quantity: Int = 0
    @Persisted var totalImport: Int = 0
    @Persisted var totalSell: Int = 0
    @Persisted var sell: Int = 0
    @Persisted var details = List<RealmDetail>()
    
    convenience init(from dataMilk: DataMilk) {
        self.init()
        self.idProduct = dataMilk.idProduct
        self.type = dataMilk.type
        self.nameMilk = dataMilk.nameMilk
        self.imgMilk = dataMilk.imgMilk
        self.price = dataMilk.price
        self.priceInput = dataMilk.priceInput ?? 0
        self.priceSell = dataMilk.priceSell ?? 0
        self.quantity = dataMilk.quantity ?? 0
        self.totalImport = dataMilk.totalImport ?? 0
        self.totalSell = dataMilk.totalSell ?? 0
        self.sell = dataMilk.sell ?? 0
        
        // Chuyển đổi detail
        if let details = dataMilk.detail {
            for detail in details {
                let realmDetail = RealmDetail(from: detail)
                self.details.append(realmDetail)
            }
        }
    }
    
    func toDataMilk() -> DataMilk {
        var detailArray: [Detail] = []
        for realmDetail in details {
            detailArray.append(realmDetail.toDetail())
        }
        
        return DataMilk(
            idProduct: idProduct,
            type: type,
            nameMilk: nameMilk,
            imgMilk: imgMilk,
            price: price,
            detail: detailArray,
            priceInput: priceInput,
            priceSell: priceSell,
            quantity: quantity,
            totalImport: totalImport,
            totalSell: totalSell,
            sell: sell
        )
    }
}

// Realm wrapper cho Detail
class RealmDetail: Object {
    @Persisted var trademark: String?
    @Persisted var brandOrigin: String?
    @Persisted var placeOfManufacture: String?
    @Persisted var ingredient: String?
    @Persisted var expiry: String?
    @Persisted var userManual: String?
    @Persisted var storageInstructions: String?
    @Persisted var packaging: String?
    @Persisted var description: String?
    @Persisted var energy: String?
    @Persisted var fat: String?
    @Persisted var protein: String?
    @Persisted var carbohydrates: String?
    @Persisted var calcium: String?
    
    convenience init(from detail: Detail) {
        self.init()
        self.trademark = detail.trademark
        self.brandOrigin = detail.brandOrigin
        self.placeOfManufacture = detail.placeOfManufacture
        self.ingredient = detail.ingredient
        self.expiry = detail.expiry
        self.userManual = detail.userManual
        self.storageInstructions = detail.storageInstructions
        self.packaging = detail.packaging
        self.description = detail.description
        self.energy = detail.energy
        self.fat = detail.fat
        self.protein = detail.protein
        self.carbohydrates = detail.carbohydrates
        self.calcium = detail.calcium
    }
    
    func toDetail() -> Detail {
        return Detail(
            trademark: trademark,
            brandOrigin: brandOrigin,
            placeOfManufacture: placeOfManufacture,
            ingredient: ingredient,
            expiry: expiry,
            userManual: userManual,
            storageInstructions: storageInstructions,
            packaging: packaging,
            description: description,
            energy: energy,
            fat: fat,
            protein: protein,
            carbohydrates: carbohydrates,
            calcium: calcium
        )
    }
}

// Helper functions để lưu và đọc dữ liệu từ Realm
func saveMilksToRealm(_ milks: [DataMilk]) {
    do {
        let realm = try Realm()
        try realm.write {
            // Xóa dữ liệu cũ
            realm.delete(realm.objects(RealmDataMilk.self))
            
            // Thêm dữ liệu mới
            for milk in milks {
                let realmMilk = RealmDataMilk(from: milk)
                realm.add(realmMilk)
            }
        }
    } catch {
        print("❌ Lỗi khi lưu dữ liệu vào Realm: \(error)")
    }
}

func getMilksFromRealm() -> [DataMilk] {
    do {
        let realm = try Realm()
        let realmMilks = realm.objects(RealmDataMilk.self)
        return realmMilks.map { $0.toDataMilk() }
    } catch {
        print("❌ Lỗi khi đọc dữ liệu từ Realm: \(error)")
        return []
    }
}

// Realm wrapper cho Address
class RealmAddress: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var phone: String = ""
    @Persisted var address: String = ""
    @Persisted var isDefault: Bool = false
    
    convenience init(from address: Address) {
        self.init()
        self.id = address.id
        self.name = address.name
        self.phone = address.phone
        self.address = address.address
        self.isDefault = address.isDefault
    }
    
    func toAddress() -> Address {
        return Address(
            id: id,
            name: name,
            phone: phone,
            address: address,
            isDefault: isDefault
        )
    }
}

// Helper functions để lưu và đọc địa chỉ từ Realm
func saveAddressToRealm(_ address: Address) {
    do {
        let realm = try Realm()
        try realm.write {
            let realmAddress = RealmAddress(from: address)
            realm.add(realmAddress, update: .modified)
        }
    } catch {
        print("❌ Lỗi khi lưu địa chỉ vào Realm: \(error)")
    }
}

func getAddressesFromRealm() -> [Address] {
    do {
        let realm = try Realm()
        let realmAddresses = realm.objects(RealmAddress.self)
        return realmAddresses.map { $0.toAddress() }
    } catch {
        print("❌ Lỗi khi đọc địa chỉ từ Realm: \(error)")
        return []
    }
}

func deleteAddressFromRealm(id: String) {
    do {
        let realm = try Realm()
        if let address = realm.object(ofType: RealmAddress.self, forPrimaryKey: id) {
            try realm.write {
                realm.delete(address)
            }
        }
    } catch {
        print("❌ Lỗi khi xóa địa chỉ từ Realm: \(error)")
    }
}

func updateDefaultAddress(id: String) {
    do {
        let realm = try Realm()
        try realm.write {
            // Reset tất cả địa chỉ về false
            let allAddresses = realm.objects(RealmAddress.self)
            allAddresses.forEach { $0.isDefault = false }
            
            // Set địa chỉ được chọn thành default
            if let address = realm.object(ofType: RealmAddress.self, forPrimaryKey: id) {
                address.isDefault = true
            }
        }
    } catch {
        print("❌ Lỗi khi cập nhật địa chỉ mặc định: \(error)")
    }
} 
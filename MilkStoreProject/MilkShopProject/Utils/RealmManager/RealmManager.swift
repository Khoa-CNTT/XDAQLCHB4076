//
//  RealmManager.swift
//  Weather NOOA


import Foundation
import RealmSwift

class RealmManager {
    let realm = try! Realm()
    class var shared: RealmManager {
        struct Singleton {
            static let instance = RealmManager()
        }
        return Singleton.instance
    }
    
    func add<T: Object>(_ object: T) {
        try? realm.safeWrite {
            realm.add(object)
        }
    }
    
    func add<T: Object>(_ objects: [T]) {
        objects.forEach({ object in
            add(object)
        })
    }
    
    func remove<T: Object>(_ object: T) {
        try? realm.safeWrite {
            realm.delete(object)
        }
    }
    
    func removeAll<T: Object>(_ object: T.Type) {
        let objs = getAll(for: object)
        objs.forEach({ remove($0) })
    }

    func getAll<T: Object>(for object: T.Type) -> [T] {
        let objects = try? Realm().objects(T.self)
        return objects == nil ? [] : Array(objects!)
    }
}

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

extension RealmManager {
    func addMilkObj(object: [DataMilkObject]) {
        try? realm.safeWrite {
            realm.add(object)
        }
    }
}



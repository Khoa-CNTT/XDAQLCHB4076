//
//  Realm+.swift
//  AIPhotoProject

//import Foundation
//import RealmSwift
//
//extension Realm {
//    public func safeWrite(_ block: (() throws -> Void)) throws {
//        if isInWriteTransaction {
//            try block()
//        } else {
//            try write(block)
//        }
//    }
//}
//extension RealmCollection
//{
//  func toArray<T>() ->[T]
//  {
//    return self.compactMap{$0 as? T}
//  }
//}

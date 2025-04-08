//
//  Array+.swift
//  AIPhotoProject

import Foundation
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    func findDuplicates() -> [Element: Int] {
            var dict = [Element: Int]()
            
            self.forEach { dict[$0] = dict[$0] == nil ? 1 : (dict[$0] ?? 0) + 1 }
            
            return dict.filter { $0.value > 1 }
     
   
    }
    
    mutating func removeDuplicates() {
            self = self.removingDuplicates()
    }
    
    mutating func clear() {
        self = []
    }
}


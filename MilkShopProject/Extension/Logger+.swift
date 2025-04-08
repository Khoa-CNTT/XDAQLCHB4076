//
//  Logger+.swift
//  AIPhotoProject

import Foundation
func Logger(text: String,  fileName: String = #file, function: String =  #function, line: Int = #line) {
    debugPrint("========[\((fileName as NSString).lastPathComponent), in \(function) at line: \(line)]: \(text)")
}

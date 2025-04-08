//
//  CMTime+.swift
//  AIPhotoProject

import Foundation
import UIKit
import AVKit
import Vision
import Photos

extension CMTime {
    var durationText:String {
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds % 3600 / 60)
        let seconds:Int = Int((totalSeconds % 3600) % 60)
        return String(format: "%i:%02i:%02i", hours, minutes, seconds)
    }
}

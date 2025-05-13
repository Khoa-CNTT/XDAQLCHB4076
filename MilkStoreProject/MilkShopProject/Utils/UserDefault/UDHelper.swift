//
//  UDHelper.swift


import Foundation
import SwifterSwift

struct UDHelper {
    
    static var isFirstLauch: Bool {
        set { UDKey.isFirstLauch.set(newValue) }
        get { UDKey.isFirstLauch.value.unwrapped(or: false) }
    }
    
    static var isPurchaseLifeTime : Bool {
        set { UDKey.isPurchasedLifetime.set(newValue) }
        get { UDKey.isPurchasedLifetime.value.unwrapped(or: false)}
    }
    
//    static var isPurchased: Bool {
////        set { UDKey.isPurchased.set(newValue) }
//        get {
//            return StoreProduct.subscriptions.isPurchased.value
//        }
//    }
    
    static var currentLanguageCode: String {
        get {
            UDKey.currentLanguageCode.value.unwrapped(or: "en")
        }
        
        set {
            UDKey.currentLanguageCode.set(newValue)
        }
    }
    
    static var isShowAds: Bool {
        get {
            UDKey.isShowAds.value.unwrapped(or: true)
        }
        
        set {
            UDKey.isShowAds.set(newValue)
        }
    }
    
    static var isShowOpenApp: Bool {
        get {
            UDKey.isShowOpenApp.value.unwrapped(or: true)
        }
        
        set {
            UDKey.isShowOpenApp.set(newValue)
        }
    }
    
    static var isShowInterAds: Bool {
        get {
            UDKey.isShowInterAds.value.unwrapped(or: true)
        }
        
        set {
            UDKey.isShowInterAds.set(newValue)
        }
    }
    
    static var isShowNativeLanguage: Bool {
        get {
            UDKey.isShowNativeLanguage.value.unwrapped(or: true)
        }
        
        set {
            UDKey.isShowNativeLanguage.set(newValue)
        }
    }
    
    static var isShowColabBannerHome: Bool {
        get {
            UDKey.isShowColabBannerHome.value.unwrapped(or: true)
        }
        
        set {
            UDKey.isShowColabBannerHome.set(newValue)
        }
    }
    
    static var isShowColabBannerSetting: Bool {
        get {
            UDKey.isShowColabBannerSetting.value.unwrapped(or: true)
        }
        
        set {
            UDKey.isShowColabBannerSetting.set(newValue)
        }
    }
    
    static var isShowReward: Bool {
        get {
            UDKey.isShowReward.value.unwrapped(or: true)
        }
        
        set {
            UDKey.isShowReward.set(newValue)
        }
    }
    
    static var isShowNativeSave: Bool {
        get {
            UDKey.isShowNativeSave.value.unwrapped(or: true)
        }
        
        set {
            UDKey.isShowNativeSave.set(newValue)
        }
    }
    
    static var nameUser: String {
        get {
            UDKey.nameUser.value.unwrapped(or: "")
        }
        
        set {
            UDKey.nameUser.set(newValue)
        }
    }
    
    static var phoneUser: String {
        get {
            UDKey.phoneUser.value.unwrapped(or: "")
        }
        
        set {
            UDKey.phoneUser.set(newValue)
        }
    }
    
    static var roleUser: Bool {
        get {
            UDKey.roleUser.value.unwrapped(or: false)
        }
        
        set {
            UDKey.roleUser.set(newValue)
        }
    }
    
    static var address: [String] {
        get {
            UDKey.address.value.unwrapped(or: [])
        }
        
        set {
            UDKey.address.set(newValue)
        }
    }
    
    static var passWord: String {
        get {
            UDKey.passWord.value.unwrapped(or: "")
        }
        
        set {
            UDKey.passWord.set(newValue)
        }
    }
    
    static var authenCode: String {
        get {
            UDKey.authenCode.value.unwrapped(or: "")
        }
        
        set {
            UDKey.authenCode.set(newValue)
        }
    }
    
    static var email: String {
        get {
            UDKey.email.value.unwrapped(or: "")
        }
        
        set {
            UDKey.email.set(newValue)
        }
    }
    
    static var isLoginSuccess: Bool {
        get {
            UDKey.isLoginSuccess.value.unwrapped(or: false)
        }
        
        set {
            UDKey.isLoginSuccess.set(newValue)
        }
    }
    
    static var isFirstFetchDataInSplash: Bool {
        get {
            UDKey.isFirstFetchDataInSplash.value.unwrapped(or: true)
        }
        
        set {
            UDKey.isFirstFetchDataInSplash.set(newValue)
        }
    }
}

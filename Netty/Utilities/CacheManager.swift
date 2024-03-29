//
//  PhotoModelCacheManager.swift
//  Netty
//
//  Created by Danny on 7/28/22.
//

import Foundation
import SwiftUI
import CloudKit

class CacheManager {
    
    static let instance = CacheManager()
    private init() { }
    
    var photoCache: NSCache<NSString, UIImage> = {
        
        var cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200
        cache.totalCostLimit = 1024 * 1024 * 200
        return cache
    }()
    
    var recentUsers: NSCache<NSString, RecentUsersHolder> = {
        
        var cache = NSCache<NSString, RecentUsersHolder>()
        cache.countLimit = 2
        return cache
    }()
    
    var chatMessages: NSCache<NSString, ChatMessagesHolder> = {
        
        var cache = NSCache<NSString, ChatMessagesHolder>()
        cache.countLimit = 10
        return cache
    }()
    
    var posts: NSCache<NSString, PostModelsHolder> = {
        
        var cache = NSCache<NSString, PostModelsHolder>()
        cache.countLimit = 10
        return cache
    }()
    
    var userData: NSCache<NSString, UserModelHolder> = {
        
        var cache = NSCache<NSString, UserModelHolder>()
        cache.countLimit = 50
        return cache
    }()
    
    var chatRows: NSCache<NSString, ChatRowModelsHolder> = {
        
        var cache = NSCache<NSString, ChatRowModelsHolder>()
        cache.countLimit = 2
        return cache
    }()

    
    
    
    func delete(from cache: NSCache<NSString, UIImage>, _ strValue: String, for recordName: String) {
        cache.removeObject(forKey: "\(recordName)\(strValue)" as NSString)
    }
    
    func delete(from cache: NSCache<NSString, NSString>, _ strValue: String, for recordName: String) {
        cache.removeObject(forKey: "\(recordName)\(strValue)" as NSString)
    }
    
    func delete(from cache: NSCache<NSString, RecentUsersHolder>, _ strValue: String, for recordName: String) {
        cache.removeObject(forKey: "\(recordName)\(strValue)" as NSString)
    }
              
    func addTo(_ cache: NSCache<NSString, RecentUsersHolder>, key: String, value: RecentUsersHolder) {
        cache.setObject(value, forKey: key as NSString)
    }
    
    func addTo(_ cache: NSCache<NSString, ChatRowModelsHolder>, key: String, value: ChatRowModelsHolder) {
        cache.setObject(value, forKey: key as NSString)
    }

    
    func addTo(_ cache: NSCache<NSString, ChatMessagesHolder>, key: String, value: ChatMessagesHolder) {
        cache.setObject(value, forKey: key as NSString)
    }
    
    func addTo(_ cache: NSCache<NSString, PostModelsHolder>, key: String, value: PostModelsHolder) {
        cache.setObject(value, forKey: key as NSString)
    }
    
    func addTo(_ cache: NSCache<NSString, UserModelHolder>, key: String, value: UserModelHolder) {
        cache.setObject(value, forKey: key as NSString)
    }
    
    func addTo(_ cache: NSCache<NSString, UIImage>, key: String, value: UIImage?) {
        if let value = value {
            cache.setObject(value, forKey: key as NSString)
        } else {
            cache.removeObject(forKey: key as NSString)
        }
    }
    
    func getFrom(_ cache: NSCache<NSString, RecentUsersHolder>, key: String) -> RecentUsersHolder? {
        cache.object(forKey: key as NSString)
    }
    
    func getFrom(_ cache: NSCache<NSString, ChatRowModelsHolder>, key: String) -> ChatRowModelsHolder? {
        cache.object(forKey: key as NSString)
    }

    
    func getFrom(_ cache: NSCache<NSString, UserModelHolder>, key: String) -> UserModelHolder? {
        cache.object(forKey: key as NSString)
    }
    
    func getFrom(_ cache: NSCache<NSString, PostModelsHolder>, key: String) -> PostModelsHolder? {
        cache.object(forKey: key as NSString)
    }

    
    func getFrom(_ cache: NSCache<NSString, ChatMessagesHolder>, key: String) -> ChatMessagesHolder? {
        cache.object(forKey: key as NSString)
    }

    func getFrom(_ cache: NSCache<NSString, UIImage>, key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
}

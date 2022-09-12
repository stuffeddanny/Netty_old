//
//  ProfileViewModel.swift
//  Netty
//
//  Created by Danny on 7/28/22.
//

import Foundation
import CloudKit
import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false
    @Published var fullName: String? = nil
    @Published var nickname: String? = nil

        
    init() {
        
    }
    
    func sync(for id: CKRecord.ID?) {
        getImage(for: id)
        getFullName(for: id)
        getNickname(for: id)
    }
    
    private func getNickname(for id: CKRecord.ID?) {
        guard let id = id else { return }
        if let savedNickname = CacheManager.instance.getText(key: "\(id.recordName)_nickname") as? String {
            nickname = savedNickname
        } else {
            Task {
                let result = await UserInfoService.instance.fetchNicknameForUser(with: id)
                switch result {
                case .success(let returnedValue):
                    await MainActor.run(body: {
                        self.nickname = returnedValue
                        if let nickname = returnedValue {
                            CacheManager.instance.add(key: "\(id.recordName)_nickname", value: NSString(string: nickname))
                        }
                    })
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func getFullName(for id: CKRecord.ID?) {
        guard let id = id else { return }
        if let savedName = CacheManager.instance.getText(key: "\(id.recordName)_fullName") as? String {
            fullName = savedName
        } else {
            Task {
                let result = await UserInfoService.instance.fetchFullNameForUser(with: id)
                switch result {
                case .success(let returnedValue):
                    await MainActor.run(body: {
                        self.fullName = returnedValue
                        if let fullName = returnedValue {
                            CacheManager.instance.add(key: "\(id.recordName)_fullName", value: NSString(string: fullName))
                        }
                    })
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func uploadImage(_ image: UIImage, for id: CKRecord.ID?) {
        guard let id = id else { return }
        DispatchQueue.main.async {
            self.image = nil
            self.isLoading = true
        }
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: id) { record, error in
            if let record = record,
               let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathExtension("avatar.jpg") {
                let data = image.jpegData(compressionQuality: 0.5)
                
                do {
                    try data?.write(to: url)
                    let asset = CKAsset(fileURL: url)
                    record[.avatarRecordField] = asset
                    Task {
                        let _ = await CloudKitManager.instance.saveRecordToPublicDatabase(record)
                        await MainActor.run {
                            self.image = image
                            self.isLoading = false
                        }
                        CacheManager.instance.add(key: "\(id.recordName)_avatar", value: image)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                self.getImage(for: id)
            }
        }
    }
    
    private func getImage(for id: CKRecord.ID?) {
        guard let id = id else { return }
        if let savedImage = CacheManager.instance.getImage(key: "\(id.recordName)_avatar") {
            image = savedImage
        } else {
            isLoading = true
            Task {
                let result = await AvatarImageService.instance.fetchAvatarForUser(with: id)
                switch result {
                case .success(let returnedValue):
                    await MainActor.run(body: {
                        isLoading = false
                        self.image = returnedValue
                        if let image = returnedValue {
                            CacheManager.instance.add(key: "\(id.recordName)_avatar", value: image)
                        }
                    })
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

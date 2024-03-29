//
//  FindUserModelService.swift
//  Netty
//
//  Created by Danny on 9/30/22.
//

import Foundation
import CloudKit


actor FindUserModelService {
    
    static let instance = FindUserModelService()
    
    private init() {}
    
    func downloadRecents(for id: CKRecord.ID) async -> Result<[UserModel], Error> {
        await withCheckedContinuation { continuation in
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: id) { returnedRecord, error in
                if let record = returnedRecord {
                    if let recentsRefs = record[.recentUsersInSearchRecordField] as? [CKRecord.Reference] {
                        CKContainer.default().publicCloudDatabase.fetch(withRecordIDs: recentsRefs.map({ $0.recordID })) { returnedResult in
                            switch returnedResult {
                            case .success(let results):
                                var arrayToBeSorted: [UserModel] = []
                                for result in results.values {
                                    switch result {
                                    case .success(let recentUser):
                                        if let firstName = recentUser[.firstNameRecordField] as? String,
                                           let lastName = recentUser[.lastNameRecordField] as? String,
                                           let nickname = recentUser[.nicknameRecordField] as? String {
                                            let followers = recentUser[.followersRecordField] as? [CKRecord.Reference] ?? []
                                            let following = record[.followingRecordField] as? [CKRecord.Reference] ?? []
                                            arrayToBeSorted.append(UserModel(id: recentUser.recordID, firstName: firstName, lastName: lastName, nickname: nickname, followers: followers, following: following))
                                            
                                        }
                                    case .failure(let error):
                                        continuation.resume(returning: .failure(error))
                                    }
                                }
                                var resultArray: [UserModel] = []
                                for ref in recentsRefs {
                                    if let temp = arrayToBeSorted.first(where: { $0.id == ref.recordID }) {
                                        resultArray.append(temp)
                                    }
                                }
                                continuation.resume(returning: .success(resultArray))
                            case .failure(let error):
                                continuation.resume(returning: .failure(error))
                            }
                        }
                    } else {
                        continuation.resume(returning: .success([]))
                    }
                } else if let error = error {
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
    
    func downloadSearching(_ searchText: String, id: CKRecord.ID) async -> Result<[UserModel], Error> {
        await withCheckedContinuation { continuation in
            let query = CKQuery(recordType: .usersRecordType, predicate: .init(value: true))
            CKContainer.default().publicCloudDatabase.fetch(withQuery: query) { completion in
                switch completion {
                case .success(let completionResult):
                    var resultArray: [UserModel] = []
                    for result in completionResult.matchResults {
                        switch result.1 {
                        case .success(let userRecord):
                            if let firstName = userRecord[.firstNameRecordField] as? String,
                               let lastName = userRecord[.lastNameRecordField] as? String,
                               let nickname = userRecord[.nicknameRecordField] as? String {
                                if userRecord.recordID != id && (firstName.lowercased().starts(with: searchText.lowercased()) || lastName.lowercased().starts(with: searchText.lowercased()) || nickname.lowercased().starts(with: searchText.lowercased())) {
                                    let followers = userRecord[.followersRecordField] as? [CKRecord.Reference] ?? []
                                    let following = userRecord[.followingRecordField] as? [CKRecord.Reference] ?? []
                                    resultArray.append(UserModel(id: userRecord.recordID, firstName: firstName, lastName: lastName, nickname: nickname, followers: followers, following: following))
                                }
                            }
                            
                        case .failure(_):
                            break
                        }
                    }
                    continuation.resume(returning: .success(resultArray))
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
    
    func saveRecents(_ users: [UserModel], id: CKRecord.ID) async -> Result<CKRecord, Error> {
        await CloudKitManager.instance.updateFieldForUserWith(recordId: id, field: .recentUsersInSearchRecordField, newData: users.map({ CKRecord.Reference(recordID: $0.id, action: .none) }))
    }
}

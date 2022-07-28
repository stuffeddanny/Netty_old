//
//  CloudKitManager.swift
//  Netty
//
//  Created by Danny on 21/07/2022.
//

import Foundation
import CloudKit
import Combine
import SwiftUI

actor CloudKitManager {
    
    private init() {}
    
    static let instance = CloudKitManager()
    
    
    func doesRecordExistInPublicDatabase(inRecordType: String, withField: String, equalTo: String) async -> Result<Bool, Error> {
        await withCheckedContinuation { continuation in
            let predicate = NSPredicate(format: "\(withField) == %@", equalTo.lowercased())
            let query = CKQuery(recordType: inRecordType, predicate: predicate)
            CKContainer.default().publicCloudDatabase.fetch(withQuery: query, inZoneWith: nil) { completion in
                switch completion {
                case .success(let success):
                    continuation.resume(returning: .success(success.matchResults.isEmpty))
                case .failure(let failure):
                    continuation.resume(returning: .failure(failure))
                }
            }
        }
    }

    func saveRecordToPublicDatabase(_ record: CKRecord) async -> Result<CKRecord, Error> {
        await withCheckedContinuation { continuation in
            CKContainer.default().publicCloudDatabase.save(record) { returnedRecord, error in
                if let error = error {
                    continuation.resume(returning: .failure(error))
                }
                if let returnedRecord = returnedRecord {
                    continuation.resume(returning: .success(returnedRecord))
                }
            }
        }
    }
}


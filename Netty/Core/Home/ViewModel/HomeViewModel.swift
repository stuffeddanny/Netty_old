//
//  HomeViewModel.swift
//  Netty
//
//  Created by Danny on 20/07/2022.
//

import SwiftUI
import CloudKit

class HomeViewModel: ObservableObject {
    
    struct New: Identifiable {
        let id: UUID
    }
    
    @Published var news: [New] = []
    
    let userId: CKRecord.ID
    
    init(_ userId: CKRecord.ID) {
        self.userId = userId
        Task {
            await createNews()
        }
    }
    
    func createNews() async {
        try? await Task.sleep(for: .seconds(1))
        await MainActor.run {
            news = []
            for _ in 1...100 {
                news.append(New(id: UUID()))
            }
        }
    }
}

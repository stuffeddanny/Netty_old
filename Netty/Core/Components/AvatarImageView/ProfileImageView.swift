//
//  ProfileImageView.swift
//  Netty
//
//  Created by Danny on 9/14/22.
//

import CloudKit
import SwiftUI

struct ProfileImageView: View {
    
    // View Model
    @ObservedObject private var vm: ProfileImageViewModel
        
    init(for id: CKRecord.ID) {
        vm = ProfileImageViewModel(id: id)
    }
    
    var body: some View {
        ZStack {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if vm.isLoading {
                Rectangle()
                    .foregroundColor(.secondary.opacity(0.3))
                    .overlay {
                        ProgressView()
                    }
            } else {
                Rectangle()
                    .foregroundColor(.secondary.opacity(0.3))
                    .overlay {
                        Image(systemName: "questionmark")
                            .foregroundColor(.secondary)
                    }
            }
        }
        .clipShape(Circle())
    }
}

struct ProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageView(for: TestUser.daniel.id)
            .scaledToFit()
            .previewLayout(.sizeThatFits)
    }
}

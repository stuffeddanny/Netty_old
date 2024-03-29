//
//  PostView.swift
//  Netty
//
//  Created by Danny on 11/6/22.
//

import SwiftUI

struct FunctionsForPost {
    
}

struct PostView: View {
    
    @StateObject private var vm: PostViewModel
    @Environment(\.presentationMode) var presentationMode
    private let deleteFunc: ((PostModel) async -> ())?
    @State private var showConfDialog: Bool = false
    @State private var showDeletionConfDialog: Bool = false
    let showNavTitle: Bool
    
    init(postModel: PostModel, deleteFunc: @escaping (PostModel) async -> (), showNavTitle: Bool = false) {
        _vm = .init(wrappedValue: PostViewModel(postModel: postModel))
        self.deleteFunc = deleteFunc
        self.showNavTitle = showNavTitle
    }
    
    init(postModel: PostModel, showNavTitle: Bool = false) {
        _vm = .init(wrappedValue: PostViewModel(postModel: postModel))
        self.deleteFunc = nil
        self.showNavTitle = showNavTitle
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Divider()
                
                HStack {
                    ProfileImageView(for: vm.postModel.ownerId)
                        .frame(width: 40, height: 40)
                        .padding(.leading, 10)
                    
                    if let nickname = vm.nickname {
                        Text(nickname)
                            .font(.callout)
                            .fontWeight(.semibold)
                    } else {
                        LoadingAnimation()
                    }
                    
                    Spacer(minLength: 0)
                    
                    Button {
                        showConfDialog = true
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .padding(.trailing)
                }
                .padding(.vertical, 10)
                
                Image(uiImage: vm.postModel.photo)
                    .resizable()
                    .scaledToFit()
                
                HStack {
                    
                    Button {
                        vm.liked.toggle()
                    } label: {
                        Image(systemName: vm.liked ? "heart.fill" : "heart")
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "message")
                    }
                    
                    
                    
                    Spacer(minLength: 0)
                    
                    Button {
                        vm.saved.toggle()
                    } label: {
                        Image(systemName: vm.saved ? "bookmark.fill" : "bookmark")
                    }
                }
                .font(.title)
                .padding(10)
            }
        }
        .modifier(CustomNavTitle(showNavTitle: showNavTitle, nickname: vm.nickname ?? ""))
        .confirmationDialog("", isPresented: $showConfDialog, titleVisibility: .hidden) {
            Button("TestButton") {
                print("Test")
            }
            if deleteFunc != nil {
                Button("Delete", role: .destructive, action: {
                    showDeletionConfDialog = true
                })
            }
            Button("Cancel", role: .cancel, action: {})
        }
        .confirmationDialog("Are you sure?", isPresented: $showDeletionConfDialog, titleVisibility: .visible) {
            Button("Permanently Delete", role: .destructive) {
                Task {
                    presentationMode.wrappedValue.dismiss()
                    
                    if let deleteFunc = deleteFunc {
                        await deleteFunc(vm.postModel)
                    }
                }
            }
            
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    struct CustomNavTitle: ViewModifier {
        let showNavTitle: Bool
        let nickname: String
        
        func body(content: Content) -> some View {
            if showNavTitle {
                content
                    .navigationTitle(nickname)
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                content
            }
        }
    }
}

struct PostView_Previews: PreviewProvider {
    
    static let post = PostModel(id: .init(recordName: "3F744AF1-0FB3-4395-A0CA-C8AC9FC5722A"), ownerId: TestUser.anastasia.id, photo: UIImage(named: "testImage")!, creationDate: .now)
    static func delete(_ post: PostModel) async {
        
    }
    
    static var previews: some View {
        NavigationView {
            PostView(postModel: post, deleteFunc: delete, showNavTitle: true)
                .previewLayout(.sizeThatFits)
        }
    }
}

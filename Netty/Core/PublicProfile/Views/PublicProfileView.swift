//
//  PublicProfileView.swift
//  Netty
//
//  Created by Danny on 11/8/22.
//

import SwiftUI
import CloudKit

struct PublicProfileView: View {
    
    // View Model
    @StateObject private var vm: PublicProfileViewModel
    
    init(for userModel: UserModel, ownId: CKRecord.ID) {
        self._vm = .init(wrappedValue: PublicProfileViewModel(userModel, ownId: ownId))
    }
            
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    
                    // Photo
                    ProfileImageView(for: vm.user.id)
                        .frame(width: 100, height: 100)
                        .padding(.horizontal)
                    
                    // Name & nickname
                    UserInfo
                        .frame(height: 100)
                    
                    Spacer(minLength: 0)
                }
                
                FollowButton
                .overlay {
                    if vm.followButtonIsLoading {
                        ProgressView()
                    }
                }
                .disabled(vm.followButtonIsLoading)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal)

            }
            .padding(.top)
            
            Divider()
            
            Posts
        }
        .navigationTitle(vm.user.nickname)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await vm.sync()
        }
        .onAppear {
            vm.updateValuesFromCache()
        }
        .alert(Text(vm.alertTitle), isPresented: $vm.showAlert, actions: {}) {
            Text(vm.alertMessage)
        }
    }
    
    @ViewBuilder
    private var Posts: some View {
        if !vm.postsAreLoading {
            
            if vm.posts.isEmpty {
                Text("User has no posts yet")
                    .font(.title2)
                    .foregroundColor(.secondary.opacity(0.6))
                    .padding(.top)

            } else {
                LazyVGrid(columns: .init(repeating: GridItem(spacing: 1), count: 3), spacing: 1) {
                    ForEach(vm.posts) { post in
                        NavigationLink {
                            PostView(postModel: post, showNavTitle: true)
                        } label: {
                            Image(uiImage: post.photo)
                                .resizable()
                                .scaledToFit()
                        }
                        .contextMenu {
                            Button("Test Button") {
                                print("test")
                            }
                        } preview: {
                            PostView(postModel: post, showNavTitle: true)
                        }
                        
                    }
                }

            }
        } else {
            ProgressView()
                .padding(.top, 100)
        }
    }
    
    private var UserInfo: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if vm.userInfoIsLoading {
                LoadingAnimation()
                    .padding(.vertical)
                
            } else { // User data
                
                Text("\(vm.firstName) \(vm.lastName)")
                    .lineLimit(1)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(vm.nickname)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    
                    VStack {
                        Text("Posts")
                            .fontWeight(.semibold)
                            .font(.footnote)
                        
                        Text(vm.postsNumber ?? "***")
                            .font(.callout)
                    }
                    
                    Spacer(minLength: 0)
                    
                    NavigationLink(value: RefsHolderWithDestination(destination: .followers, refs: vm.followers ?? [])) {
                        VStack {
                            Text("Followers")
                                .fontWeight(.semibold)
                                .font(.footnote)
                            
                            if let followersCount = vm.followers?.count {
                                Text("\(followersCount)")
                                    .font(.callout)
                            } else {
                                Text("***")
                                    .font(.callout)
                            }
                                
                        }
                        .foregroundColor(followersDisabled ? .secondary : .primary)
                    }
                    .foregroundColor(.primary)
                    .disabled(followersDisabled)
                    
                    Spacer(minLength: 0)
                    
                    NavigationLink(value: RefsHolderWithDestination(destination: .following, refs: vm.following ?? [])) {
                        VStack {
                            Text("Following")
                                .fontWeight(.semibold)
                                .font(.footnote)
                            
                            if let followingCount = vm.following?.count {
                                Text("\(followingCount)")
                                    .font(.callout)
                            } else {
                                Text("***")
                                    .font(.callout)
                            }
                        }
                        .foregroundColor(followingDisabled ? .secondary : .primary)
                    }
                    .foregroundColor(.primary)
                    .disabled(followingDisabled)

                }
                .padding([.trailing, .vertical])
                
                
            }
        }
    }
    
    private var FollowButton: some View {
        Button {
            vm.followButtonPressed()
        } label: {
            Text(vm.isFollowed ?? false ? "Unfollow" : "Follow")
                .frame(maxWidth: .infinity)
        }
        .followButtonStyle(isFollowed: vm.isFollowed ?? false)
    }
    
    private var followingDisabled: Bool {
        vm.following == nil || vm.following?.count ?? 0 < 1
    }
    
    private var followersDisabled: Bool {
        vm.followers == nil || vm.followers?.count ?? 0 < 1
    }
}





struct PublicProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PublicProfileView(for: TestUser.anastasia, ownId: TestUser.daniel.id)
        }
    }
}

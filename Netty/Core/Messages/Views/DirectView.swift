//
//  DirectView.swift
//  Netty
//
//  Created by Danny on 7/27/22.
//

import SwiftUI
import CloudKit

struct DirectView: View {
    
    @EnvironmentObject private var mainScreenVm: MainScreenViewModel
    
    // View Model
    @StateObject private var vm: DirectViewModel
    
    // Search text in search field
    @State private var searchText: String = ""
    
    // Shows new message sheet
    @State private var showSheet: Bool = false
        
    init(userId: CKRecord.ID) {
        _vm = .init(wrappedValue: DirectViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    if !vm.isLoading {
                        
                        if vm.chatsArray.isEmpty {
                            noChatsView
                        } else {
                            List(searchResults) { chat in
                            NavigationLink(value: UserModelHolderWithDestination(destination: .chat, userModel: chat.user)) {
                                    chatRowView(for: chat, with: geo)
                                        .swipeActions {
                                            getSwipeActionsFor(chat)
                                        }
                                }
                            }
                            
                            .listStyle(.inset)
                            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))

                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            .disabled(vm.isLoading)
            .refreshable {
                await vm.sync()
            }
            .toolbar { getToolbar() }
        }
        .overlay {
            if vm.isLoading {
                ProgressView()
            }
        }
        .alert(Text(vm.alertTitle), isPresented: $vm.showAlert, actions: {}, message: {
            Text(vm.alertMessage)
        })
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                FindUserView(ownId: vm.userId, forDestination: .chat, finishPickingFunc: findUserFinishPicking)
                    .navigationTitle("New message")
                    .navigationBarTitleDisplayMode(.inline)
            }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .padding(.top)
        }
    }
    
    private func findUserFinishPicking() {
        showSheet = false
    }
    
    // Creates toolbar for navigation view
    @ToolbarContentBuilder private func getToolbar() -> some ToolbarContent {
        
        // Title
        ToolbarItem(placement: .navigationBarLeading) {
            Text("Messages")
                .fontWeight(.semibold)
                .font(.title)
                .foregroundColor(.accentColor)
        }
        
        // New message button
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showSheet.toggle()
            } label: {
                Image(systemName: "square.and.pencil")
            }
            
        }
    }
    
    // Chat view
    private func chatRowView(for chat: ChatRowModel, with geo: GeometryProxy) -> some View {
        HStack {
            ProfileImageView(for: chat.user.id)
                .frame(width: 70, height: 70)
                .padding(.trailing, 5)
            
            VStack(alignment: .leading) {
                Text(chat.user.nickname)
                    .lineLimit(1)
                    .fontWeight(.semibold)
                    .padding(.top)
                    .frame(width: geo.size.width * 0.5, alignment: .leading)
                
                Spacer(minLength: 0)
                
                Text(chat.lastMessage ?? "...")
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                    .font(.callout)
                    .padding(.bottom)
                    .frame(width: geo.size.width * 0.6, alignment: .leading)
            }
        }
    }
    
    // Swipe actions for each chat
    private func getSwipeActionsFor(_ chat: ChatRowModel) -> some View {
        Button("Delete", role: .destructive) {
            Task {
                await vm.delete(chat: chat)
            }
        }
    }
    
    // View which is showed if user has no chats
    private var noChatsView: some View {
        VStack {
            Image(systemName: "xmark.bin")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
            
            Text("You don't have any chats")
                .font(.title3)
                .padding()
            
            Button {
                Task {
                    await vm.sync()
                }
            } label: {
                Label {
                    Text("Tap to reload")
                } icon: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .foregroundColor(.secondary)
    }
    
    // Filters messages to satisfy search request
    private var searchResults: [ChatRowModel] {
        if searchText.isEmpty {
            return vm.chatsArray
        } else {
            return vm.chatsArray.filter { $0.user.nickname.lowercased().contains(searchText.lowercased()) }
        }
    }
}




struct DirectView_Previews: PreviewProvider {
    static var previews: some View {
        DirectView(userId: TestUser.daniel.id)
        DirectView(userId: TestUser.daniel.id)
    }
}


//
//  NettyApp.swift
//  Netty
//
//  Created by Danny on 16/07/2022.
//

import SwiftUI
import Combine
import CloudKit

class LogInAndOutViewModel: ObservableObject {
    
    // Current user's recordID
    @Published var userRecordId: CKRecord.ID?
    
    // Log in and out manager
    private let manager = LogInAndOutManager.instance
    
    // Error message
    @Published var warningMessage: WarningMessage = .none
    
    // Shows loading view if true
    @Published var isLoading: Bool = false
    
    // Alert
    @Published var showAlert: Bool = false
    var alertTitle: String = ""
    var alertMessage: String = ""
        
    init(id: CKRecord.ID? = nil) {
        userRecordId = id
        Task {
            let result = await manager.checkLoggedInDevise()
            await MainActor.run(body: {
                switch result {
                case .success(let id):
                    withAnimation {
                        userRecordId = id
                    }
                case .failure(_):
                    print("")
                }
            })
        }
        getiCloudStatus()
    }
    
    /// Logs user in
    func logIn(username: String, password: String) async {
        if username.count < 3 {
            await MainActor.run(body: {
                warningMessage = .usernameIsShort
            })
        } else if password.count < 8 {
            await MainActor.run(body: {
                warningMessage = .passwordIsShort
            })
        } else {
            await MainActor.run(body: {
                warningMessage = .none
                isLoading = true
            })
            switch await manager.logIn(username: username, password: password) {
            case .success(let id):
                if let id = id {
                    await MainActor.run(body: {
                        withAnimation {
                            userRecordId = id
                        }
                    })
                    await manager.addLoggedInDevice(for: id)
                } else {
                    showAlert(title: "Error while logging in", message: "Password is incorrect")
                }
            case .failure(let error):
                showAlert(title: "Error", message: error.localizedDescription)
            }
            await MainActor.run(body: {
                isLoading = false
            })
        }
    }
    
    /// Shows alert
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        DispatchQueue.main.async {
            self.showAlert = true
        }
    }
    
    /// Logs user out
    func logOut() async {
        if let id = userRecordId {
            switch await manager.logOut(for: id) {
            case .success(_):
                await MainActor.run(body: {
                    withAnimation {
                        userRecordId = nil
                    }
                })
            case .failure(let error):
                showAlert(title: "Error while logging out", message: error.localizedDescription)
            }
        }
    }
    
    /// Gets user's iCloud status
    private func getiCloudStatus() {
        CKContainer.default().accountStatus {  returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .couldNotDetermine:
                    print("Could not determine")
                case .available:
                    print("iCloud is available")
                case .restricted:
                    print("iCloud is restricted")
                case .noAccount:
                    print("No account")
                case .temporarilyUnavailable:
                    print("Temporariry unavailable")
                @unknown default:
                    print("iCloud default")
                }
            }
        }
    }
}

@main
struct NettyApp: App {
    
    @StateObject private var logInAndOutViewModel = LogInAndOutViewModel()
    @State private var showLaunchView: Bool = true
    
    init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : UIColor(.theme.accent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor(.theme.accent)]
//        UITableView.appearance().backgroundColor = UIColor.clear
//        UINavigationBar.appearance().backgroundColor = UIColor(.theme.background)
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(.theme.accent)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if logInAndOutViewModel.userRecordId != nil {
                    MainScreenView(userRecordId: logInAndOutViewModel.userRecordId, logOutFunc: logInAndOutViewModel.logOut)
                        .transition(.opacity)
                } else {
                    LogInView()
                        .environmentObject(logInAndOutViewModel)
                        .transition(.opacity)
                }
                
                
                if showLaunchView {
                    LaunchView(showLaunchView: $showLaunchView)
                        .zIndex(2.0)
                }
            }
            .persistentSystemOverlays(.hidden)
            .alert(Text(logInAndOutViewModel.alertTitle), isPresented: $logInAndOutViewModel.showAlert, actions: {}, message: {
                Text(logInAndOutViewModel.alertMessage)
            })
        }
    }
}

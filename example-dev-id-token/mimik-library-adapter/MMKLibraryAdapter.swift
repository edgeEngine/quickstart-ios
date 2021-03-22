//
//  MMKLibraryAdapter.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2021-02-25.
//

import MIMIKEdgeMobileClient

class MMKLibraryAdapter: NSObject {
    class var sharedInstance: MMKLibraryAdapter {
        struct Singleton {
            static let instance = MMKLibraryAdapter()
        }

        return Singleton.instance
    }
    
    var edgeMobileClient: MIMIKEdgeMobileClient!
    
    private override init() {
        super.init()
        self.setupClientLibrary()
    }
    
    private func setupClientLibrary() -> Void {
        self.edgeMobileClient = MIMIKEdgeMobileClient.init()
        self.updateClientLibraryConfiguration()
    }
    
    func updateClientLibraryConfiguration() -> Void {
        
        guard let checkedEdgeMobileClient = self.edgeMobileClient else {
            print("⚠️⚠️⚠️ MMKLibraryAdapter updateClientLibraryConfiguration error (client)")
            return
        }
        
        checkedEdgeMobileClient.setBackendMode(backend: MMKLibraryAdapter.applicationBackend())
        checkedEdgeMobileClient.setCustomConfiguration(configuration: MMKLibraryAdapter.customEdgeConfiguration())
        checkedEdgeMobileClient.setClientLibraryLogLevel(to: MMKLibraryAdapter.clientLibraryLogLevel())
        
        let params = MMKLibraryAdapter.edgeStartupParameters()
        checkedEdgeMobileClient.setEdgeEngineCustomStartupParameters(parameters: params)

        if let checkedUserAccessToken = MMKLibraryAdapter.currentUserAccessToken() {
            checkedEdgeMobileClient.saveLibraryUserAccessToken(token: checkedUserAccessToken)
        }
        
        MMKLibraryAdapter.additionalPrivateSetup()
    }
    
    class func cleanupAfterLogout() -> Void {
        MIMIKObjectsStore.edgeAccessToken = nil
        MIMIKObjectsStore.userAccessToken = nil
        MIMIKObjectsStore.transientTokens = nil
        MIMIKObjectsStore.profileUser = nil
        MIMIKObjectsStore.identityUser = nil
        MIMIKObjectsStore.assessment = nil
    }
}

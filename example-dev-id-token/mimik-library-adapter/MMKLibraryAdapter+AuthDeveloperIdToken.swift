//
//  MMKLibraryAdapter.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2021-03-17.
//

import RxSwift
import MIMIKEdgeMobileClient

extension MMKLibraryAdapter {
    
    class func authorizeWithDeveloperIdToken(_ developerIdToken: String) -> Observable<MIMIKAuthStateResult> {
        return Observable.create { observer in
            
            self.sharedInstance.edgeMobileClient.authorizeWithDeveloperIdToken(appAuthConfig: self.applicationAuthorizationConfig(), developerIdToken: developerIdToken) { (result) in
                
                guard result.error == nil else {
                    MIMIKLog.log(message: "⚠️⚠️⚠️ completeAuthorizationWith error.", type: .error, subsystem: .mimikEdgeMobileClientAdapter)
                    observer.onError(result.error!)
                    return
                }
                
                guard let checkedTokens = result.tokens, let checkedEdgeAccessToken = checkedTokens.accessToken else {
                    MIMIKLog.log(message: "⚠️⚠️⚠️ completeAuthorizationWith error (tokens).", type: .error, subsystem: .mimikEdgeMobileClientAdapter)
                    observer.onError(NSError.init(domain: "completeAuthorizationWith error (tokens).", code: 500, userInfo: nil))
                    return
                }
                
                MIMIKLog.log(message: "⚠️⚠️⚠️ completeAuthorizationWith Success. checkedTokens.accessToken: \(checkedTokens.accessToken ?? "N/A")", type: .info, subsystem: .mimikEdgeMobileClientAdapter)
                MIMIKObjectsStore.edgeAccessToken = checkedTokens
                MIMIKObjectsStore.transientTokens = nil
                self.sharedInstance.edgeMobileClient.saveLibraryEdgeAccessToken(token: checkedEdgeAccessToken)
                observer.onNext(result)
                observer.onCompleted()
            }
            
            return Disposables.create {}
        }
    }
}

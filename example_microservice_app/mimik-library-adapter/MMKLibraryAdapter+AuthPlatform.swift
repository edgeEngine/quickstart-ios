//
//  MMKLibraryAdapter.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2021-03-01.
//

import MIMIKEdgeMobileClient
import RxSwift

extension MMKLibraryAdapter {
    
    // authorizePlatform (MIMIK MID)
    class func authorizePlatform(_ viewController: UIViewController) -> Observable<MIMIKAuthStateResult> {
        
        return Observable.create { observer in
            
            self.sharedInstance.edgeMobileClient.authorizePlatform(authConfig: self.platformAuthorizationConfig(), viewController: viewController, completion: { result in
                
                DispatchQueue.main.async {
                    
                    guard result.error == nil else {
                        print("⚠️⚠️⚠️ authorizePlatform error.")
                        observer.onError(result.error!)
                        return
                    }
                    
                    guard let checkedTokens = result.tokens else {
                        print("⚠️⚠️⚠️ authorizePlatform error (tokens)")
                        observer.onError(NSError.init(domain: "authorizePlatform error (tokens)", code: 500, userInfo: nil))
                        return
                    }
                    
                    MIMIKObjectsStore.edgeAccessToken = checkedTokens
                    
                    print("⚠️⚠️⚠️ authorizePlatform success")
                    observer.onNext(result)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create {}
        }
    }
    
    class func unauthorizePlatform(_ viewController: UIViewController) -> Observable<MIMIKAuthStateResult> {
        
        return Observable.create { observer in
            
            self.sharedInstance.edgeMobileClient.unauthorize(authConfig: self.platformUnauthorizationConfig(), viewController: viewController, completion: { result in
                
                DispatchQueue.main.async {
                    
                    guard result.error == nil else {
                        print("⚠️⚠️⚠️ unauthorizePlatform error.")
                        observer.onError(result.error!)
                        return
                    }
                    
                    MMKLibraryAdapter.cleanupAfterLogout()
                    print("⚠️⚠️⚠️ unauthorizePlatform Success.")
                    observer.onNext(result)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create {}
        }
    }
}

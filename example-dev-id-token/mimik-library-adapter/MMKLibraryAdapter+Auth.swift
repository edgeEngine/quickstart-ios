//
//  MMKLibraryAdapter.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2021-03-11.
//

import MIMIKEdgeMobileClient
import RxSwift

extension MMKLibraryAdapter {
    
    // determines if the user is considered to be logged in
    class func userIsLoggedIn() -> Bool {
        guard let checkedCurrentUser = self.currentIdentity() else {
            return false
        }
        
        return userIsLoggedIn(user: checkedCurrentUser)
    }
        
    class func userIsLoggedIn(user: IdentityUser) -> Bool {
        
        guard let checkedUserAccessToken = self.currentUserAccessToken() else {
            print("⚠️⚠️⚠️ User is not logged in (token)")
            return false
        }
        
        guard let checkedExpirationDateString = MMKTools.valueFromToken(token: checkedUserAccessToken, key: "exp"), let checkedExpirationDateTimeInterval = TimeInterval.init(checkedExpirationDateString)  else {
            print("⚠️⚠️⚠️ User is not logged in (value)")
            return false
        }
        
        guard let checkedExpirationDate = Date.init(timeIntervalSince1970: checkedExpirationDateTimeInterval) as Date?  else {
            print("⚠️⚠️⚠️ User is not logged in (date)")
            return false
        }

        guard checkedExpirationDate > Date() else {
            print("⚠️⚠️⚠️ User is not logged in (expiry)")
            return false
        }
        
        return true
    }
    
    class func applicationIdentityUser() -> Observable<IdentityUser> {
        return Observable.create { observer in
            
//            MIMIKLog.log(message: "⚠️⚠️⚠️ applicationIdentityUser started", type: .info, subsystem: .mimikEdgeMobileClientAdapter)
            
            self.sharedInstance.edgeMobileClient.applicationUser(self.applicationAuthorizationConfig()) { (applicationUser) in
                
                guard let checkedApplicationUser = applicationUser else {
                    observer.onError(NSError.init(domain: "applicationIdentityUser error.", code: 500, userInfo: nil))
                    return
                }
                
                MMKLibraryAdapter.storeIdentity(user: checkedApplicationUser)
                observer.onNext(checkedApplicationUser)
                observer.onCompleted()
            }
            
            return Disposables.create {}
        }
    }
    
    class func unauthorize() -> Observable<Bool> {
        return Observable.create { observer in
            
            MIMIKLog.log(message: "⚠️⚠️⚠️ unauthorize started", type: .info, subsystem: .mimikEdgeMobileClientAdapter)
            
            self.sharedInstance.edgeMobileClient.unauthorize(authConfig: self.applicationAuthorizationConfig()) { (result) in
                observer.onNext(result)
                observer.onCompleted()
            }
            
            return Disposables.create {}
        }
    }
}

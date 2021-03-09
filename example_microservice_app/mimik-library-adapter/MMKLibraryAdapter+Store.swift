//
//  MMKLibraryAdapter.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2021-02-22
//

import MIMIKEdgeMobileClient
import RxSwift


extension MMKLibraryAdapter {

    // These are transient token information bits, for example when tenant authentication is in process
    class func currentTransientTokens() -> MIMIKAuthTokens? {
        return MIMIKObjectsStore.transientTokens
    }
    
    // This is usually used as Authorization Bearer in request headers for microservices calls
    class func currentEdgeAccessToken() -> String? {
        return MIMIKObjectsStore.edgeAccessToken?.accessToken
    }
       
    // This is usually used for accessing backend resources, usually specified in the request query
    class func currentUserAccessToken() -> String? {
        return MIMIKObjectsStore.userAccessToken?.accessToken
    }
    
    class func currentIdentity() -> IdentityUser? {
        return MIMIKObjectsStore.identityUser
    }
    
    class func currentProfile() -> ProfileUser? {
        return MIMIKObjectsStore.profileUser
    }
    
    class func currentAssessmentProfile() -> Assessment? {
        return MIMIKObjectsStore.assessment
    }
}

extension MMKLibraryAdapter {
    class func storeProfileObservable(user: ProfileUser) -> Observable<Bool> {
        return Observable.create { observer in
            self.storeProfile(user: user)
            observer.onNext(true)
            return Disposables.create {}
        }
    }
    
    class func storeProfile(user: ProfileUser) -> Void {
        MIMIKObjectsStore.storeString(value: "\(Date().timeIntervalSince1970)" , key: MIMIKObjectsStore.kMMKLibraryAdapterStoreCurrentUserProfileCacheTimeInterval)
        MIMIKObjectsStore.profileUser = user
    }
    
    class func storeAssessmentObservable(user: Assessment) -> Observable<Bool> {
        return Observable.create { observer in
            MIMIKObjectsStore.storeString(value: "\(Date().timeIntervalSince1970)" , key: MIMIKObjectsStore.kMMKLibraryAdapterStoreCurrentAssessmentProfileCacheTimeInterval)
            MIMIKObjectsStore.assessment = user
            observer.onNext(true)
            return Disposables.create {}
        }
    }
    
    class func storeIdentityObservable(user: IdentityUser) -> Observable<Bool> {
        return Observable.create { observer in
            self.storeIdentity(user: user)
            observer.onNext(true)
            return Disposables.create {}
        }
    }
    
    class func storeIdentity(user: IdentityUser) -> Void {
        MIMIKObjectsStore.storeString(value: "\(Date().timeIntervalSince1970)" , key: MIMIKObjectsStore.kMMKLibraryAdapterStoreCurrentIdentityProfileCacheTimeInterval)
        MIMIKObjectsStore.identityUser = user
    }
}

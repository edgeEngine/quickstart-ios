//
//  MMKLibraryAdapter+Engine.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2021-03-12.
//

import MIMIKEdgeMobileClient
import RxSwift

extension MMKLibraryAdapter {
    
    class func startEdgeEngineObservable() -> Observable<Bool> {
        return Observable.create { observer in
            
            MMKLibraryAdapter.sharedInstance.updateClientLibraryConfiguration()
            
            self.sharedInstance.edgeMobileClient.startEdgeEngine { (result) in

                guard result == true else {
                    print("⚠️⚠️⚠️ MMKLibraryAdapter startEdgeEngineObservable error.")
                    observer.onNext(false)
                    return
                }

                observer.onNext(true)
                print("⚠️⚠️⚠️ MMKLibraryAdapter startEdgeEngineObservable success.")
            }
                        
            return Disposables.create {}
        }
    }
    
    class func startEdgeEngine(_ completion: ((_ result: Bool) -> Void)? = nil) {
        
        MMKLibraryAdapter.sharedInstance.updateClientLibraryConfiguration()
            
        self.sharedInstance.edgeMobileClient.startEdgeEngine { (result) in
            guard result == true else {
                print("⚠️⚠️⚠️ MMKLibraryAdapter startEdgeEngine error.")
                completion?(result)
                return
            }

            print("⚠️⚠️⚠️ MMKLibraryAdapter startEdgeEngine success.")
            completion?(result)
        }
    }
    
    class func stopEdgeEngineSynchronously() -> Void {
        self.sharedInstance.edgeMobileClient.stopEdgeEngineSynchronously()
        print("⚠️⚠️⚠️ MMKLibraryAdapter stopEdgeEngineSynchronously success.")
    }
    
    class func stopEdgeEngineObservable() -> Observable<Bool> {
        return Observable.create { observer in
                        
            self.sharedInstance.edgeMobileClient.stopEdgeEngine { (result) in
                guard result == true else {
                    print("⚠️⚠️⚠️ MMKLibraryAdapter stopEdgeEngineObservable error.")
                    observer.onNext(false)
                    return
                }

                observer.onNext(true)
                print("⚠️⚠️⚠️ MMKLibraryAdapter stopEdgeEngineObservable success.")
            }
                        
            return Disposables.create {}
        }
    }
    
    class func stopEdgeEngine(_ completion: ((_ result: Bool) -> Void)? = nil) {
        
        self.sharedInstance.edgeMobileClient.stopEdgeEngine { (result) in
            guard result == true else {
                print("⚠️⚠️⚠️ MMKLibraryAdapter stopEdgeEngine error.")
                completion?(result)
                return
            }

            print("⚠️⚠️⚠️ MMKLibraryAdapter stopEdgeEngine success.")
            completion?(result)
        }
    }
    
    class func restartEdgeEngine(_ completion: ((_ result: Bool) -> Void)? = nil) {
        self.sharedInstance.edgeMobileClient.stopEdgeEngine { (stopResult) in
            guard stopResult == true else {
                print("⚠️⚠️⚠️ MMKLibraryAdapter restartEdgeEngine error (stop)")
                completion?(false)
                return
            }

            MMKLibraryAdapter.sharedInstance.updateClientLibraryConfiguration()

            self.sharedInstance.edgeMobileClient.startEdgeEngine { (startResult) in
                guard startResult == true else {
                    print("⚠️⚠️⚠️ MMKLibraryAdapter restartEdgeEngine error (start)")
                    completion?(false)
                    return
                }

                print("⚠️⚠️⚠️ MMKLibraryAdapter restartEdgeEngine success.")
                completion?(true)
            }
        }
    }
    
    class func edgeServiceLinkUrl() -> URL? {
        guard let checkedPlatformServiceLink = MMKLibraryAdapter.sharedInstance.edgeMobileClient.platformServiceLink() else {
            return nil
        }
        
        return URL.init(string: checkedPlatformServiceLink)
    }
    
    class func edgeServiceLink() -> String? {
        return MMKLibraryAdapter.sharedInstance.edgeMobileClient.platformServiceLink()
    }
    
    class func edgeWebSocketServiceLink() -> String? {
        return MMKLibraryAdapter.sharedInstance.edgeMobileClient.platformWebSocketServiceLink()
    }
    
    class func edgeServiceLinkURL() -> URL? {
        guard let checkedEdgeServiceLink = self.edgeServiceLink() else {
            return nil
        }
        
        let url = URL.init(string: checkedEdgeServiceLink)
        return url
    }
    
    class func edgeWorkingDirectory() -> String? {
        return MMKLibraryAdapter.sharedInstance.edgeMobileClient.platformWorkingDirectory()
    }
}

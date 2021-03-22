//
//  MMKLibraryAdapter.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2021-01-06.
//

import MIMIKEdgeMobileClient
import RxSwift
import SwiftyJSON

extension MMKLibraryAdapter {
    
    // An observable function template for testing flows, you can request a success or an error.
    class func vanilla(shouldSucceed: Bool) -> Observable<Bool> {
        return Observable.create { observer in
            
            if shouldSucceed {
                observer.onNext(shouldSucceed)
                observer.onCompleted()
            }
            else {
                observer.onError(NSError.init(domain: "Intentional Vanilla Error", code: 500, userInfo: nil))
            }
                        
            return Disposables.create {}
        }
    }

    class func getEdgeEngineIdToken() -> Observable<(token: String?, decoded: JSON?)> {

        return Observable.create { observer in

            self.sharedInstance.edgeMobileClient.edgeEngineIdToken() { result in
                observer.onNext(result)
                observer.onCompleted()
            }

            return Disposables.create {}
        }
    }
        
    class func getEdgeEngineInfo() -> Observable<MIMIKEdgeInfo?> {

        return Observable.create { observer in

            self.sharedInstance.edgeMobileClient.edgeEngineInfo() { (info) in

                guard let checkedInfo = info else {
                    print("⚠️⚠️⚠️ getEdgeInfo error.")
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }

                observer.onNext(checkedInfo)
                observer.onCompleted()
            }

            return Disposables.create {}
        }
    }
}

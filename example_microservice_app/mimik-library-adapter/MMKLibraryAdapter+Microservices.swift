//
//  MMKLibraryAdapter.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2020-01-19.
//

import RxSwift
import MIMIKEdgeMobileClient
import SwiftyJSON

extension MMKLibraryAdapter {
            
    class func deployCustomMicroservice(config: MIMIKMicroserviceDeploymentConfig, imageTarPath: String, onlyWhenImageIdHasNotBeenDeployedYet imageId: String? = nil) -> Observable<MIMIKMicroservice> {
        return Observable.create { observer in
            
            guard let checkedEdgeAccessToken = MMKLibraryAdapter.currentEdgeAccessToken(), let checkedClientId = MMKLibraryAdapter.clientId() as String? else {
                print("⚠️⚠️⚠️ MMKLibraryAdapter deploy error.")
                observer.onError(NSError.init(domain: "MMKLibraryAdapter deploy error", code: 500, userInfo: nil))
                return Disposables.create {}
            }
            
            if let checkedImageId = imageId {
                self.sharedInstance.edgeMobileClient.verifyDeployedMicroserviceMatching(imageId: checkedImageId, edgeAccessToken: checkedEdgeAccessToken) { (alreadyDeployedMicroservice) in
                    
                    if let checkedAlreadyDeployedMicroservice = alreadyDeployedMicroservice {
                        observer.onNext(checkedAlreadyDeployedMicroservice)
                        return
                    }
                    else {
                        self.sharedInstance.edgeMobileClient.deployCustomMicroservice(edgeAccessToken: checkedEdgeAccessToken, config: config, imageTarPath: imageTarPath, clientId: checkedClientId) { (microservice) in
                            
                            guard let checkedMicroservice = microservice else {
                                print("⚠️⚠️⚠️ MMKLibraryAdapter deploy error.")
                                observer.onError(NSError.init(domain: "MMKLibraryAdapter deploy error", code: 500, userInfo: nil))
                                return
                            }
                            
                            observer.onNext(checkedMicroservice)
                        }
                    }
                }
            }
            else {
                self.sharedInstance.edgeMobileClient.deployCustomMicroservice(edgeAccessToken: checkedEdgeAccessToken, config: config, imageTarPath: imageTarPath, clientId: checkedClientId) { (microservice) in
                    
                    guard let checkedMicroservice = microservice else {
                        print("⚠️⚠️⚠️ MMKLibraryAdapter deploy error.")
                        observer.onError(NSError.init(domain: "MMKLibraryAdapter deploy error", code: 500, userInfo: nil))
                        return
                    }
                    
                    observer.onNext(checkedMicroservice)
                }
            }
            
            return Disposables.create {}
        }
    }
    
    class func deployMIMIKMicroservice(type: MIMIKMicroserviceType, imageTarPath: String) -> Observable<MIMIKMicroservice> {
        return Observable.create { observer in
            
            guard let checkedEdgeAccessToken = MMKLibraryAdapter.currentEdgeAccessToken() else {
                return Disposables.create {}
            }
            
            self.sharedInstance.edgeMobileClient.deployMIMIKMicroservice(type: type, edgeAccessToken: checkedEdgeAccessToken, clientId: clientId(), imageTarPath: imageTarPath, apiKey: self.apiKey()) { (microservice) in
                
                guard let checkedMicroservice = microservice else {
                    print("⚠️⚠️⚠️ MMKLibraryAdapter deploy error.")
                    observer.onError(NSError.init(domain: "MMKLibraryAdapter deploy error", code: 500, userInfo: nil))
                    return
                }
                
                observer.onNext(checkedMicroservice)
            }
         
            return Disposables.create {}
        }
    }
    
    class func deployedMicroservices() -> Observable<[MIMIKMicroservice]> {
        
        return Observable.create { observer in
            
            guard let checkedEdgeAccessToken = MMKLibraryAdapter.currentEdgeAccessToken() else {
                observer.onError(NSError.init(domain: "deployMicroservices error (token)", code: 500, userInfo: nil))
                return Disposables.create {}
            }
            
            self.sharedInstance.edgeMobileClient.deployedMicroservices(edgeAccessToken: checkedEdgeAccessToken, completion: { microservices in
                
                guard let checkedMicroservices = microservices else {
                    return
                }
                
                observer.onNext(checkedMicroservices)
                observer.onCompleted()
            })
            
            return Disposables.create {}
        }
    }
    
    class func verifyMicroserviceMatching(imageId: String?) -> Observable<MIMIKMicroservice?> {
        
        return Observable.create { observer in
            
            guard let checkedImageId = imageId, let edgeAccessToken = currentEdgeAccessToken() else {
                observer.onNext(nil)
                return Disposables.create {}
            }
            
            self.sharedInstance.edgeMobileClient.verifyDeployedMicroserviceMatching(imageId: checkedImageId, edgeAccessToken: edgeAccessToken, completion: { microservice in
                
                guard let checkedMicroservice = microservice else {
                    observer.onNext(nil)
                    return
                }
                
                observer.onNext(checkedMicroservice)
                observer.onCompleted()
            })
            
            return Disposables.create {}
        }
    }
        
    class private func deployedImages(edgeAccessToken: String) -> Observable<[MIMIKMicroserviceImage]> {
        
        return Observable.create { observer in
            
            self.sharedInstance.edgeMobileClient.deployedMicroserviceImages(edgeAccessToken: edgeAccessToken, completion: { images in
    
                guard let checkedImages = images else {
                    return
                }
                
                observer.onNext(checkedImages)
                observer.onCompleted()
            })
            
            return Disposables.create {}
        }
    }
    
    class private func deployedContainers(edgeAccessToken: String) -> Observable<[MIMIKMicroserviceContainer]> {
        
        return Observable.create { observer in
            
            self.sharedInstance.edgeMobileClient.deployedMicroserviceContainers(edgeAccessToken: edgeAccessToken, completion: { containers in
                
                guard let checkedContainers = containers else {
                    return
                }
                
                observer.onNext(checkedContainers)
                observer.onCompleted()
            })
            
            return Disposables.create {}
        }
    }
    
    // This is where the .tar micro service is stored in the application's bundle
    class func resourcePathInBundle(named: String, dotExtension: String) -> String? {
        let microServiceBundlePath = Bundle.main.path(forResource: named, ofType: dotExtension)
        return microServiceBundlePath
    }
}

//
//  EdgeNode.swift
//  example_microservice_app
//
//  Created by Raduz Benicky on 2018-01-25.
//  Copyright © 2018 mimik. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MIMIKEdgeMobileClient

/**
 An object representing an edgeSDK node.
 
 * accountId: accountId the node is currently associated with
 * name: node name
 * id: node id
 * os: node operating system
 * urlString: node external service link (string)
 * url: node external service link
 * thisDevice: convenience check whether this is the current node
 */
class EdgeEngineNode: NSObject {

    var accountId: String?
    var name: String?
    var id: String?
    var os: String?
    var urlString: String?
    var url: URL?
    
    convenience init?(json: JSON) {
        
        self.init()
        
        let accountId = json["accountId"]
        if accountId != JSON.null {
            self.accountId = accountId.stringValue
        }
        
        let name = json["name"]
        if name != JSON.null {
            self.name = name.stringValue
        }
        
        let id = json["id"]
        if id != JSON.null {
            self.id = id.stringValue
        }
        
        let os = json["os"]
        if os != JSON.null {
            self.os = os.stringValue
        }
        
        let url = json["url"]
        if url != JSON.null {
            self.urlString = url.stringValue
            self.url = URL.init(string: self.urlString!)
        }
    }
    
    func isThisDevice() -> Bool {
        return self.name == UIDevice.current.name
    }
    
    func displayName() -> String {
        
        guard let checkedName = self.name else {
            return "📱"
        }
        
        if self.isThisDevice() {
            return "📲 " + checkedName
        }
        else {
            return "📱 " + checkedName
        }
    }
    
    func displayServices() -> String {
        let value: String = "id: \(self.id ?? "") \nplatform: \(self.os ?? "")" + "\nurl: \(self.urlString ?? "external network")"
        return value
    }
    
    func getBEPURL(_ completion: @escaping ((url: URL?, error: Error?)) -> Void) {
        
        guard let edgeAccessToken = MMKLibraryAdapter.currentEdgeAccessToken(), let checkedEdgeServiceLink = MMKLibraryAdapter.edgeServiceLink() else {
            completion((nil, NSError.init(domain: "Unable to Proceed (token)", code: 500, userInfo: nil)))
            return
        }
        
        let microserviceBaseApiPath = MMKLibraryAdapter.microserviceDeployedBaseApiPath(type: .example, endpoint: .nodes)
        let link = checkedEdgeServiceLink + "/" + microserviceBaseApiPath

        guard let nodeId = self.id else {
            completion((nil, NSError.init(domain: "Unable to Proceed (nodeId)", code: 500, userInfo: nil)))
            return
        }
        
        let fullLink = link + "/" + nodeId
        let authenticatedLink = fullLink + "?userAccessToken=\(edgeAccessToken)"
        let headers = ["Authorization" : "Bearer \(edgeAccessToken)" ]
        let httpHeaders = HTTPHeaders.init(headers)
        
        AF.request(authenticatedLink, method: .get, parameters: nil, encoding: URLEncoding.default, headers: httpHeaders).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON.init(data)
                if json != JSON.null {
                    
                    MIMIKLog.log(message: "getBEPURL id: ", type: .info, value: " \(nodeId) response_json: \(json)", subsystem: .mimik_example_app)
                    
                    let code = json["code"]
                    if code != JSON.null {
                        let message = json["message"]
                        if message != JSON.null {
                            completion((nil, NSError.init(domain: message.stringValue, code: 500, userInfo: nil)))
                            return
                        }
                    }
                    
                    let urlString = json["url"]
                    guard !urlString.stringValue.isEmpty else {
                        completion((nil, NSError.init(domain: "Unable to Proceed", code: 500, userInfo: nil)))
                        return
                    }
                    
                    guard let url = URL.init(string: urlString.stringValue) else {
                        completion((nil, NSError.init(domain: "Unable to parse the response", code: 500, userInfo: nil)))
                        return
                    }
                    
                    completion((url, nil))
                }
                
            case .failure(let error):
                completion((nil, error))
            }
        }
    }
}

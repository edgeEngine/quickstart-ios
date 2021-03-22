//
//  MMKLibraryAdapter.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2021-03-22.
//


import MIMIKEdgeMobileClient

extension MMKLibraryAdapter {
    
    // platform client id
    class func clientId() -> String {
        return Developer.clientId()
    }
    
    // platform redirect url
    class func redirectUrl() -> URL {
        return URL.init(string: "com.mimik.example.appauth://oauth2callback")!
    }
    
    // mimik platform authorization
    class func authorizationRoot() -> URL {
        return URL.init(string: "https://mid.mimik360.com")!
    }
    
    class func applicationAuthorizationConfig() -> MIMIKAuthConfigApp {
        return MIMIKAuthConfigApp.init(clientId: self.clientId(), redirectUrl: self.redirectUrl(), additionalScopes: ["openid", "read:me", "edge:mcm", "edge:clusters", "edge:account:associate"], authorizationRootUrl: self.authorizationRoot())
    }
}

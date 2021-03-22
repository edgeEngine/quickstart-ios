//
//  MMKLibraryAdapter.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2020-12-22.
//

import MIMIKEdgeMobileClient

extension MMKLibraryAdapter {
    // this is a custom configuration string for initializing edge for a development backend
    class func customEdgeConfiguration() -> String? {
        return nil
    }
    
    class func edgeStartupParameters() -> MIMIKStartupParameters {
        return MIMIKStartupParameters.init(logLevel: .debug, nodeInfoLevel: .on, nodeName: nil)
    }
    
    class func clientLibraryLogLevel() -> MIMIKLogLevel {
        return .debug
    }
    
    class func additionalPrivateSetup() -> Void {
        // additional private custom setup
    }
}

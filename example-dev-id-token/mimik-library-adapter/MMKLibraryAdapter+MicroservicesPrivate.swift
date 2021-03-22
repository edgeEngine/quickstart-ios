//
//  MMKLibraryAdapter.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2021-01-06.
//

import MIMIKEdgeMobileClient

enum CustomMicroserviceType: String {
    case example
}

enum MicroserviceEndpoint: String {
    case drives_nearby = "drives?type=nearby"
    case drives_network = "drives?type=network"
    case nodes = "nodes"
    case hello = "hello"
}

extension MMKLibraryAdapter {
    
    class private func expectedImageId(type: CustomMicroserviceType) -> String {
        let clientId = MMKLibraryAdapter.clientId()
        let expectedImageId = clientId + "-" + self.expectedImageAndContainerName(type: type)
        return expectedImageId
    }
    
    class private func expectedImageAndContainerName(type: CustomMicroserviceType) -> String {
        return type.rawValue + "-v1"
    }
    
    class private func expectedMicroservicePath(type: CustomMicroserviceType) -> String {
        return type.rawValue + "-v1"
    }
    
    class private func envVariables(type: CustomMicroserviceType) -> [String: String] {
        
        guard let checkedEdgeServiceLink = MMKLibraryAdapter.edgeServiceLink() else {
            return [:]
        }
                
        switch type {
        case .example:
            var envVariables: [String: String] = [:]
            envVariables["BEAM"] = checkedEdgeServiceLink + "/beam/v1"
            envVariables["uMDS"] = checkedEdgeServiceLink + "/mds/v1"
            return envVariables
        }
    }
    
    class func microserviceBaseApiPath(type: CustomMicroserviceType) -> String {
        return "/" + type.rawValue + "/v1"
    }
    
    class func microserviceDeployedBaseApiPath(type: CustomMicroserviceType) -> String {
        return MMKLibraryAdapter.clientId() + "/" + type.rawValue + "/v1"
    }
    
    class func microserviceDeployedBaseApiPath(type: CustomMicroserviceType, endpoint: MicroserviceEndpoint) -> String {
        return MMKLibraryAdapter.clientId() + "/" + type.rawValue + "/v1/" + endpoint.rawValue
    }
    
    class func microserviceConfiguration(type: CustomMicroserviceType) -> MIMIKMicroserviceDeploymentConfig {
        let imageName = self.expectedImageAndContainerName(type: type)
        let containerName = self.expectedImageAndContainerName(type: type)
        let baseApiPath = self.microserviceBaseApiPath(type: type)
        let envVariables = self.envVariables(type: type)
        let config = MIMIKMicroserviceDeploymentConfig.init(imageName: imageName, containerName: containerName, baseApiPath: baseApiPath , envVariables: envVariables)
        return config
    }
        
    class func apiKey() -> String {
        guard let checkedStoredString = MIMIKObjectsStore.storedString(key: self.apiKeyStoreKey()) else {
            let newApiKey = UUID().uuidString
            MIMIKObjectsStore.storeString(value: newApiKey, key: self.apiKeyStoreKey())
            return newApiKey
        }
        
        return checkedStoredString
    }
    
    class private func apiKeyStoreKey() -> String {
        switch MMKLibraryAdapter.applicationBackend() {
        case .development:
            return "MMKLibraryAdapter.apikey.development"
        case .qa:
            return "MMKLibraryAdapter.apikey.qa"
        case .staging:
            return "MMKLibraryAdapter.apikey.staging"
        case .production:
            return "MMKLibraryAdapter.apikey.production"
        }
    }
}

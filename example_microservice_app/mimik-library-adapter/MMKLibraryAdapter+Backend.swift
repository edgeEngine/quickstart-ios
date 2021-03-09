//
//  MMKLibraryAdapter.swift
//  mimik technology inc.
//
//  Updated by Radúz Benický on 2020-12-22.
//

import MIMIKEdgeMobileClient

extension MMKLibraryAdapter {
    
    static let kManuallySelectedBackendString = "MMKLibraryAdapter.selectedBackend"
    
    // This is where a backend selection can be made, if it has not been made yet.
    class func setBackendTo(backend: MIMIKEdgeMobileClientBackend) -> Void {
        guard let checkedSelectedBackend = self.manuallySelectedBackend() else {
            UserDefaults.standard.set(backend.rawValue, forKey: kManuallySelectedBackendString)
            UserDefaults.standard.synchronize()
            print("⚠️⚠️⚠️ locking backend to: \(backend.rawValue)")
            return
        }
        
        print("⚠️⚠️⚠️ backend is already locked to: \(checkedSelectedBackend)")
    }
    
    // Selected backend, or nil if it has not been selected yet.
    class func manuallySelectedBackend() -> MIMIKEdgeMobileClientBackend? {
        guard let loadedBackendString = UserDefaults.standard.string(forKey: kManuallySelectedBackendString) else {
            return nil
        }
        
        let decodedLoadedBackend = MIMIKEdgeMobileClientBackend.init(rawValue: loadedBackendString)
        return decodedLoadedBackend
    }
    
    // Selected backend for the application environment. Or a default selection is forced if no selection has been made yet.
    class func applicationBackend() -> MIMIKEdgeMobileClientBackend {
        guard let checkedSelectedBackend = self.manuallySelectedBackend() else {
            self.forceDefaultBackendSelection()
            return self.defaultBackend()
        }
            
        return checkedSelectedBackend
    }
    
    // This is where a default backend will be forced for a RELEASE scheme.
    class func forceDefaultBackendSelection() -> Void {
        guard self.manuallySelectedBackend() != nil else {
            self.setBackendTo(backend: self.defaultBackend())
            print("⚠️⚠️⚠️ forced backend locking to: \(self.defaultBackend().rawValue)")
            return
        }
    }
    
    // Selected backend for the platform environment. Or a default selection is forced if no selection has been made yet.
    class func platformBackend() -> MIMIKEdgeMobileClientBackend {
        guard let checkedSelectedBackend = self.manuallySelectedBackend() else {
            self.setBackendTo(backend: self.defaultBackend())
            return self.defaultBackend()
        }
        
        return checkedSelectedBackend
    }
}

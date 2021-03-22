//
//  ViewController.swift
//  example_microservice_app
//
//  Created by Raduz Benicky on 2018-01-25.
//  Copyright © 2018 mimik. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SwiftyJSON
import RxSwift
import MIMIKEdgeMobileClient

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var edgeNodes: [EdgeEngineNode] = []
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var unauthorizeButton: UIButton!
    @IBOutlet weak var edgeIdButton: UIButton!
    @IBOutlet weak var edgeInfoButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var authorizeButton: UIButton!
    @IBOutlet weak var listNetworkButton: UIButton!
    @IBOutlet weak var listNearbyButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var bottomInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.bottomInfoLabel.text = "🔴 edgeEngine is not running."
    }
    
    @IBAction func startEdgeEngine(_ sender: UIButton) {
        
        self.enableAllButtons(enable: false)
        self.bottomInfoLabel.text = "🟢 Starting edgeEngine..."
        self.activitySpinner.startAnimating()
        
        // Intentionally delayed by 1s to give the developer time to read the UI messaging
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // First we start edgeEngine
            MMKLibraryAdapter.startEdgeEngine { (result) in
                
                self.activitySpinner.stopAnimating()
                
                // Check if edgeEngine startup was a success
                guard result == true else {
                    // Show an error if it didn't
                    MIMIKLog.log(message: "⛔️ start edgeEngine error", type: .error, subsystem: .mimik_example_app)
                    self.bottomInfoLabel.text = "⛔️ start edgeEngine error"
                    self.enableAllButtons(enable: true)
                    return
                }
                
                MIMIKLog.log(message: "🟢 edgeEngine is running.", type: .info, subsystem: .mimik_example_app)
                self.bottomInfoLabel.text = "🟢 edgeEngine is running."
                
                // Intentionally delayed by 1s to give the developer time to read the UI messaging
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // Then we get some runtime information about edgeEngine
                    MMKLibraryAdapter.getEdgeEngineInfo().observe(on: MainScheduler.instance).subscribe(on: MainScheduler.instance).subscribe(onNext: { info in
                        self.enableAllButtons(enable: true)
                        MIMIKLog.log(message: "🟢 edgeEngine.\nversion: \(info?.version ?? "")\nservice link: \(MMKLibraryAdapter.edgeServiceLink() ?? "")\nIP address: \(info?.linkLocalIp ?? "")", type: .info, subsystem: .mimik_example_app)
                        self.bottomInfoLabel.text = "🟢 edgeEngine.\nversion: \(info?.version ?? "")\nservice link: \(MMKLibraryAdapter.edgeServiceLink() ?? "")\nIP address: \(info?.linkLocalIp ?? "")"
                    }).disposed(by: self.disposeBag)
                }
            }
        }
    }
    
    @IBAction func stopEdgeEngine(_ sender: UIButton) {
        
        self.enableAllButtons(enable: false)
        self.bottomInfoLabel.text = "🔴 Stopping edgeEngine..."
        self.activitySpinner.startAnimating()
        
        // We will check on the synchronous shutdown process in 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.activitySpinner.stopAnimating()
            self.enableAllButtons(enable: true)
            
            MIMIKLog.log(message: "🔴 stop edgeEngine success.", type: .info, subsystem: .mimik_example_app)
            self.bottomInfoLabel.text = "🔴 edgeEngine is not running."
        }
  
        MMKLibraryAdapter.stopEdgeEngineSynchronously()
        MIMIKLog.log(message: "edgeEngine shutdown success", type: .info, subsystem: .mimik_example_app)
    }
    
    /**
     Starts the authentication session.
     */
    @IBAction func authorizationAction(_ sender: UIButton) {
        
        self.enableAllButtons(enable: false)
        self.bottomInfoLabel.text = "🟢 1. Starting edgeEngine\n🟢 2. Authorizing with developer id token\n🟢 3. Deploying microservice"
        self.activitySpinner.startAnimating()
        
        // Intentionally delayed by 1s to give the developer time to read the UI messaging
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            MMKLibraryAdapter.authorizeWithDeveloperIdToken(Developer.idToken()).observe(on: MainScheduler.instance).subscribe(on: MainScheduler.instance).subscribe(onNext: { (result) in

                guard result.error == nil else {
                    MIMIKLog.log(message: "⛔️ authorizationAction error", type: .error, subsystem: .mimik_example_app)
                    self.bottomInfoLabel.text = "⛔️ authorizationAction error"
                    self.activitySpinner.stopAnimating()
                    self.enableAllButtons(enable: true)
                    return
                }

                MIMIKLog.log(message: "🟢 Authorized with developer id token.", type: .info, subsystem: .mimik_example_app)
                self.bottomInfoLabel.text = "🟢 Authorized with developer id token."
                self.activitySpinner.stopAnimating()

                // Intentionally delayed by 1s to give the developer time to read the UI messaging
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.deployLocalMicroservices(sender)
                }

            }, onError: { (error) in
                MIMIKLog.log(message: "⛔️ authorizationAction error", type: .error, subsystem: .mimik_example_app)
                self.bottomInfoLabel.text = "⛔️ authorizationAction error"
                self.activitySpinner.stopAnimating()
                sender.isEnabled = true

            }).disposed(by: self.disposeBag)
        }
    }
    
    @IBAction func unauthorizeAction(_ sender: UIButton) {

        self.enableAllButtons(enable: false)
        self.bottomInfoLabel.text = "🔴 1. Stopping edgeEngine\n🔴 2. Unauthorizing tokens\n🔴 3. Removing content"
        self.activitySpinner.startAnimating()
        
        // Intentionally delayed by 1s to give the developer time to read the UI messaging
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            MMKLibraryAdapter.unauthorize().observe(on: MainScheduler.instance).subscribe(on: MainScheduler.instance).subscribe(onNext: { (result) in
                self.enableAllButtons(enable: true)
                
                guard result == true else {
                    MIMIKLog.log(message: "⛔️ Unauthorization error", type: .error, subsystem: .mimik_example_app)
                    self.bottomInfoLabel.text = "⛔️ Unauthorization error"
                    self.activitySpinner.stopAnimating()
                    return
                }

                MIMIKLog.log(message: "🔴 edgeEngine is not running.\n🔴 unauthorized.\n🔴 microservice removed", type: .info, subsystem: .mimik_example_app)
                self.bottomInfoLabel.text = "🔴 edgeEngine is not running. Content was reset."
                self.activitySpinner.stopAnimating()
                
            }, onError: { (error) in
                MIMIKLog.log(message: "⛔️ Unauthorization error", type: .error, subsystem: .mimik_example_app)
                self.bottomInfoLabel.text = "⛔️ Unauthorization error"
                self.activitySpinner.stopAnimating()
                sender.isEnabled = true
            }).disposed(by: self.disposeBag)
        }
    }
    
    /**
     Starts the example micro service loading process by uploading its content via a edgeSDK service URL.
     */
    func deployLocalMicroservices(_ sender: UIButton) {
        
        guard let checkedExampleTarPath = MMKLibraryAdapter.resourcePathInBundle(named: "example-v1", dotExtension: ".tar") else {
            self.bottomInfoLabel.text = "⛔️ Failed to deploy example microservice"
            return
        }

        self.enableAllButtons(enable: false)
        self.bottomInfoLabel.text = "🟢 Deploying microservice..."
        self.activitySpinner.startAnimating()
        let exampleConfig = MMKLibraryAdapter.microserviceConfiguration(type: .example)
        
        // Intentionally delayed by 1s to give the developer time to read the UI messaging
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            MMKLibraryAdapter.deployCustomMicroservice(config: exampleConfig, imageTarPath: checkedExampleTarPath).observe(on: MainScheduler.instance).subscribe(on: MainScheduler.instance).subscribe(onNext: { microservice in
                self.enableAllButtons(enable: true)
                
                self.bottomInfoLabel.text = "🟢 microservice deployed"
                
                // Intentionally delayed by 1s to give the developer time to read the UI messaging
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.bottomInfoLabel.text = "🟢 edge engine is running\n🟢 authorized.\n🟢 microservice deployed"
                }
                self.activitySpinner.stopAnimating()
            }, onError: { (error) in
                self.enableAllButtons(enable: true)
                self.bottomInfoLabel.text = "⛔️ Failed to deploy microservice."
                self.activitySpinner.stopAnimating()
            }).disposed(by: self.disposeBag)
        }
    }
    
    /**
     Uses MMKGetManager to sends a getNetwork API call that returns a list of edgeSDK nodes visible on the local network
     */
    @IBAction func getNodesNetwork() {
        
        self.enableAllButtons(enable: false)
        self.edgeNodes.removeAll()
        self.tableView.reloadData()
        
        CallManager.getNodes(type: .network, completion: { (nodes, error) in
            self.enableAllButtons(enable: true)
            
            guard error == nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = "⛔️ Unable to Proceed"
                return
            }
            
            guard nodes != nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = "⛔️ Unable to Proceed"
                return
            }
            
            self.edgeNodes = nodes!
            self.tableView.reloadData()

            let nodeString: String = self.edgeNodes.count == 1 ? "node" : "nodes"
            self.bottomInfoLabel.text = "🟢 Discovered \(self.edgeNodes.count) \(nodeString)"
        })
    }

    /**
     Uses MMKGetManager to sends a getNearby API call that returns a list of edge nodes visible across all networks considered within a "proximity" distance.
     - Remarks: The returned list will be either IP or GPS location based, depending on whether device's GPS location information has been sent to edgeSDK.
     */
    @IBAction func getNodesNearbyAction() {

        self.enableAllButtons(enable: false)
        self.edgeNodes.removeAll()
        self.tableView.reloadData()
        
        CallManager.getNodes(type: .nearby, completion: { (nodes, error) in
            self.enableAllButtons(enable: true)
            
            guard error == nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = "⛔️ Unable to Proceed"
                return
            }
            
            guard nodes != nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = "⛔️ Unable to Proceed"
                return
            }
            
            self.edgeNodes = nodes!
            self.tableView.reloadData()

            let nodeString: String = self.edgeNodes.count == 1 ? "node" : "nodes"
            self.bottomInfoLabel.text = "🟢 Discovered \(self.edgeNodes.count) \(nodeString)"
        })
    }
        
    @IBAction func getEdgeInfo(_ sender: UIButton) {
        self.enableAllButtons(enable: false)
        
        MMKLibraryAdapter.getEdgeEngineInfo().observe(on: MainScheduler.instance).subscribe(on: MainScheduler.instance).subscribe(onNext: { result in
            self.enableAllButtons(enable: true)
            
            guard let checkedDescription = result?.mimikDescription else {
                self.bottomInfoLabel.text = "⛔️ Unable to Proceed"
                return
            }
            
            print("🟢 info: \(checkedDescription)")
            self.bottomInfoLabel.text = "🟢 info: \(checkedDescription)"
        }).disposed(by: self.disposeBag)
    }
    
    @IBAction func getEdgeIdToken(_ sender: UIButton) {
        MMKLibraryAdapter.getEdgeEngineIdToken().observe(on: MainScheduler.instance).subscribe(on: MainScheduler.instance).subscribe(onNext: { result in
            guard let checkedDescription = result.decoded?.rawString() else {
                self.bottomInfoLabel.text = "⛔️ Unable to Proceed"
                return
            }
            
            print("🟢 id token: \(checkedDescription)")
            self.bottomInfoLabel.text = "🟢 id token: \(checkedDescription)"
            
        }).disposed(by: self.disposeBag)
    }
    
    @IBAction func listButtonPressed(_ sender: UIButton) {
        MMKLibraryAdapter.deployedMicroservices().subscribe(onNext: { (microservicesInfo) in
            print("🟢 microservicesInfo: \(microservicesInfo)")
            self.bottomInfoLabel.text = "🟢 \(microservicesInfo)"
                        
        }, onError: { (error) in
            print("⛔️ Unable to Proceed")
            self.bottomInfoLabel.text = "⛔️ Unable to Proceed"
            
        }).disposed(by: disposeBag)
    }
}

internal extension ViewController {
    func allButtons() -> [UIButton] {
        return [self.unauthorizeButton, self.edgeIdButton, self.edgeInfoButton, self.stopButton, self.startButton, self.authorizeButton, self.listNearbyButton, self.listNetworkButton, self.listButton]
    }
    
    func enableAllButtons(enable: Bool) -> Void {
        for (_, button) in self.allButtons().enumerated() {
            button.isEnabled = enable
        }
    }
}

internal extension ViewController {
    
    /**
     Determines which edgeSDK node has been selected, then gets an url to it and initiates a hello endpoint call on it.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = self.edgeNodes[indexPath.row]
        self.bottomInfoLabel.text = "Connecting to node: \(node.displayName()), please wait for a response."
        
        node.getBEPURL { (url, error) in
            let updatedNode: EdgeEngineNode = node
            
            if let checkedUrl = url {
                
                updatedNode.url = checkedUrl
                updatedNode.urlString = checkedUrl.absoluteString
                self.bottomInfoLabel.text = "Calling hello endpoint on node: \(node.urlString ?? "no-url-detected"), please wait for a response."
                
                CallManager.getHelloResponse(node: node, completion: { (json,error) in
                    
                    guard error == nil else {
                        self.tableView.reloadData()
                        self.bottomInfoLabel.text = "⛔️ Unable to Proceed"
                        return
                    }
                    
                    guard json != nil else {
                        self.tableView.reloadData()
                        self.bottomInfoLabel.text = "⛔️ Unable to Proceed"
                        return
                    }
                    
                    self.bottomInfoLabel.text = "🟢 \(json!["JSONMessage"]) received from \(node.displayName())"
                    MIMIKLog.log(message: "🟢 Hello response from node: ", type: .info, value: "\(node.urlString ?? "no-url-detected") json: \(json ?? JSON())", subsystem: .mimik_example_app)
                })
                
            }
            else if let checkedError = error {
                self.bottomInfoLabel.text = checkedError.localizedDescription
            }
            else {
                self.bottomInfoLabel.text = "⛔️ An unknown Error occured"
            }
        }
    }
    
    /**
     Returns a number of edgeSDK nodes for the table
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.edgeNodes.count
    }
    
    /**
     Prepares the UI for each cell.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "NodeCell")!
        let node = self.edgeNodes[indexPath.row]
        cell.textLabel?.text = node.displayName()
        cell.detailTextLabel?.text = node.displayServices()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

///**
// EdgeAppOpsProtocol. Getting calls about edgeSDK state changes.
// */
extension ViewController: MIMIKEdgeMobileClientDelegate {
    func edgeEngineStateChanged(event: MIMIKStateChangingEvent) {
        MIMIKLog.log(message: "edgeEngineStateChanged to: ", type: .info, value: "event: \(event.rawValue)", subsystem: .mimik_example_app)
    }
}

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
    }
        
    @IBAction func startEdgeEngine(_ sender: UIButton) {        
        self.bottomInfoLabel.text = "Starting edgeEngine on this device."
        
        // First we start edgeEngine
        MMKLibraryAdapter.startEdgeEngine { (result) in
            
            // Check if edgeEngine startup was a success
            guard result == true else {
                // Show an error if it didn't
                MIMIKLog.log(message: "⛔️ start edgeEngine error", type: .error, subsystem: .mimik_example_app)
                self.bottomInfoLabel.text = "⛔️ start edgeEngine error"
                return
            }
            
            // Then we get some runtime information about edgeEngine
            MMKLibraryAdapter.getEdgeEngineInfo().observe(on: MainScheduler.instance).subscribe(onNext: { info in
                MIMIKLog.log(message: "👍 start edgeEngine success. \n ### \(info?.linkLocalIp ?? "N/A") \n ### \(MMKLibraryAdapter.edgeServiceLink() ?? "N/A")", type: .info, subsystem: .mimik_example_app)
                self.bottomInfoLabel.text = "👍 edgeEngine \(info?.version ?? "N/A") started\nlinkLocalIp: \(info?.linkLocalIp ?? "N/A")\nservice link: \(MMKLibraryAdapter.edgeServiceLink() ?? "N/A")"
            }).disposed(by: self.disposeBag)
        }
    }
    
    @IBAction func stopEdgeEngine(_ sender: UIButton) {
        self.bottomInfoLabel.text = "Stopping edgeEngine on this device."
        MMKLibraryAdapter.stopEdgeEngine { (result) in
            
            guard result == true else {
                MIMIKLog.log(message: "⛔️ stop edgeEngine error.", type: .error, subsystem: .mimik_example_app)
                self.bottomInfoLabel.text = "⛔️ stop edgeEngine error."
                return
            }
            
            MIMIKLog.log(message: "👍 stop edgeEngine success.", type: .info, subsystem: .mimik_example_app)
            self.bottomInfoLabel.text = "👍 stop edgeEngine success."
        }
    }
    
    /**
     Starts the authentication session.
     */
    @IBAction func authorizationAction(_ sender: UIButton) {
        sender.isEnabled = false
        self.bottomInfoLabel.text = "Authorization in progress..."
        self.activitySpinner.startAnimating()
        
        MMKLibraryAdapter.authorizePlatform(self).observe(on: MainScheduler.instance).subscribe(onNext: { (result) in
            
            sender.isEnabled = true
            
            guard result.error == nil else {
                MIMIKLog.log(message: "⛔️ authorizePlatform error", type: .error, subsystem: .mimik_example_app)
                self.bottomInfoLabel.text = "⛔️ authorizePlatform error"
                self.activitySpinner.stopAnimating()
                return
            }

            MIMIKLog.log(message: "👍 authorizePlatform success.", type: .info, subsystem: .mimik_example_app)
            self.bottomInfoLabel.text = "👍 authorizePlatform success."
            self.activitySpinner.stopAnimating()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.deployLocalMicroservices(sender)
            }
            
        }, onError: { (error) in
            MIMIKLog.log(message: "⛔️ authorizePlatform error", type: .error, subsystem: .mimik_example_app)
            self.bottomInfoLabel.text = "⛔️ authorizePlatform error"
            self.activitySpinner.stopAnimating()
            sender.isEnabled = true
            
        }).disposed(by: self.disposeBag)
    }
    
    
    @IBAction func unauthorizeAction(_ sender: UIButton) {
        sender.isEnabled = false
        self.bottomInfoLabel.text = "Unauthorization in progress..."
        self.activitySpinner.startAnimating()
        
        MMKLibraryAdapter.unauthorizePlatform(self).observe(on: MainScheduler.instance).subscribe(onNext: { (result) in
            
            sender.isEnabled = true
            
            guard result.error == nil else {
                MIMIKLog.log(message: "⛔️ unauthorizePlatform error", type: .error, subsystem: .mimik_example_app)
                self.bottomInfoLabel.text = "⛔️ unauthorizePlatform error"
                self.activitySpinner.stopAnimating()
                return
            }

            MIMIKLog.log(message: "👍 unauthorizePlatform success.", type: .info, subsystem: .mimik_example_app)
            self.bottomInfoLabel.text = "👍 unauthorizePlatform success."
            self.activitySpinner.stopAnimating()
            
        }, onError: { (error) in
            MIMIKLog.log(message: "⛔️ unauthorizePlatform error", type: .error, subsystem: .mimik_example_app)
            self.bottomInfoLabel.text = "⛔️ unauthorizePlatform error"
            self.activitySpinner.stopAnimating()
            sender.isEnabled = true
            
        }).disposed(by: self.disposeBag)
    }
    
    /**
     Starts the example micro service loading process by uploading its content via a edgeSDK service URL.
     */
    func deployLocalMicroservices(_ sender: UIButton) {
        
        self.bottomInfoLabel.text = "Deploying example micro service locally..."
        self.activitySpinner.startAnimating()
        
        guard let checkedExampleTarPath = MMKLibraryAdapter.resourcePathInBundle(named: "example-v1", dotExtension: ".tar") else {
            self.bottomInfoLabel.text = "⛔️ Failed to deploy example"
            self.activitySpinner.stopAnimating()
            sender.isEnabled = true
            return
        }
        
        let exampleConfig = MMKLibraryAdapter.microserviceConfiguration(type: .example)
        
        MMKLibraryAdapter.deployCustomMicroservice(config: exampleConfig, imageTarPath: checkedExampleTarPath).subscribe(onNext: { microservice in
            
            self.bottomInfoLabel.text = "👍 Deployed \(microservice.image?.name ?? "N/A")"
            self.activitySpinner.stopAnimating()
                        
        }, onError: { (error) in
            
            self.bottomInfoLabel.text = "⛔️ Failed to deploy microservice."
            self.activitySpinner.stopAnimating()
            
        }).disposed(by: self.disposeBag)
    }
    
    /**
     Uses MMKGetManager to sends a getNetwork API call that returns a list of edgeSDK nodes visible on the local network
     */
    @IBAction func getNodesNetwork() {
        
        self.edgeNodes.removeAll()
        self.tableView.reloadData()
        
        CallManager.getNodes(type: .network, completion: { (nodes, error) in
            
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
            self.bottomInfoLabel.text = "👍 Received information about \(self.edgeNodes.count) \(nodeString)"
        })
    }

    /**
     Uses MMKGetManager to sends a getNearby API call that returns a list of edge nodes visible across all networks considered within a "proximity" distance.
     - Remarks: The returned list will be either IP or GPS location based, depending on whether device's GPS location information has been sent to edgeSDK.
     */
    @IBAction func getNodesNearbyAction() {

        self.edgeNodes.removeAll()
        self.tableView.reloadData()
        
        CallManager.getNodes(type: .nearby, completion: { (nodes, error) in
            
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
            self.bottomInfoLabel.text = "👍 Received information about \(self.edgeNodes.count) \(nodeString)"
        })
    }
        
    @IBAction func getEdgeInfo(_ sender: UIButton) {
        MMKLibraryAdapter.getEdgeEngineInfo().observe(on: MainScheduler.instance).subscribe(onNext: { result in
            guard let checkedDescription = result?.mimikDescription else {
                self.bottomInfoLabel.text = "⛔️ Unable to Proceed"
                return
            }
            
            print("👍 info: \(checkedDescription)")
            self.bottomInfoLabel.text = "👍 info: \(checkedDescription)"
        }).disposed(by: self.disposeBag)
    }
    
    @IBAction func getEdgeIdToken(_ sender: UIButton) {
        MMKLibraryAdapter.getEdgeEngineIdToken().observe(on: MainScheduler.instance).subscribe(onNext: { result in
            guard let checkedDescription = result.decoded?.rawString() else {
                self.bottomInfoLabel.text = "⛔️ Unable to Proceed"
                return
            }
            
            print("👍 id token: \(checkedDescription)")
            self.bottomInfoLabel.text = "👍 id token: \(checkedDescription)"
            
        }).disposed(by: self.disposeBag)
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
                    
                    self.bottomInfoLabel.text = "👍 \(json!["JSONMessage"]) received from \(node.displayName())"
                    MIMIKLog.log(message: "👍 Hello response from node: ", type: .info, value: "\(node.urlString ?? "no-url-detected") json: \(json ?? JSON())", subsystem: .mimik_example_app)
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

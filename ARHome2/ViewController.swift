//
//  ViewController.swift
//  ARHome2
//
//  Created by Roderic Campbell on 6/5/17.
//  Copyright © 2017 Roderic Campbell. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var hasRun = false
    var house = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        if let houseScene = SCNScene(named: "art.scnassets/Arbutus.dae") {
//        if let houseNode = SCNScene(named: "art.scnassets/RandomShape.dae") {
            print("house node is")
            house = houseScene.rootNode
            print("house dimensions \(house.boundingBox)")
        }
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @IBAction func addAnchor(_ sender: Any) {
        let anchor = ARAnchor(transform: matrix_identity_float4x4)
        sceneView.session.add(anchor: anchor)
    }
    
    // MARK: - ARSCNViewDelegate
    
    func beachBallGeometry() -> SCNGeometry {
        
        let blue = SCNMaterial()
        blue.diffuse.contents = UIColor.blue
        
        let yellow = SCNMaterial()
        yellow.diffuse.contents = UIColor.yellow
        
        // Now create the geometry and set the colors
        let geometry = SCNBox(width: 0.1, height:  0.1, length:  0.1, chamferRadius: 4.0)
        geometry.materials = [blue, yellow, blue, yellow, blue, yellow]
        return geometry
    }
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        print("Thje frames are ", frame.anchors)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("There was an error with the session \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension ViewController: ARSessionDelegate {
    func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        print("These are updated")
        for anchor in anchors {
            print("updated anchors \(anchor)")
        }
        print("that is the end of the updates")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            print("did add node, pushed to main queue")
            if self.hasRun {
                return
            }
            if let planeAnchor = anchor as? ARPlaneAnchor {
                let pos = self.positionFromTransform(anchor.transform)
                print("NEW SURFACE DETECTED AT \(pos.friendlyString())")
                
                self.house.scale = SCNVector3Make(0.001, 0.001, 0.001)
                node.addChildNode(self.house)
                self.hasRun = true
                
//                self.updatePlane(anchor: planeAnchor)
//                self.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor)
            }
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print("did add anchor")
    }
    
    
}

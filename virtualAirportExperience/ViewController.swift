//
//  ViewController.swift
//  virtualAirportExperience
//
//  Created by Shubham on 1/4/23.
//

import UIKit
import SceneKit
import ARKit

// MARK: - App State Management
enum AppState: Int16 {
    case DetectSurface
    case PointAtSurface
    case TapAtStart
    case Started
}


class ViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var resetButton: UIButton!

    @IBAction func resetButtonAction(_ sender: Any) {
        print("DEBUG:: Reset Button is tapped")
    }
    
    @IBAction func tapGestureAction(_ sender: Any) {
        print("DEBUG:: Screen is tapped")
    }
    
    // MARK: - Lifecycle functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}



// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

// MARK: - App Management
extension ViewController {
  
  // Add code here...
  
}

// MARK: - AR Coaching Overlay
extension ViewController {
  
  // Add code here...
  
}

// MARK: - AR Session Management (ARSCNViewDelegate)
extension ViewController {
  
  // Add code here...
  
}

// MARK: - Scene Management
extension ViewController {
  
  // Add code here...
  
}

// MARK: - Focus Node Management
extension ViewController {
  
  // Add code here...
  
}


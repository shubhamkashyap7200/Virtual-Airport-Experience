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
    var trackingStatus: String = ""
    var statusMessage: String = ""
    var appState: AppState = .DetectSurface
    var focusPoint: CGPoint!
    var focusNode: SCNNode!
    var arPortNode: SCNNode!
    
    override var prefersStatusBarHidden: Bool {
      return true
    }
    
    // MARK: - Interface builders
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var resetButton: UIButton!
    
    @IBAction func resetButtonAction(_ sender: Any) {
        print("DEBUG:: Reset Button is tapped")
        self.resetARSession()
    }
    
    @IBAction func tapGestureAction(_ sender: Any) {
        print("DEBUG:: Screen is tapped")
        
        guard appState == .TapAtStart else { return }
        self.arPortNode.isHidden = false
        self.focusNode.isHidden = true
        self.arPortNode.position = self.focusNode.position
        appState = .Started
        
    }
    
    // MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initScene()
        self.initARSession()
        self.initCoachOverlayView()
        self.initFocusNode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      print("*** DidReceiveMemoryWarning()")
    }

}



// MARK: - AR Session Management (ARSCNViewDelegate)
extension ViewController: ARSCNViewDelegate {
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
            
        case .notAvailable:
            self.trackingStatus = "Tracking: Not avaiable!"
        case .limited(let reason):
            switch reason {
            case .initializing:
                self.trackingStatus = "Tracking: Initializing..."
            case .excessiveMotion:
                self.trackingStatus = "Tracking: Limited due to excessive motion"
            case .insufficientFeatures:
                self.trackingStatus = "Tracking: Limited due to insufficient features!"
            case .relocalizing:
                self.trackingStatus = "Tracking: Relocalizing..."
            @unknown default:
                self.trackingStatus = "Tracking: Unknown..."
            }
        case .normal:
            self.trackingStatus = ""
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        self.trackingStatus = "AR Session Failure: \(error.localizedDescription)"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        self.trackingStatus = "AR Session was Interrupted!)"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        self.trackingStatus = "AR Session was Ended!"
    }
    
    // MARK: - Helper Functions

    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("DEBUG:: ARConfig: ARWorldTracking is not supported")
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        config.environmentTexturing = .automatic
        
        sceneView.session.run(config)
    }
    
    func resetARSession() {
        let config = sceneView.session.configuration as! ARWorldTrackingConfiguration
        config.planeDetection = .horizontal
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
}

// MARK: - App Management
extension ViewController {
    
    // Add code here...
    // 1
    func startApp() {
        DispatchQueue.main.async {
            self.appState = .DetectSurface
        }
    }
    
    
    // 2
    func resetApp() {
        self.resetARSession()
        self.appState = .DetectSurface
    }
    
}

// MARK: - AR Coaching Overlay
extension ViewController: ARCoachingOverlayViewDelegate {
    
    // Add code here...
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        self.startApp()
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        self.resetApp()
    }
    
    func initCoachOverlayView() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = self.sceneView.session
        coachingOverlay.delegate = self
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.goal = .horizontalPlane
        self.sceneView.addSubview(coachingOverlay)
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: coachingOverlay, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: coachingOverlay, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: coachingOverlay, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: coachingOverlay, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0)
        ])
    }
    
}

// MARK: - Scene Management
extension ViewController {
    
    // Add code here...
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            if let touchLocation = touches.first?.location(in: self.sceneView) {
                if let hit = self.sceneView.hitTest(touchLocation, options: nil).first {
                    if hit.node.name == "Touch" {
                        let billboardNode = hit.node.childNode(withName: "BillBoard", recursively: false)
                        billboardNode?.isHidden = false
                    }
                    
                    if hit.node.name == "Billboard" {
                        hit.node.isHidden = true
                    }
                }
            }
        }
    }
    
    func initScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        
        let artPortScene = SCNScene(named: "art.scnassets/Scenes/ARPortScene.scn")!
        arPortNode = artPortScene.rootNode.childNode(withName: "ARPort", recursively: false)
        arPortNode.isHidden = true
        sceneView.scene.rootNode.addChildNode(arPortNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateStatus()
            self.updateFocusNode()
        }
    }
    
    func updateStatus() {
        switch appState {
        case .DetectSurface:
            statusMessage = "Scan available flat surfaces..."
        case .PointAtSurface:
            statusMessage = "Point at designated surface first"
        case .TapAtStart:
            statusMessage = "Tap to start"
        case .Started:
            statusMessage = "Tap objects for more info."
        }
        
        self.statusLabel.text = trackingStatus != "" ? "\(trackingStatus)" : "\(statusMessage)"
    }
    
}

// MARK: - Focus Node Management
extension ViewController {
    
    // MARK: - Helper Functions
    func initFocusNode() {
        
        let focusScene = SCNScene(named: "art.scnassets/Scenes/FocusScene.scn")!
        focusNode = focusScene.rootNode.childNode(withName: "Focus", recursively: false)
        focusNode.isHidden = true
        sceneView.scene.rootNode.addChildNode(focusNode)
        
        focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func updateFocusNode() {
        guard appState != .Started else { focusNode.isHidden = true; return }
        
        if let query = self.sceneView.raycastQuery(
            from: self.focusPoint,
            allowing: .estimatedPlane,
            alignment: .horizontal
        ) {
            let results = self.sceneView.session.raycast(query)
            if results.count == 1 {
                if let match = results.first {
                    let t = match.worldTransform
                    
                    self.focusNode.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
                    self.appState = .TapAtStart
                    focusNode.isHidden = false
                }
            }
            else {
                self.appState = .PointAtSurface
                focusNode.isHidden = true
            }
        }
    }
    
    // MARK: - Focus Node Selectors
    @objc func orientationChanged() {
        focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.1)
    }
}


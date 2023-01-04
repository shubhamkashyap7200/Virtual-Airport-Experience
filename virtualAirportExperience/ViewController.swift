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
    }
    
    // MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initScene()
        self.initARSession()
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
            NSLayoutConstraint(item: coachingOverlay, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)
        ])
    }
    
}

// MARK: - Scene Management
extension ViewController {
    
    // Add code here...
    func initScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateStatus()
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
    
    // Add code here...
    
}


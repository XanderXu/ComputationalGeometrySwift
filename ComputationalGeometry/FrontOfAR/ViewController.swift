//
//  ViewController.swift
//  FrontOfAR
//
//  Created by CoderXu on 2021/2/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
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
    @IBAction func frontBtnClick(_ sender: UIButton) {
        guard let front = sceneView.pointOfView?.simdWorldFront else {return}
//        let horizontalFront = normalize(simd_float3(front.x, 0, front.z))
        addChildNode(position: front, color: .red)
    }
    @IBAction func rightBtnClick(_ sender: UIButton) {
        guard let front = sceneView.pointOfView?.simdWorldFront else {return}
        var horazontalRight = cross(front, simd_float3(0, 1, 0))
        horazontalRight.y = front.y//手机前方 1 米处的高度
        addChildNode(position: horazontalRight, color: .green)
    }
    
    private func addChildNode(position:simd_float3, color:UIColor) {
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        cube.firstMaterial?.diffuse.contents = color
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.simdPosition = position
        sceneView.scene.rootNode.addChildNode(cubeNode)
    }
    // MARK: - ARSCNViewDelegate
    
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


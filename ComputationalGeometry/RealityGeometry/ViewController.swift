//
//  ViewController.swift
//  RealityGeometry
//
//  Created by 许海峰 on 2022/2/17.
//

import UIKit
import RealityKit
import ARKit
class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let boxAnchor = AnchorEntity(plane: .horizontal)
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        arView.debugOptions = [.showStatistics]
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config, options: [])
        
        let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.1,cornerRadius: 0.01),materials: [SimpleMaterial(color: .red, isMetallic: false)])
        box.position.y = 0.05
        boxAnchor.addChild(box)

        
    }
}

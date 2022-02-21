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
        
        var m = PhysicallyBasedMaterial()
        m.baseColor = .init(tint: .white, texture: .init(try! TextureResource.load(named: "number.jpeg", in: nil)))
        do {
            let mesh = try MeshResource.generateTorus(sides: 18, csSides: 360, radius: 0.1, csRadius: 0.02)
            let box = ModelEntity(mesh:mesh,materials: [m])
            box.position.y = 0.05
            box.name = "box"
            boxAnchor.addChild(box)
        } catch {
            print(error)
        }
    }
    @IBAction func segChanged(_ sender: UISegmentedControl) {
        if let box = arView.scene.findEntity(named: "box") as? ModelEntity {
            box.components.remove(ModelDebugOptionsComponent.self)
            switch sender.selectedSegmentIndex {
            case 0:
                break
            case 1:
                let debug = ModelDebugOptionsComponent(visualizationMode: .normal)
                box.components.set(debug)
            case 2:
                let debug = ModelDebugOptionsComponent(visualizationMode: .textureCoordinates)
                box.components.set(debug)
            default:
                break
            }
        }
        
    }
}

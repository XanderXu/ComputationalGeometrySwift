//
//  ViewController.swift
//  RealityGeometry
//
//  Created by CoderXu on 2022/2/17.
//

import UIKit
import RealityKit
import ARKit
class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let modelAnchor = AnchorEntity(plane: .horizontal)
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(modelAnchor)
//        arView.debugOptions = [.showStatistics]
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config, options: [])
        
        var m = PhysicallyBasedMaterial()
//        m.baseColor = .init(tint: .white, texture: nil)
        m.baseColor = .init(tint: .white, texture:.init(try! TextureResource.load(named: "number.jpeg", in: nil)))
        do {
            let mesh = try MeshResource.generateArcPlane(innerRadius: 0.1, outerRadius: 0.2, startAngle: 0, endAngle: Float.pi*2, angularResolution: 30, radialResolution: 5, circleUV: false)
            let model = ModelEntity(mesh:mesh,materials: [m])
            model.position.y = 0.05
            model.name = "model"
            modelAnchor.addChild(model)
        } catch {
            print(error)
        }
    }
    @IBAction func segChanged(_ sender: UISegmentedControl) {
        if let model = arView.scene.findEntity(named: "model") as? ModelEntity {
            model.components.remove(ModelDebugOptionsComponent.self)
            switch sender.selectedSegmentIndex {
            case 0:
                break
            case 1:
                let debug = ModelDebugOptionsComponent(visualizationMode: .normal)
                model.components.set(debug)
            case 2:
                let debug = ModelDebugOptionsComponent(visualizationMode: .textureCoordinates)
                model.components.set(debug)
            default:
                break
            }
        }
        
    }
}

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
        var m2 = PhysicallyBasedMaterial()
        m2.baseColor = .init(tint: .red, texture: nil)
        do {
//            let mesh = try MeshResource.generateCirclePlane(radius:0.1, angularResolution: 30, radialResolution: 5, circleUV: true)
//            let mesh = try MeshResource.generateArcPlane(innerRadius: 0.02, outerRadius: 0.2, startAngle: 0, endAngle: .pi, angularResolution: 30, radialResolution: 5, circleUV: true)
//            let mesh = try MeshResource.generateSquirclePlane(size: 0.2, p: 4, angularResolution: 30, radialResolution: 5, circleUV: true)
//            let mesh = try MeshResource.generateRoundedRectPlane(width: 0.2, depth: 0.2, radius: 0.05, angularResolution: 10, edgeXResolution: 5, edgeYResolution: 5, radialResolution: 5, circleUV: true)
            let mesh = try MeshResource.generateCone(radius: 0.2, height: 0.3, angularResolution: 24, radialResolution: 2, verticalResolution: 3, splitFaces: true, smoothNormals: true)
            let model = ModelEntity(mesh:mesh, materials: [m,m2])
            model.position.y = 0.15
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

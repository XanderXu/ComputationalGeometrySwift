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
//            let mesh = try MeshResource.generateRoundedRectPlane(width: 0.2, height: 0.2, radius: 0.05, angularResolution: 10, edgeXResolution: 5, edgeYResolution: 5, radialResolution: 5, circleUV: true)
//            let mesh = try MeshResource.generateCone(radius: 0.2, height: 0.3, angularResolution: 24, radialResolution: 2, verticalResolution: 3, splitFaces: true, circleUV: false)
//            let mesh = try MeshResource.generateCylinder(radius: 0.2, height: 0.2, angularResolution: 24, radialResolution: 2, verticalResolution: 3, splitFaces: false, circleUV: false)
//            let mesh = try MeshResource.generateCapsule(radius: 0.1, height: 0.1, angularResolution: 24, radialResolution: 5, verticalResolution: 3, splitFaces: true)
//            let mesh = try MeshResource.generateTorus(minorRadius: 0.05, majorRadius: 0.2)
//            let mesh = try MeshResource.generateLissajousCurveTorus(minorRadius: 0.008, majorRadius: 0.2, height: 0.3, cycleTimes: 10, majorResolution: 96)
            let mesh = try MeshResource.generateIcosahedron(radius: 0.2, res: 2)
            let model = ModelEntity(mesh:mesh, materials: [m,m])
            model.position.y = 0.2
//            model.orientation = simd_quatf(angle: -.pi/4, axis: SIMD3<Float>(1,0,0))
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

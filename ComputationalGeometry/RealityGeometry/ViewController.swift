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
        
        let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.1,cornerRadius: 0.01),materials: [SimpleMaterial(color: .gray, isMetallic: false)])
        box.position.y = 0.05
        box.name = "box"
        boxAnchor.addChild(box)

        
    }
    @IBAction func segChanged(_ sender: UISegmentedControl) {
        if let box = arView.scene.findEntity(named: "box") as? ModelEntity {
            guard var model = box.model else { return }
            switch sender.selectedSegmentIndex {
            case 0:
                model.materials = [SimpleMaterial(color: .gray, isMetallic: false)]
                box.model = model
            case 1:
                guard let library = MTLCreateSystemDefaultDevice()?.makeDefaultLibrary() else { return }
                let surfaceShader = CustomMaterial.SurfaceShader(named: "normalSurface", in: library)
                let ms = model.materials.map({ base in
                    try! CustomMaterial(from: base, surfaceShader: surfaceShader)
                })
                model.materials = ms
                box.model = model
            case 2:
                guard let library = MTLCreateSystemDefaultDevice()?.makeDefaultLibrary() else { return }
                let surfaceShader = CustomMaterial.SurfaceShader(named: "uvSurface", in: library)
                let ms = model.materials.map({ base in
                    try! CustomMaterial(from: base, surfaceShader: surfaceShader)
                })
                model.materials = ms
                box.model = model// 所有的component都是结构体，即值类型，重新赋值回去才能生效
            default:
                break
            }
        }
        
    }
}

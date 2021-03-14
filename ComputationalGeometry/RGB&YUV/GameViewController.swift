//
//  GameViewController.swift
//  RGB&YUV
//
//  Created by CoderXu on 2021/3/14.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 45
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 1, y: 0.5, z: 4)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        scnView.debugOptions = [.showBoundingBoxes]
        
        
        let box1 = scene.rootNode.childNode(withName: "box", recursively: true)!
        let box2 = scene.rootNode.childNode(withName: "box2", recursively: true)!
        simpleProgram(node: box1)
        simpleProgram(node: box2)
        
        //YUV 到 RGB
        let ycbcrToRGBTransform = float4x4(
            simd_float4(+1.0000, +1.0000, +1.0000, +0.0000),
            simd_float4(+0.0000, -0.3441, +1.7720, +0.0000),
            simd_float4(+1.4020, -0.7141, +0.0000, +0.0000),
            simd_float4(-0.7010, +0.5291, -0.8860, +1.0000)
        );
        let p = ycbcrToRGBTransform.inverse//RGB 到 YUV
        box1.simdTransform = p
        
//        box2.simdTransform = box2.simdTransform * ycbcrToRGBTransform.inverse * box2.simdTransform.inverse
    }
    //用 shader 进行可视化显示
    func simpleProgram(node:SCNNode) {
        let program = SCNProgram()
        program.vertexFunctionName = "vertexShader"
        program.fragmentFunctionName = "fragmentShader"
        
        // 赋值给**SCNGeometry**或者**SCNMaterial**
        guard let material = node.geometry?.materials.first else { fatalError() }
        material.program = program
    }
   
}

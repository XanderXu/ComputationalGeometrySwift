//
//  MeshResource+Cube.swift
//  RealityGeometry
//
//  Created by 许 on 2022/4/2.
//

import RealityKit

extension MeshResource {
    public static func generateExtrudedRoundedRectPad(width: Float, height: Float, depth: Float, radius: Float, angularResolution: Int = 24, edgeXResolution: Int = 2, edgeYResolution: Int = 2, depthResolution: Int = 1, radialResolution: Int = 2, splitFaces: Bool = false, circleUV: Bool = false) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        let halfDepth = depth * 0.5
        
        let datas = generateRoundedRectPlaneDatas(width: width, height: height, radius: radius, angularResolution: angularResolution, edgeXResolution: edgeXResolution, edgeYResolution: edgeYResolution, radialResolution: radialResolution, circleUV: circleUV)
        
        let topMeshPositions = datas.meshPositions.map({ p in
            return p + SIMD3<Float>(0, halfDepth, 0)
        })
        meshPositions.append(contentsOf: topMeshPositions)
        let bottomMeshPositions = datas.meshPositions.map({ p in
            return p + SIMD3<Float>(0, -halfDepth, 0)
        })
        meshPositions.append(contentsOf: bottomMeshPositions)
        
        normals.append(contentsOf: Array(repeating: SIMD3<Float>(0, 1, 0), count: datas.meshPositions.count))
        normals.append(contentsOf: Array(repeating: SIMD3<Float>(0, -1, 0), count: datas.meshPositions.count))
        
        textureMap.append(contentsOf: datas.textureMap)
        textureMap.append(contentsOf: datas.textureMap.map({ uv in
            return uv * SIMD2<Float>(-1, 1) + SIMD2<Float>(1, 0)
        }))
        
        indices.append(contentsOf: datas.indices)
        var reverseIndices: [UInt32] = []
        let bottomTriangleCount = datas.indices.count / 3
        for i in 1...bottomTriangleCount {
            reverseIndices.append(contentsOf: [datas.indices[i*3-1], datas.indices[i*3-2], datas.indices[i*3-3]])
        }
        indices.append(contentsOf: reverseIndices)
        
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 1, count: bottomTriangleCount * 2))
        }
        
        let angular = angularResolution > 2 ? angularResolution : 3
        let angularMinusOne = angular - 1
        let edgeX = edgeXResolution > 1 ? edgeXResolution : 2
        let edgeY = edgeYResolution > 1 ? edgeYResolution : 2
        let edgeDepth = depthResolution > 0 ? depthResolution : 1
        
        let perLoop = (angular - 2) * 4 + (edgeX * 2) + (edgeY * 2) + (circleUV ? 2 : 0)
        let perimeter = width * 2 + height * 2 + .pi * radius * 2
        
        let bottomOutPositions = bottomMeshPositions[(bottomMeshPositions.count - perLoop)...]
        let depthInc = depth / Float(edgeDepth)
        let angularInc = Float(angular) / .pi * 2
        for j in 0...edgeDepth {
            let jf = Float(j)
            let d = jf * depthInc
            let uvy = jf / Float(edgeDepth)
            let curLoop = j * perLoop
            let nextLoop = (j + 1) * perLoop
            
            for i in 0..<perLoop {
                meshPositions.append(bottomOutPositions[i] + SIMD3<Float>(0, d, 0))
                let line1 = edgeY + (circleUV ? 2 : 0)
                var p: Float = 0
                if i < line1 {
                    normals.append(SIMD3<Float>(1, 0, 0))
                    textureMap.append(SIMD2<Float>(width, uvy))
                } else if i < line1 + angularMinusOne {
                    let a = Float(i - line1) * angularInc
                    normals.append(SIMD3<Float>(cos(a), 0, sin(a)))
                    
                } else if i < line1 + angularMinusOne + edgeX {
                    normals.append(SIMD3<Float>(0, 0, 1))
                    
                } else if i < line1 + angularMinusOne * 2 + edgeX {
                    let a = Float(i - line1 - angularMinusOne - edgeX) * angularInc + .pi * 0.5
                    normals.append(SIMD3<Float>(cos(a), 0, sin(a)))
                    
                } else if i < line1 + angularMinusOne * 2 + edgeX + edgeY {
                    normals.append(SIMD3<Float>(-1, 0, 0))
                    
                } else if i < line1 + angularMinusOne * 3 + edgeX + edgeY {
                    let a = Float(i - line1 - angularMinusOne * 2 - edgeX) * angularInc + .pi
                    normals.append(SIMD3<Float>(cos(a), 0, sin(a)))
                    
                } else if i < line1 + angularMinusOne * 3 + edgeX * 2 + edgeY {
                    normals.append(SIMD3<Float>(0, 0, -1))
                    
                } else {
                    let a = Float(i - line1 - angularMinusOne * 3 - edgeX) * angularInc + .pi * 1.5
                    normals.append(SIMD3<Float>(cos(a), 0, sin(a)))
                    
                }
                
                textureMap.append(SIMD2<Float>(0, uvy))
                
                var prev = i - 1
                prev = prev < 0 ? (perLoop - 1) : prev
                let curr = i
                let next = (i + 1) % perLoop
                
                if j != edgeDepth {
                    let i0 = UInt32(curLoop + curr)
                    let i1 = UInt32(curLoop + next)
                    
                    let i2 = UInt32(nextLoop + curr)
                    let i3 = UInt32(nextLoop + next)
                    indices.append(contentsOf: [
                        i0, i2, i3,
                        i0, i3, i1
                    ])
                }
            }
        }
        
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 0, count: edgeDepth * perLoop * 2))
        }
        
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        if !materials.isEmpty {
            descr.materials = MeshDescriptor.Materials.perFace(materials)
        }
        return try .generate(from: [descr])
    }
}

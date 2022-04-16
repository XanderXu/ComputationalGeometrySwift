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
        let edgeX = edgeXResolution > 1 ? edgeXResolution : 2
        let edgeY = edgeYResolution > 1 ? edgeYResolution : 2
        let edgeDepth = depthResolution > 0 ? depthResolution : 1
        
        let widthHalf = width * 0.5
        let heightHalf = height * 0.5
        let minDim = (widthHalf < heightHalf ? widthHalf : heightHalf)
        let radius = radius > minDim ? minDim : radius
        
        let perLoop = (angular - 2) * 4 + (edgeX * 2) + (edgeY * 2) + (circleUV ? 2 : 0)
        let perimeter = width * 2 + height * 2 + .pi * radius * 2
        
        let bottomOutPositions = bottomMeshPositions[(bottomMeshPositions.count - perLoop)...]
        let depthInc = depth / Float(edgeDepth)
        let XInc = (width - 2 * radius) / Float(edgeY)
        let YInc = (height - 2 * radius) / Float(edgeX)
        let arcInc = .pi * radius * 0.5 / Float(angular)
        
        for j in 0...edgeDepth {
            let jf = Float(j)
            let d = jf * depthInc
            let uvy = jf / Float(edgeDepth)
            let curLoop = j * perLoop
            let nextLoop = (j + 1) * perLoop
            
            var length: Float = 0
            for i in 0..<perLoop {
                let p = bottomOutPositions[i]
                meshPositions.append(p + SIMD3<Float>(0, d, 0))
                var inner = p
                if inner.x > widthHalf {
                    inner.x = widthHalf
                }
                if inner.x < -widthHalf {
                    inner.x = -widthHalf
                }
                if inner.z > heightHalf {
                    inner.z = heightHalf
                }
                if inner.z < -heightHalf {
                    inner.z = -heightHalf
                }
                let n = simd_normalize(p - inner)
                normals.append(n)
                
                let line1 = edgeY + (circleUV ? 2 : 0)
                if i <= line1 {
                    length += YInc
                } else if i <= line1 + angular - 2 {
                    length += arcInc
                } else if i < line1 + angular - 2 + edgeX {
                    
                }
                
                
                
                textureMap.append(SIMD2<Float>(length / perimeter, uvy))
                
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

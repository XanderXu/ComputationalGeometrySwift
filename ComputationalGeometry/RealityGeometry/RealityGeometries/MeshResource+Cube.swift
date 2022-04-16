//
//  MeshResource+Cube.swift
//  RealityGeometry
//
//  Created by 许 on 2022/4/2.
//

import RealityKit

extension MeshResource {
    public static func generateExtrudedRoundedRectPad(width: Float, height: Float, depth: Float, radius: Float, angularResolution: Int = 3, edgeXResolution: Int = 2, edgeYResolution: Int = 2, depthResolution: Int = 2, radialResolution: Int = 2, splitFaces: Bool = false, circleUV: Bool = false) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        let halfDepth = depth * 0.5
        
        let datas = generateRoundedRectPlaneDatas(width: width, height: height, radius: radius, angularResolution: angularResolution, edgeXResolution: edgeXResolution, edgeYResolution: edgeYResolution, radialResolution: radialResolution, circleUV: circleUV)
        let planePositionsCount = datas.meshPositions.count
        
        let topMeshPositions = datas.meshPositions.map({ p in
            return p + SIMD3<Float>(0, halfDepth, 0)
        })
        meshPositions.append(contentsOf: topMeshPositions)
        let bottomMeshPositions = datas.meshPositions.map({ p in
            return p + SIMD3<Float>(0, -halfDepth, 0)
        })
        meshPositions.append(contentsOf: bottomMeshPositions)
        
        normals.append(contentsOf: Array(repeating: SIMD3<Float>(0, 1, 0), count: planePositionsCount))
        normals.append(contentsOf: Array(repeating: SIMD3<Float>(0, -1, 0), count: planePositionsCount))
        
        textureMap.append(contentsOf: datas.textureMap)
        textureMap.append(contentsOf: datas.textureMap.map({ uv in
            return uv * SIMD2<Float>(-1, 1) + SIMD2<Float>(1, 0)
        }))
        
        indices.append(contentsOf: datas.indices)
        var reverseIndices: [UInt32] = []
        let bottomTriangleCount = datas.indices.count / 3
        for i in 1...bottomTriangleCount {
            reverseIndices.append(contentsOf: [
                datas.indices[i*3-1] + UInt32(planePositionsCount),
                datas.indices[i*3-2] + UInt32(planePositionsCount),
                datas.indices[i*3-3] + UInt32(planePositionsCount)])
        }
        indices.append(contentsOf: reverseIndices)
        
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 1, count: bottomTriangleCount * 2))
        }
        
        let angular = angularResolution > 2 ? angularResolution : 3
        let edgeX = edgeXResolution > 1 ? edgeXResolution : 2
        let edgeY = edgeYResolution > 1 ? edgeYResolution : 2
        let edgeDepth = depthResolution > 1 ? depthResolution : 2
        
        let widthHalf = width * 0.5
        let heightHalf = height * 0.5
        let minDim = (widthHalf < heightHalf ? widthHalf : heightHalf)
        let radius = radius > minDim ? minDim : radius
        let innerWidth = width - radius * 2
        let innerHeight = height - radius * 2
        
        
        let perLoop = (angular - 2) * 4 + (edgeX * 2) + (edgeY * 2) + 2
        let perimeter = innerWidth * 2 + innerHeight * 2 + .pi * radius * 2
        var bottomOutPositions = Array(bottomMeshPositions[(planePositionsCount - perLoop + (circleUV ? 0 : 2))...])
        if !circleUV {//start and end UVs are different, so add more points
            bottomOutPositions.insert(contentsOf: [SIMD3<Float>(widthHalf, -halfDepth, 0), SIMD3<Float>(widthHalf, -halfDepth, 0)], at: edgeY/2)
        }
        
        let depthInc = depth / Float(edgeDepth-1)
        let angularInc = .pi * radius * 0.5 / Float(angular - 1)
        let innerWidthHalf = widthHalf - radius
        let innerHeightHalf = heightHalf - radius
        
        let index1 = edgeY + 2
        let keyIndexes = [0,
                          index1 - 1,
                          index1 + angular - 2,
                          index1 + angular + edgeX - 3,
                          index1 + angular * 2 + edgeX - 4,
                          index1 + angular * 2 + edgeX + edgeY - 5,
                          index1 + angular * 3 + edgeX + edgeY - 6,
                          index1 + angular * 3 + edgeX * 2 + edgeY - 7
        ]
        let keyLengths = [0,
                          innerHeight,
                          innerHeight + .pi * radius * 0.5,
                          innerHeight + innerWidth + .pi * radius * 0.5,
                          innerHeight + innerWidth + .pi * radius,
                          innerHeight * 2 + innerWidth + .pi * radius,
                          innerHeight * 2 + innerWidth + .pi * radius * 1.5,
                          innerHeight * 2 + innerWidth * 2 + .pi * radius * 1.5,
        ]
        let topBottomPositionsCount = UInt32(planePositionsCount * 2)
        
        for j in 0..<edgeDepth {
            let jf = Float(j)
            let d = jf * depthInc
            let uvy = jf / Float(edgeDepth-1)
            let curLoop = j * perLoop
            let nextLoop = (j + 1) * perLoop
            
            for i in 0..<perLoop {
                let p = bottomOutPositions[i]
                meshPositions.append(p + SIMD3<Float>(0, d, 0))
                
                let inner = p.clamped(lowerBound: SIMD3<Float>(-innerWidthHalf, 0, -innerHeightHalf), upperBound: SIMD3<Float>(innerWidthHalf, 0, innerHeightHalf))
                let n = simd_normalize(p - inner)
                normals.append(n)
                
                var length: Float = -innerHeightHalf
                if i <= keyIndexes[1] {
                    if i <= edgeY/2 {
                        length += perimeter
                    }
                    length += keyLengths[0] + abs(p.z - bottomOutPositions[0].z)
                } else if i <= keyIndexes[2] {
                    length += keyLengths[1] + angularInc * Float(i - keyIndexes[1])
                } else if i <= keyIndexes[3] {
                    length += keyLengths[2] + abs(p.x - bottomOutPositions[2].x)
                } else if i <= keyIndexes[4] {
                    length += keyLengths[3] + angularInc * Float(i - keyIndexes[3])
                } else if i <= keyIndexes[5] {
                    length += keyLengths[4] + abs(p.z - bottomOutPositions[4].z)
                } else if i <= keyIndexes[6] {
                    length += keyLengths[5] + angularInc * Float(i - keyIndexes[5])
                } else if i <= keyIndexes[7] {
                    length += keyLengths[6] + abs(p.x - bottomOutPositions[6].x)
                } else {
                    length += keyLengths[7] + angularInc * Float(i - keyIndexes[7])
                }
                
                textureMap.append(SIMD2<Float>(length / perimeter, uvy))
                
                var prev = i - 1
                prev = prev < 0 ? (perLoop - 1) : prev
                let curr = i
                let next = (i + 1) % perLoop
                
                if j != edgeDepth - 1 {
                    let i0 = UInt32(curLoop + curr) + topBottomPositionsCount
                    let i1 = UInt32(curLoop + next) + topBottomPositionsCount
                    
                    let i2 = UInt32(nextLoop + curr) + topBottomPositionsCount
                    let i3 = UInt32(nextLoop + next) + topBottomPositionsCount
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

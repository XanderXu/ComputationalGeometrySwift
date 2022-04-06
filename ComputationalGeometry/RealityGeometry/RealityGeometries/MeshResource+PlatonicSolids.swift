//
//  MeshResource+PlatonicSolids.swift
//  RealityGeometry
//
//  Created by CoderXu on 2022/4/5.
//

import RealityKit

extension MeshResource {
    public static func generateTetrahedron(radius: Float, res: Int) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        
        
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        if !materials.isEmpty {
            descr.materials = MeshDescriptor.Materials.perFace(materials)
        }
        return try MeshResource.generate(from: [descr])
    }
    public static func generateHexahedron(radius: Float, res: Int) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        
        
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        if !materials.isEmpty {
            descr.materials = MeshDescriptor.Materials.perFace(materials)
        }
        return try MeshResource.generate(from: [descr])
    }
    public static func generateOctahedron(radius: Float, res: Int) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        
        
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        if !materials.isEmpty {
            descr.materials = MeshDescriptor.Materials.perFace(materials)
        }
        return try MeshResource.generate(from: [descr])
    }
    
    public static func generateDogecahedron(radius: Float, res: Int) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        
        
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        if !materials.isEmpty {
            descr.materials = MeshDescriptor.Materials.perFace(materials)
        }
        return try MeshResource.generate(from: [descr])
    }
    
    public static func generateIcosahedron(radius: Float, res: Int) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = Array(repeating: .zero, count: 60)
        var textureMap: [SIMD2<Float>] = []
        
        let phi = (1.0 + sqrtf(5)) * 0.5
        let r2 = radius * radius
        let den = (1.0 + (1.0 / pow(phi, 2.0)))
        let h = sqrt(r2 / (den))
        let w = h / phi

        let points = [
            SIMD3<Float>(0.0, h, w),
            SIMD3<Float>(0.0, h, -w),
            SIMD3<Float>(0.0, -h, w),
            SIMD3<Float>(0.0, -h, -w),

            SIMD3<Float>(h, -w, 0.0),
            SIMD3<Float>(h, w, 0.0),
            SIMD3<Float>(-h, -w, 0.0),
            SIMD3<Float>(-h, w, 0.0),

            SIMD3<Float>(-w, 0.0, -h),
            SIMD3<Float>(w, 0.0, -h),
            SIMD3<Float>(-w, 0.0, h),
            SIMD3<Float>(w, 0.0, h)
        ]
        meshPositions.append(contentsOf: points + points + points + points + points)
        
        let index: [UInt32] = [
            0, 11, 5,
            0, 5, 1,
            0, 1, 7,
            0, 7, 10,
            0, 10, 11,

            1, 5, 9,
            5, 11, 4,
            11, 10, 2,
            10, 7, 6,
            7, 1, 8,

            3, 9, 4,
            3, 4, 2,
            3, 2, 6,
            3, 6, 8,
            3, 8, 9,

            4, 9, 5,
            2, 4, 11,
            6, 2, 10,
            8, 6, 7,
            9, 8, 1
        ]
        var countDict: [UInt32:Int] = [:]
        for ind in index {
            let count = countDict[ind] ?? 0
            indices.append(ind + UInt32(points.count * count))
            countDict[ind] = count + 1
        }
        var triangles = 20
        for i in 0..<triangles {
            let ai = 3 * i
            let bi = 3 * i + 1
            let ci = 3 * i + 2
            
            let i0 = indices[ai]
            let i1 = indices[bi]
            let i2 = indices[ci]
            
            let v0 = meshPositions[Int(i0)]
            let v1 = meshPositions[Int(i1)]
            let v2 = meshPositions[Int(i2)]
            
            let faceNormal = simd_normalize((v0 + v1 + v2) / 3)
            normals[Int(i0)] = faceNormal
            normals[Int(i1)] = faceNormal
            normals[Int(i2)] = faceNormal
        }
        var vertices = meshPositions.count
        
        for _ in 0..<res {
            let newTriangles = triangles * 4
            let newVertices = vertices + triangles * 3
            
            var newIndices: [UInt32] = []
            var pos: SIMD3<Float>
            
            for i in 0..<triangles {
                let ai = 3 * i
                let bi = 3 * i + 1
                let ci = 3 * i + 2
                
                let i0 = indices[ai]
                let i1 = indices[bi]
                let i2 = indices[ci]
                
                let v0 = meshPositions[Int(i0)]
                let v1 = meshPositions[Int(i1)]
                let v2 = meshPositions[Int(i2)]
                
                let faceNormal = normals[Int(i0)]
                normals.append(contentsOf: [faceNormal, faceNormal, faceNormal])
                // a
                pos = (v0 + v1) * 0.5
                meshPositions.append(pos)

                // b
                pos = (v1 + v2) * 0.5
                meshPositions.append(pos)
                
                // c
                pos = (v2 + v0) * 0.5
                meshPositions.append(pos)
                
                
                let a = UInt32(ai + vertices)
                let b = UInt32(bi + vertices)
                let c = UInt32(ci + vertices)
                newIndices.append(contentsOf: [
                    i0, a, c,
                    a, i1, b,
                    a, b, c,
                    c, b, i2
                ])
            }
            
            indices = newIndices
            triangles = newTriangles
            vertices = newVertices
        }
        
        for i in 0..<meshPositions.count {
            let p = meshPositions[i]
            let n = simd_normalize(p)
//            normals.append(n)
            
            textureMap.append(SIMD2<Float>((atan2(n.x, n.z) + .pi) / (2 * .pi), 1 - acos(n.y) / .pi))
        }
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        return try MeshResource.generate(from: [descr])
    }
}

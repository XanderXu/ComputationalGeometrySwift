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
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        let phi = (1.0 + sqrtf(5)) * 0.5
        let r2 = radius * radius
        let den = (1.0 + (1.0 / pow(phi, 2.0)))
        let h = sqrt(r2 / (den))
        let w = h / phi

        var vertices = 12
        var triangles = 20
        
        meshPositions.append(SIMD3<Float>(0.0, h, w))
        meshPositions.append(SIMD3<Float>(0.0, h, -w))
        meshPositions.append(SIMD3<Float>(0.0, -h, w))
        meshPositions.append(SIMD3<Float>(0.0, -h, -w))

        meshPositions.append(SIMD3<Float>(h, -w, 0.0))
        meshPositions.append(SIMD3<Float>(h, w, 0.0))
        meshPositions.append(SIMD3<Float>(-h, -w, 0.0))
        meshPositions.append(SIMD3<Float>(-h, w, 0.0))

        meshPositions.append(SIMD3<Float>(-w, 0.0, -h))
        meshPositions.append(SIMD3<Float>(w, 0.0, -h))
        meshPositions.append(SIMD3<Float>(-w, 0.0, h))
        meshPositions.append(SIMD3<Float>(w, 0.0, h))
        
        indices.append(contentsOf: [0, 11, 5])
        indices.append(contentsOf: [0, 5, 1])
        indices.append(contentsOf: [0, 1, 7])
        indices.append(contentsOf: [0, 7, 10])
        indices.append(contentsOf: [0, 10, 11])

        indices.append(contentsOf: [1, 5, 9])
        indices.append(contentsOf: [5, 11, 4])
        indices.append(contentsOf: [11, 10, 2])
        indices.append(contentsOf: [10, 7, 6])
        indices.append(contentsOf: [7, 1, 8])

        indices.append(contentsOf: [3, 9, 4])
        indices.append(contentsOf: [3, 4, 2])
        indices.append(contentsOf: [3, 2, 6])
        indices.append(contentsOf: [3, 6, 8])
        indices.append(contentsOf: [3, 8, 9])

        indices.append(contentsOf: [4, 9, 5])
        indices.append(contentsOf: [2, 4, 11])
        indices.append(contentsOf: [6, 2, 10])
        indices.append(contentsOf: [8, 6, 7])
        indices.append(contentsOf: [9, 8, 1])
        
        for _ in 0..<res {
            let newTriangles = triangles * 4
            let newVertices = vertices + triangles * 3
            
            var newIndices: [UInt32] = []

            var j = vertices
            var pos: SIMD3<Float>
            
            for i in 0..<triangles {
                let i0 = indices[3 * i]
                let i1 = indices[3 * i + 1]
                let i2 = indices[3 * i + 2]
                
                let v0 = meshPositions[Int(i0)]
                let v1 = meshPositions[Int(i1)]
                let v2 = meshPositions[Int(i2)]
                
                // a
                pos = (v0 + v1) * 0.5
//                pos = simd_normalize(pos) * radius
                meshPositions.append(pos)
                let a = UInt32(j)
                j += 1

                // b
                pos = (v1 + v2) * 0.5
//                pos = simd_normalize(pos) * radius
                meshPositions.append(pos)
                let b = UInt32(j)
                j += 1
                // c
                pos = (v2 + v0) * 0.5
//                pos = simd_normalize(pos) * radius
                meshPositions.append(pos)
                let c = UInt32(j)
                j += 1
                
                newIndices.append(contentsOf: [
                    UInt32(i0), a, c,
                    a, UInt32(i1), b,
                    a, b, c,
                    c, b, UInt32(i2)
                ])
            }
            
            indices = newIndices
            triangles = newTriangles
            vertices = newVertices
        }
        
        for i in 0..<vertices {
            let p = meshPositions[i]
            let n = simd_normalize(p)
            normals.append(n)
            
            textureMap.append(SIMD2<Float>((atan2(n.x, n.z) + .pi) / (2.0 * .pi), 1 - acos(n.y) / .pi))
        }
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        if !materials.isEmpty {
            descr.materials = MeshDescriptor.Materials.perFace(materials)
        }
        return try MeshResource.generate(from: [descr])
    }
}

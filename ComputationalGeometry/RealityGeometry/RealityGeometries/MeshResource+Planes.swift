//
//  MeshResource+Planes.swift
//  
//
//  Created by Max Cobb on 11/06/2021.
//

import RealityKit

extension MeshResource {
    /// Creates a new plane mesh with the specified values. 
    /// - Parameters:
    ///   - width: Width of the output plane
    ///   - depth: Depth of the output plane
    ///   - vertices: Vertex count in the x and z axis
    /// - Returns: A plane mesh
    public static func generateDetailedPlane(
        width: Float, depth: Float, vertices: (Int, Int)
    ) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var textureMap: [SIMD2<Float>] = []
        for x_v in 0..<(vertices.0) {
            let vertexCounts = meshPositions.count
            for y_v in 0..<(vertices.1) {
                meshPositions.append([
                    (Float(x_v) / Float(vertices.0 - 1) - 0.5) * width,
                    0,
                    (0.5 - Float(y_v) / Float(vertices.1 - 1)) * depth
                ])
                textureMap.append([Float(x_v) / Float(vertices.0 - 1), Float(y_v) / Float(vertices.1 - 1)])
                if x_v > 0 && y_v > 0 {
                    indices.append(
                        contentsOf: [
                            vertexCounts - vertices.1, vertexCounts, vertexCounts - vertices.1 + 1,
                            vertexCounts - vertices.1 + 1, vertexCounts, vertexCounts + 1
                        ].map { UInt32($0 + y_v - 1) })
                }
            }
        }
        descr.primitives = .triangles(indices)
        descr.positions = MeshBuffer(meshPositions)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        return try .generate(from: [descr])
    }
    
    public static func generateDetailedPlane(
        width: Float, depth: Float, radius:Float, vertices: (Int, Int), corners:(angularResolution:Int, radialResolution:Int)
    ) throws -> MeshResource {
        if radius == 0 {
            return try generateDetailedPlane(width: width, depth: depth, vertices: vertices)
        }
        
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var textureMap: [SIMD2<Float>] = []
        
        let innerWidth = width - radius*2
        let innerDepth = depth - radius*2
        if innerWidth < 0 || innerDepth < 0 {
            return try .generate(from: [descr])
        }
        let radialResolution = min(1, corners.radialResolution)
        let angularResolution = min(1, corners.angularResolution)
        let angleIncs = .pi/2/Float(angularResolution)
        
        //left
        for x_v in 0..<radialResolution {
            let vertexCounts = meshPositions.count
            //topCorner
            let topCorner = SIMD3<Float>(radius-width/2, 0, radius-depth/2)
            for y_v in 0..<angularResolution {
                let y_v_R = angularResolution - 1 - y_v
                let position = SIMD3<Float>(topCorner.x - cos(Float(y_v_R)*angleIncs)*radius,
                                            0,
                                            topCorner.y - sin(Float(y_v_R)*angleIncs)*radius)
                
                meshPositions.append(position)
                textureMap.append([position.x/width+0.5, position.z/depth+0.5])
                if x_v > 0 && y_v > 0 {
                    indices.append(
                        contentsOf: [
                            vertexCounts - angularResolution, vertexCounts, vertexCounts - angularResolution + 1,
                            vertexCounts - angularResolution + 1, vertexCounts, vertexCounts + 1
                        ].map { UInt32($0 + y_v - 1) })
                }
            }
            //middle
            //bottomCorner
        }
        //middle
        //right
        
        for x_v in 0..<(vertices.0) {
            let vertexCounts = meshPositions.count
            for y_v in 0..<(vertices.1) {
                meshPositions.append([
                    (Float(x_v) / Float(vertices.0 - 1) - 0.5) * width,
                    0,
                    (0.5 - Float(y_v) / Float(vertices.1 - 1)) * depth
                ])
                textureMap.append([Float(x_v) / Float(vertices.0 - 1), Float(y_v) / Float(vertices.1 - 1)])
                if x_v > 0 && y_v > 0 {
                    indices.append(
                        contentsOf: [
                            vertexCounts - vertices.1, vertexCounts, vertexCounts - vertices.1 + 1,
                            vertexCounts - vertices.1 + 1, vertexCounts, vertexCounts + 1
                        ].map { UInt32($0 + y_v - 1) })
                }
            }
        }
        descr.primitives = .triangles(indices)
        descr.positions = MeshBuffer(meshPositions)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        return try .generate(from: [descr])
    }
}

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
        let widthIncs = vertices.0 < 2 ? 0 : innerWidth / Float(vertices.0 - 1)
        let depthIncs = vertices.1 < 2 ? 0 : innerDepth / Float(vertices.1 - 1)
        //left
        let leftCounts = (angularResolution-1)*2 + vertices.1
        for x_v in 0..<radialResolution {
            let vertexCounts = meshPositions.count
            
            let topCorner = SIMD3<Float>(radius-width/2, 0, radius-depth/2)
            let bottomCorner = SIMD3<Float>(radius-width/2, 0, -radius+depth/2)
            let radiusX = radius * (1-Float(x_v)/Float(radialResolution))
            for y_v in 0..<leftCounts {
                var position = SIMD3<Float>()
                if y_v < angularResolution - 1 {//topCorner
                    let y_v_T = angularResolution - 1 - y_v
                    position = SIMD3<Float>(topCorner.x - cos(Float(y_v_T)*angleIncs)*radiusX,
                                            0,
                                            topCorner.y - sin(Float(y_v_T)*angleIncs)*radiusX)
                } else if y_v < vertices.1 + angularResolution - 1 {//middle
                    let y_v_M = y_v - (angularResolution - 1)
                    position = SIMD3<Float>(topCorner.x - radiusX,
                                            0,
                                            topCorner.y + Float(y_v_M)*depthIncs)
                } else {//bottomCorner
                    let y_v_B = y_v - (vertices.1 + angularResolution - 1) + 1
                    position = SIMD3<Float>(bottomCorner.x - cos(Float(y_v_B)*angleIncs)*radiusX,
                                            0,
                                            bottomCorner.y + sin(Float(y_v_B)*angleIncs)*radiusX)
                }
                
                meshPositions.append(position)
                textureMap.append([position.x/width+0.5, position.z/depth+0.5])
                if x_v > 0 && y_v > 0 {
                    indices.append(
                        contentsOf: [
                            vertexCounts - leftCounts, vertexCounts, vertexCounts - leftCounts + 1,
                            vertexCounts - leftCounts + 1, vertexCounts, vertexCounts + 1
                        ].map { UInt32($0 + y_v - 1) })
                }
            }
        }
        //middle
        let middleCounts = (radialResolution-1)*2 + vertices.1
        for x_v in 0..<vertices.0 {
            let vertexCounts = meshPositions.count
            for y_v in 0..<middleCounts {
                var position = SIMD3<Float>()
                if y_v < radialResolution {//top
                    position = SIMD3<Float>(-innerWidth/2 + Float(x_v) * widthIncs,
                                            0,
                                            -innerDepth/2 - radius + Float(y_v) * radius / Float(radialResolution))
                } else if y_v < vertices.1 + radialResolution {//middle
                    let y_v_M = y_v - radialResolution
                    position = SIMD3<Float>(-innerWidth/2 + Float(x_v) * widthIncs,
                                            0,
                                             -innerDepth/2 + Float(y_v_M) * depthIncs)
                } else {//bottom
                    let y_v_B = y_v - (vertices.1 + radialResolution - 1) + 1
                    position = SIMD3<Float>(-innerWidth/2 + Float(x_v) * widthIncs,
                                            0,
                                            innerDepth/2 + Float(y_v_B) * radius / Float(radialResolution))
                }
                
                meshPositions.append(position)
                textureMap.append([position.x/width+0.5, position.z/depth+0.5])
                if x_v == 0 {
                    
                } else if x_v > 0 && y_v > 0 {
                    indices.append(
                        contentsOf: [
                            vertexCounts - middleCounts, vertexCounts, vertexCounts - middleCounts + 1,
                            vertexCounts - middleCounts + 1, vertexCounts, vertexCounts + 1
                        ].map { UInt32($0 + y_v - 1) })
                }
            }
        }
        //right
        
        
        descr.primitives = .triangles(indices)
        descr.positions = MeshBuffer(meshPositions)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        return try .generate(from: [descr])
    }
}

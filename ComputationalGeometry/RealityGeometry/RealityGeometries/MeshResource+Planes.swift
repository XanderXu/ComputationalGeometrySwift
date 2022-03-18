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
    public static func generateCirclePlane(radius:Float,angularResolution:Int, radialResolution:Int,circleUV:Bool = true) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var textureMap: [SIMD2<Float>] = []
        
        let radial = radialResolution > 0 ? radialResolution : 1
        let angular = angularResolution > 2 ? angularResolution : 3;

        let radialf = Float(radial)
        let angularf = Float(angular)
        
        let radialInc = radius / radialf
        let angularInc = (2.0 * Float.pi) / angularf

        let perLoop = angular + 1

        for r in 0...radial {
            let rf = Float(r)
            let rad = rf * radialInc
            let rFactor = rf / radialf
            for a in 0...angular {
                let af = Float(a)
                let angle = af * angularInc
                let ca = cos(angle)
                let sa = sin(angle)

                meshPositions.append(SIMD3<Float>(rad * ca,0,rad * sa))
                if circleUV {
                    textureMap.append(SIMD2<Float>(rFactor, af / angularf))
                } else {
                    textureMap.append(SIMD2<Float>((ca*rFactor)/2+0.5, 0.5-(sa*rFactor)/2))
                }
                
                if (r != radial && a != angular) {
                    let index = UInt32(a + r * perLoop)

                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(perLoop)
                    let br = bl + 1

                    indices.append(contentsOf: [tr,bl,tl,
                                                br,bl,tr])
                }
            }
        }
        
        descr.primitives = .triangles(indices)
        descr.positions = MeshBuffer(meshPositions)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        
        return try .generate(from: [descr])
    }
}

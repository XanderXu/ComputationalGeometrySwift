//
//  MeshResource+Torus.swift
//  
//
//  Created by Max Cobb on 25/10/2021.
//

import RealityKit

extension MeshResource {
    public static func generateTorus(minorRadius: Float, majorRadius: Float, minorResolution :Int = 24, majorResolution: Int = 24) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        
        let slices = minorResolution > 2 ? minorResolution : 3
        let angular = majorResolution > 2 ? majorResolution : 3

        let slicesf = Float(slices)
        let angularf = Float(angular)

        let limit = Float.pi * 2.0
        let sliceInc = limit / slicesf
        let angularInc = limit / angularf

        let perLoop = angular + 1
        
        for s in 0...slices {
            let sf = Float(s)
            let slice = sf * sliceInc
            let cosSlice = cos(slice)
            let sinSlice = sin(slice)
            
            for a in 0...angular {
                let af = Float(a)
                let angle = af * angularInc

                let cosAngle = cos(angle)
                let sinAngle = sin(angle)

                let x = cosSlice * (majorRadius + cosAngle * minorRadius)
                let y = sinSlice * (majorRadius + cosAngle * minorRadius)
                let z = sinAngle * minorRadius

                let tangent = SIMD3<Float>(-sinSlice, cosSlice, 0.0)
                let stangent = SIMD3<Float>(cosSlice * (-sinAngle), sinSlice * (-sinAngle), cosAngle)
                
                meshPositions.append(SIMD3<Float>(x, z, y))
                normals.append(SIMD3<Float>(simd_cross(tangent, stangent)))
                textureMap.append(SIMD2<Float>(af / angularf, sf / slicesf))
                
                if (s != slices && a != angular) {
                    let index = a + s * perLoop

                    let tl = UInt32(index)
                    let tr = tl + 1
                    let bl = UInt32(index + perLoop)
                    let br = bl + 1

                    indices.append(contentsOf: [
                        tl, tr, bl,
                        tr, br, bl
                    ])
                }
            }
        }
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        
        return try MeshResource.generate(from: [descr])
    }
}

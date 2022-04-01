//
//  MeshResource+MetaLogo.swift
//  RealityGeometry
//
//  Created by 许 on 2022/3/31.
//

import RealityKit

extension MeshResource {
    public static func generateMetaLogo(minorRadius: Float, majorRadius: Float, height: Float, minorResolution :Int = 24, majorResolution: Int = 24) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        
        let slices = majorResolution > 2 ? majorResolution : 4
        let angular = minorResolution > 2 ? minorResolution : 3

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
            
            let centerX = cosSlice * majorRadius
            let centerY = sin(2 * slice) * height * 0.5
            let centerZ = sinSlice * majorRadius
            let center = SIMD3<Float>(centerX, centerY, centerZ)
            
            let tangent = simd_normalize(SIMD3<Float>(-sinSlice, height * cos(2 * slice) / majorRadius, cosSlice))
            let vectorN = SIMD3<Float>(cosSlice, 0, sinSlice)
            for a in 0...angular {
                let af = Float(a)
                let angle = af * angularInc
                
                let normal = simd_act(simd_quatf(angle: angle, axis: tangent), vectorN)

                meshPositions.append(center + normal * minorRadius)
                normals.append(normal)
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

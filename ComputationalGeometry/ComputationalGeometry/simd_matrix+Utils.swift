//
//  simd_matrix+Utils.swift
//  ComputationalGeometry
//
//  Created by CoderXu on 2021/2/25.
//

import Foundation
import simd
extension simd_float3x3 {
    ///矩阵正交化
    func orthogonalization(iterationTimes:Int = 10) -> simd_float3x3 {
        var r1 = columns.0
        var r2 = columns.1
        var r3 = columns.2
        
        let k:Float = 0.3
        
        for _ in 0..<iterationTimes {
            r1 = r1 - k * (orth(u: r1, v: r2) + orth(u: r1, v: r3))
            r2 = r2 - k * (orth(u: r2, v: r1) + orth(u: r2, v: r3))
            r3 = r3 - k * (orth(u: r3, v: r1) + orth(u: r3, v: r2))
        }
        
        r2 = r2 - orth(u: r2, v: r1)
        r3 = r3 - orth(u: r3, v: r1) - orth(u: r3, v: r2)
        
        r1 = normalize(r1)
        r2 = normalize(r2)
        r3 = normalize(r3)
        
        return simd_float3x3(r1, r2, r3)
    }
    
    private func orth(u:simd_float3, v:simd_float3) -> simd_float3 {
        return dot(u, v) / dot(v, v) * v
    }
}
extension simd_float4x4 {
    static var identity: simd_float4x4 {
        get {
            return matrix_identity_float4x4
        }
    }
    var matrix3x3: simd_float3x3 {
        get {
            let m3x3 = simd_float3x3([
                columns.0.firstFloat3(),
                columns.1.firstFloat3(),
                columns.2.firstFloat3()
            ])
            return m3x3
        }
    }
    var determinant3x3: Float {
        get {
            return matrix3x3.determinant
        }
    }
    init(translation: SIMD3<Float>) {
        self.init()
        columns.0 = simd_float4(1, 0, 0, 0)
        columns.1 = simd_float4(0, 1, 0, 0)
        columns.2 = simd_float4(0, 0, 1, 0)
        columns.3 = simd_float4(translation, 1)
    }
    init(translation: SIMD4<Float>) {
        self.init()
        columns.0 = simd_float4(1, 0, 0, 0)
        columns.1 = simd_float4(0, 1, 0, 0)
        columns.2 = simd_float4(0, 0, 1, 0)
        columns.3 = translation / translation.w
    }
    ///正交化
    func orthogonalization(iterationTimes:Int = 10) -> simd_float4x4 {
        let r1 = simd_float3(self.columns.0.x, self.columns.0.y, self.columns.0.z)
        let r2 = simd_float3(self.columns.1.x, self.columns.1.y, self.columns.1.z)
        let r3 = simd_float3(self.columns.2.x, self.columns.2.y, self.columns.2.z)
        
        let m3 = simd_float3x3(r1, r2, r3).orthogonalization(iterationTimes: iterationTimes)
        
        let result = simd_float4x4([
            simd_float4(m3.columns.0, 0),
            simd_float4(m3.columns.1, 0),
            simd_float4(m3.columns.2, 0),
            self.columns.3
        ])
        return result
    }
    ///多个矩阵的平均矩阵
    static func averageMatrix(_ matrices:[simd_float4x4], needScale:Bool = false) -> simd_float4x4 {
        var averagePosition = simd_float4.zero
        var averageScale:Float = 0
        var averageRotation = simd_quatf()
        
        for matrix in matrices {
            averagePosition += matrix.columns.3
            if needScale {
                let d = matrix.determinant
                averageScale += cbrtf(d)
            }
            averageRotation += simd_quatf(matrix)
        }
        
        let count = Float(matrices.count)
        averagePosition /= count
        averageRotation = averageRotation.normalized
        if needScale {
            averageScale /= count
            let s = simd_float4x4(diagonal: simd_float4(averageScale, averageScale, averageScale, 1))
            let r = simd_float4x4(averageRotation)
            let t = simd_float4x4(translation: averagePosition)
            //复合变换约定顺序:缩放 —> 旋转 —> 平移
            return t * r * s
        } else {
            let r = simd_float4x4(averageRotation)
            let t = simd_float4x4(translation: averagePosition)
            //复合变换约定顺序:缩放 —> 旋转 —> 平移
            return t * r
        }
    }
}

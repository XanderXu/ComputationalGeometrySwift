//
//  Triangle.swift
//  ComputationalGeometry
//
//  Created by CoderXu on 2020/12/15.
//

import Foundation
import simd
//定义三角形
struct Triangle {
    let point1:simd_float3
    let point2:simd_float3
    let point3:simd_float3
    
    static func isObtuse(triangle:Triangle) -> Bool {
        return true
    }
}

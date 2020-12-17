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
    ///是否钝角
    static func isObtuse(triangle:Triangle) -> Bool {
        let vector1 = triangle.point2 - triangle.point1
        let vector2 = triangle.point3 - triangle.point2
        let vector3 = triangle.point1 - triangle.point3
        
        let dot1 = dot(vector1, vector2)
        let dot2 = dot(vector2, vector3)
        let dot3 = dot(vector3, vector1)
        
        return dot1 > 0 || dot2 > 0 || dot3 > 0
    }
    ///面积
    static func area(triangle:Triangle) -> Float {
        let vector1 = triangle.point2 - triangle.point1
        let vector2 = triangle.point3 - triangle.point2
        let crossValue = cross(vector1, vector2)
        
        return length(crossValue) / 2
    }
    ///重心、几何中心
    static func barycenter(triangle:Triangle) -> simd_float3 {
        return (triangle.point1 + triangle.point2 + triangle.point3)/3
    }
}

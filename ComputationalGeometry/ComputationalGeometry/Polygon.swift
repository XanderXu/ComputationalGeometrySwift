//
//  Polygon.swift
//  ComputationalGeometry
//
//  Created by CoderXu on 2020/12/15.
//

import Foundation
import simd
//定义多边形
struct Polygon {
    let points:[simd_float3]
    var count: Int {
        get{
            return points.count
        }
    }
    ///是否是多边形：多于 3 个点，且共面
    static func isPolygon(points:[simd_float3]) -> Bool {
        if points.count < 3 {
            return false
        }
        let d1 = points[0] - points[points.count - 1]
        let d2 = points[1] - points[0]
        let n = cross(d1, d2)
        
        var lastPoint = points[1]
        
        for i in 2..<points.count {
            let point = points[i]
            let vector = point - lastPoint
            if abs(dot(vector, n)) > Float.leastNormalMagnitude   {
                return false
            }
            lastPoint = point
        }
        return true
    }
    ///是否是凸多边形
    static func isConvex(polygon:Polygon) -> Bool {
        if !isPolygon(points: polygon.points) {
            return false
        }
        var preview = polygon.points[polygon.count-2]
        var middle = polygon.points.last!
        
        var vector1 = middle - preview
        var lastCrossValue = simd_float3.zero
        
        for point in polygon.points {
            let vector2 = point - middle
            let crossValue = cross(vector1, vector2)
            
            let sameDirection = dot(lastCrossValue, crossValue)
            
            if sameDirection < 0 {
                return false
            }
            preview = middle
            middle = point
            vector1 = vector2
            if !crossValue.tooLittleToBeNormalized() {
                lastCrossValue = crossValue
            }
        }
        return true
    }
    ///几何中心：各顶点平均值
    static func geometryCenter(polygon:Polygon) -> simd_float3 {
        var center = simd_float3.zero
        
        for point in polygon.points {
            center += point / Float(polygon.count)
        }
        return center
    }
}

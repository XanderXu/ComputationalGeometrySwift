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
    static func isPolygon(points:[simd_float3]) -> Bool {
        return points.count > 3
    }
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
    
    static func geometryCenter(polygon:Polygon) -> simd_float3 {
        var center = simd_float3.zero
        
        for point in polygon.points {
            center += point / Float(polygon.count)
        }
        return center
    }
}

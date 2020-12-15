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
    
    static func isPolygon(points:[simd_float3]) -> Bool {
        return points.count > 2
    }
    static func isConvex(polygon:Polygon) -> Bool {
        return true
    }
    
}

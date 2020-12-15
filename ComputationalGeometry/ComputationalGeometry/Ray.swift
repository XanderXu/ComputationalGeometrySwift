//
//  Ray.swift
//  ComputationalGeometry
//
//  Created by CoderXu on 2020/12/15.
//

import Foundation
import simd
//定义射线
struct Ray {
    let position:simd_float3
    let direction:simd_float3
    
    static func nearestPointOnLine(from point:simd_float3, to line:Line) -> simd_float3 {
        let vector = point - line.position
        let normalizedDirection = normalize(line.direction)
        let dotValue = dot(vector, normalizedDirection)
        if dotValue <= 0 {
            return line.position
        }
        let tarPoint = line.position + dotValue * normalizedDirection
        return tarPoint
    }
    
    static func distanceBetween(point:simd_float3, line:Line) -> Float{
        let position = nearestPointOnLine(from: point, to: line)
        return distance(position, point)
    }
    static func distanceSquaredBetween(point:simd_float3, line:Line) -> Float {
        let position = nearestPointOnLine(from: point, to: line)
        return distance_squared(position, point)
    }
}

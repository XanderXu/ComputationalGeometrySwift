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
    
    static func nearestPointOnRay(from point:simd_float3, to ray:Ray) -> simd_float3 {
        let vector = point - ray.position
        let normalizedDirection = normalize(ray.direction)
        let dotValue = dot(vector, normalizedDirection)
        if dotValue <= 0 {
            return ray.position
        }
        let tarPoint = ray.position + dotValue * normalizedDirection
        return tarPoint
    }
    
    static func distanceBetween(point:simd_float3, ray:Ray) -> Float{
        let position = nearestPointOnRay(from: point, to: ray)
        return distance(position, point)
    }
    static func distanceSquaredBetween(point:simd_float3, ray:Ray) -> Float {
        let position = nearestPointOnRay(from: point, to: ray)
        return distance_squared(position, point)
    }
}

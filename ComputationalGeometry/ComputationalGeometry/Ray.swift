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
    ///点到射线的最近点坐标
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
    ///点到射线的距离
    static func distanceBetween(point:simd_float3, ray:Ray) -> Float{
        let position = nearestPointOnRay(from: point, to: ray)
        return distance(position, point)
    }
    ///点到射线距离的平方
    static func distanceSquaredBetween(point:simd_float3, ray:Ray) -> Float {
        let position = nearestPointOnRay(from: point, to: ray)
        return distance_squared(position, point)
    }
    ///射线与射线最近点坐标
    static func nearestPoints(ray1:Ray, ray2:Ray) -> (simd_float3, simd_float3)? {
        let nearestPointOnRay1 = nearestPointOnRay(from: ray2.position, to: ray1)
        let nearestPointToRay2Vector = ray2.position - nearestPointOnRay1
        
        if dot(nearestPointToRay2Vector, ray2.direction) >= 0 {
            // ray2 远离 ray1
            return (nearestPointOnRay1, ray2.position)
        }
        
        let ray1ToRay2 = ray2.position - ray1.position
        let crossValueRay1 = cross(ray1.direction, ray1ToRay2)
        let faceFar = cross(crossValueRay1, ray1ToRay2)
        
        if dot(faceFar, ray2.direction) >= 0 {
            // ray2 指向了 ray1 原点的负方向
            let nearestPointOnRay2 = nearestPointOnRay(from: ray1.position, to: ray2)
            return (ray1.position, nearestPointOnRay2)
        }
        
        // 可按直线最近点处理
        let parallelResult = ray2.direction.almostParallelRelative(to: ray1.direction)
        let crossValue = parallelResult.crossValue
        if parallelResult.isParallel {
            // 平行
            return nil
        }
        let distanceVector = normalize(crossValue)
        
        let vector = ray1.position - ray2.position
        let dis = dot(distanceVector, vector)
        
        let point2OnPlane = ray2.position + dis * distanceVector
        
        let projectionOnLine1 = nearestPointOnRay(from: point2OnPlane, to: ray1)
        let result = projectionOnLine1.almostSamePoint(to: point2OnPlane)
        if result.isSame {
            // 垂足是 line2.position
            return (point2OnPlane,ray2.position)
        }
        let projectionVector = projectionOnLine1 - point2OnPlane
        let squared = result.distanceSquared
        
        let x1:Float = squared / dot(ray2.direction, projectionVector)
        let footPoint2 = point2OnPlane + x1 * ray2.direction
        let footPoint1 = footPoint2 - dis * distanceVector
        
        return (footPoint1, footPoint2)
    }
}

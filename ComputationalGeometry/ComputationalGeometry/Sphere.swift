//
//  Sphere.swift
//  ComputationalGeometry
//
//  Created by CoderXu on 2020/12/4.
//

import Foundation
import simd
//定义球体
struct Sphere {
    let position:simd_float3
    let radius:Float
    ///点到球面的距离，负值代表点在球体内部
    static func distanceBetween(point:simd_float3, sphere:Sphere) -> Float {
        let distanceCenter = distance(point, sphere.position)
        return distanceCenter - sphere.radius
    }
    ///点到球面的投影点坐标，点在球心时为 nil
    static func projectionOnSphere(from point:simd_float3, to sphere:Sphere) -> simd_float3? {
        let vector = point - sphere.position
        let length = simd_length(vector)
        if length < Float.leastNormalMagnitude {
            // 点与球心重合，未定义
            return nil
        }
        let factor = sphere.radius / length
        let target = sphere.position + factor * vector
        
        return target
    }
    ///点是否在球体内部
    static func isPointInsideSphere(point:simd_float3, sphere:Sphere) -> Bool {
        return distance_squared(sphere.position, point) < sphere.radius * sphere.radius
    }
    ///点是否在球面上（误差范围内）
    static func isPointOnSphere(point:simd_float3, sphere:Sphere) -> Bool {
        return abs(distance_squared(sphere.position, point) - sphere.radius * sphere.radius) < Float.toleranceThreshold * Float.toleranceThreshold
    }
    ///直线与球体是否相交
    static func isIntersection(line:Line, sphere:Sphere) -> Bool {
        let vector = line.position - sphere.position
        let a = length_squared(line.direction)
        let b = dot(line.direction, vector)
        let c = length_squared(vector) - sphere.radius * sphere.radius
        
        let discriminant = b * b - 4 * a * c
        return discriminant >= 0
    }
    ///直线与球体的交点坐标
    static func intersectionPoint(line:Line, sphere:Sphere) -> (simd_float3, simd_float3)? {
        let vector = line.position - sphere.position
        let a = length_squared(line.direction)
        let b = dot(line.direction, vector)
        let c = length_squared(vector) - sphere.radius * sphere.radius
        
        let discriminant = b * b - 4 * a * c
        if discriminant < 0 {
            return nil
        }
        let x = sqrtf(discriminant)
        let t1 = (-b + x)/(2*a)
        let t2 = (-b - x)/(2*a)
        
        let point1 = line.position + t1 * line.direction
        let point2 = line.position + t2 * line.direction
        return (point1, point2)
    }
    ///直线与球体是否相交
    static func isIntersection2(line:Line, sphere:Sphere) -> Bool {
        let distanceSquared = Line.distanceSquaredBetween(point: sphere.position, line: line)
        return distanceSquared <= sphere.radius * sphere.radius
    }
    ///直线与球体的交点坐标
    static func intersectionPoint2(line:Line, sphere:Sphere) -> (simd_float3, simd_float3)? {
        let vector = sphere.position - line.position
        let normalizedDirection = normalize(line.direction)
        let dotValue = dot(vector, normalizedDirection)
        let nearPoint = line.position + dotValue * normalizedDirection
        
        let distanceSquared = distance_squared(nearPoint, sphere.position)
        let radiusSquared = sphere.radius * sphere.radius
        
        if distanceSquared > radiusSquared {
            return nil
        }
        let x = sqrtf(radiusSquared - distanceSquared)
        let point1 = nearPoint + x * normalizedDirection
        let point2 = nearPoint - x * normalizedDirection
        return (point1, point2)
    }
    ///球体是否有重合、相交
    static func isVolumeIntersection(sphere1:Sphere, sphere2:Sphere) -> Bool {
        let radiusFar = sphere1.radius + sphere2.radius
        
        return distance_squared(sphere1.position, sphere2.position) <= radiusFar * radiusFar
    }
    ///球体表面是否相交
    static func isSurfaceIntersection(sphere1:Sphere, sphere2:Sphere) -> Bool {
        let radiusFar = sphere1.radius + sphere2.radius
        let radiusNear = sphere1.radius - sphere2.radius//正负无所谓，后面只需要平方值
        
        let distanceSquared = distance_squared(sphere1.position, sphere2.position)
        return (distanceSquared <= radiusFar * radiusFar) && (distanceSquared >= radiusNear * radiusNear)
    }
    ///球体是否完全互相包含
    static func isContain(sphere1:Sphere, sphere2:Sphere) -> Bool {
        let radiusNear = sphere1.radius - sphere2.radius//正负无所谓，后面只需要平方值
        let distanceSquared = distance_squared(sphere1.position, sphere2.position)
        return distanceSquared <= radiusNear * radiusNear
    }
    ///球体与球体是否重合（误差范围内）
    static func isSame(sphere1:Sphere, sphere2:Sphere) -> Bool {
        if sphere1.position.isAlmostSamePoint(to: sphere2.position) && abs(sphere1.radius - sphere2.radius) <= Float.leastNormalMagnitude {
            return true
        }
        
        return false
    }
    ///球体与球体相交形成的圆环
    static func intersectionCircle(sphere1:Sphere, sphere2:Sphere) -> (simd_float3, Float)? {
        if !isSurfaceIntersection(sphere1: sphere1, sphere2: sphere2) {
            return nil
        }
        let x = 0.5 * (sphere1.radius * sphere1.radius - sphere2.radius * sphere2.radius) / distance_squared(sphere1.position, sphere2.position) + 0.5
        
        let vector = x * (sphere2.position - sphere1.position)
        let position = sphere1.position + vector
        
        let radius = sqrtf(sphere1.radius * sphere1.radius - length_squared(vector))
        return (position, radius)
    }
}

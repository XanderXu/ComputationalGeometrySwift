//
//  Sphere.swift
//  ComputationalGeometry
//
//  Created by 许海峰 on 2020/12/4.
//

import Foundation
import simd
//定义球体
struct Sphere {
    var position = simd_float3.zero
    var radius = Float.zero
    static func distanceBetween(point:simd_float3, sphere:Sphere) -> Float {
        let distanceCenter = distance(point, sphere.position)
        return distanceCenter - sphere.radius
    }
    
    static func projectionOnSphere(from point:simd_float3, to sphere:Sphere) -> simd_float3 {
        let vector = point - sphere.position
        let length = simd_length(vector)
        let factor = sphere.radius / length
        let target = sphere.position + factor * vector
        
        return target
    }
    
    static func isPointOnSphere(point:simd_float3, sphere:Sphere) -> Bool {
        return abs(distance_squared(sphere.position, point) - sphere.radius * sphere.radius) < Float.toleranceThresholdLittle
    }
    static func isIntersection(line:Line, sphere:Sphere) -> Bool {
        let vector = line.position - sphere.position
        let a = length_squared(line.direction)
        let b = dot(line.direction, vector)
        let c = length_squared(vector) - sphere.radius * sphere.radius
        
        let discriminant = b * b - 4 * a * c
        return discriminant >= 0
    }
    static func intersectionPoint(line:Line, sphere:Sphere) -> (simd_float3, simd_float3)? {
        let vector = line.position - sphere.position
        let a = length_squared(line.direction)
        let b = dot(line.direction, vector)
        let c = length_squared(vector) - sphere.radius * sphere.radius
        
        let discriminant = b * b - 4 * a * c
        if discriminant < 0 {
            return nil
        }
        let t1 = (-b + sqrtf(discriminant))/(2*a)
        let t2 = (-b - sqrtf(discriminant))/(2*a)
        
        let point1 = line.position + t1 * line.direction
        let point2 = line.position + t2 * line.direction
        return (point1, point2)
    }
    static func isIntersection(sphere1:Sphere, sphere2:Sphere) -> Bool {
        let radius = sphere1.radius + sphere2.radius
        
        return distance_squared(sphere1.position, sphere2.position) <= radius * radius
    }
    
    static func isSame(sphere1:Sphere, sphere2:Sphere) -> Bool {
        if distance_squared(sphere1.position, sphere2.position) < Float.toleranceThresholdLittle && abs(sphere1.radius - sphere2.radius) <= Float.leastNormalMagnitude {
            return true
        }
        
        return false
    }
}

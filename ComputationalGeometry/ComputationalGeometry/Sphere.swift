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
    
    static func isPointInsideSphere(point:simd_float3, sphere:Sphere) -> Bool {
        return distance_squared(sphere.position, point) < sphere.radius * sphere.radius
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
        let x = sqrtf(discriminant)
        let t1 = (-b + x)/(2*a)
        let t2 = (-b - x)/(2*a)
        
        let point1 = line.position + t1 * line.direction
        let point2 = line.position + t2 * line.direction
        return (point1, point2)
    }
    
    static func isIntersection2(line:Line, sphere:Sphere) -> Bool {
        let distanceSquared = Line.distanceSquaredBetween(point: sphere.position, line: line)
        return distanceSquared <= sphere.radius * sphere.radius
    }
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
    static func isVolumeIntersection(sphere1:Sphere, sphere2:Sphere) -> Bool {
        let radiusFar = sphere1.radius + sphere2.radius
        
        return distance_squared(sphere1.position, sphere2.position) <= radiusFar * radiusFar
    }
    static func isSurfaceIntersection(sphere1:Sphere, sphere2:Sphere) -> Bool {
        let radiusFar = sphere1.radius + sphere2.radius
        let radiusNear = sphere1.radius - sphere2.radius//正负无所谓，后面只需要平方值
        
        let distanceSquared = distance_squared(sphere1.position, sphere2.position)
        return (distanceSquared <= radiusFar * radiusFar) && (distanceSquared >= radiusNear * radiusNear)
    }
    static func isContain(sphere1:Sphere, sphere2:Sphere) -> Bool {
        let radiusNear = sphere1.radius - sphere2.radius//正负无所谓，后面只需要平方值
        let distanceSquared = distance_squared(sphere1.position, sphere2.position)
        return distanceSquared <= radiusNear * radiusNear
    }
    static func isSame(sphere1:Sphere, sphere2:Sphere) -> Bool {
        if distance_squared(sphere1.position, sphere2.position) < Float.toleranceThresholdLittle && abs(sphere1.radius - sphere2.radius) <= Float.leastNormalMagnitude {
            return true
        }
        
        return false
    }
    
    static func intersectionCircle(sphere1:Sphere, sphere2:Sphere) -> (simd_float3, Float)? {
        if !isSurfaceIntersection(sphere1: sphere1, sphere2: sphere2) {
            return nil
        }
        let x = 0.5 * ((sphere1.radius * sphere1.radius - sphere2.radius * sphere2.radius) / distance_squared(sphere1.position, sphere2.position) + 1)
        
        let vector = x * (sphere2.position - sphere1.position)
        let position = sphere1.position + vector
        
        let radius = sqrtf(sphere1.radius * sphere1.radius - length_squared(vector))
        return (position, radius)
    }
    static func estimateSphereSVD(from points:[simd_float3]) -> Sphere? {
        if points.count < 3 {
            return nil
        }
        var source:[Float] = Array(repeating: 0, count: points.count*3)
        var position = simd_float3.zero
        for point in points {
            position += (point / Float(points.count))
        }
        for (row,point) in points.enumerated() {
            source[row] = point.x - position.x
            source[row+points.count] = point.y - position.y
            source[row+2*points.count] = point.z - position.z
        }
        // source 中数据顺序为[x0,x1,x2.....y0,y1,y2.....z0,z1,z3....]，竖向按列依次填充到 rowCount行*3列 的矩阵中
        let ss = Matrix(source: source, rowCount: points.count, columnCount:3)
        let svdResult = Matrix.svd(a: ss)
        let radius = svdResult.sigma[0]
        let sphere = Sphere(position: position, radius: radius)
        return sphere
    }
}

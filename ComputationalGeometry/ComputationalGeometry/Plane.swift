//
//  Plane.swift
//  Distance
//
//  Created by CoderXu on 2020/11/11.
//

import Foundation
import simd
//定义平面
struct Plane {
    var position = simd_float3.zero
    var normal = simd_float3.zero
    
    static func distanceBetween(point:simd_float3, plane:Plane) -> Float {
        let vector = point - plane.position
        let dotValue = dot(vector, normalize(plane.normal))
        return dotValue
    }
    
    static func projectionOnPlane(from point:simd_float3, to plane:Plane) -> simd_float3 {
        let vector = point - plane.position
        let normalizedNormal = normalize(plane.normal)
        
        let dotValue = dot(vector, normalizedNormal)
        let tarPoint = point - dotValue * normalizedNormal
        return tarPoint
    }
    static func isPointOnPlane(point:simd_float3, plane:Plane) -> Bool {
        let vector = point - plane.position
        let dotValue = dot(vector, plane.normal)
        return dotValue < Float.toleranceThresholdLittle
    }
    // 返回值为：投影点坐标，距离，是否在平面上
    static func matrixRelationship(point:simd_float3, plane:Plane) -> (simd_float3, Float, Bool) {
        let vector = point - plane.position
        let yAxisVector = cross(plane.normal, vector)
        
        if yAxisVector.tooLittleToBeNormalized() {
            // 点在平面上的投影点，距离平面原点太近，即 vector 与 plane.normal 几乎共线。
            let distance2 = distance(point, plane.position)
            
            return (plane.position, distance2, distance2 < Float.toleranceThresholdLittle)
        }
        let xAxisVector = cross(yAxisVector, plane.normal)
        if xAxisVector.tooLittleToBeNormalized() {
            // 点与平面原点距离过近
            return (plane.position, 0, true)
        }
        let xAxis = simd_float4(normalize(xAxisVector), 0)
        let yAxis = simd_float4(normalize(yAxisVector), 0)
        let zAxis = simd_float4(normalize(plane.normal), 0)
        let origin = simd_float4(plane.position, 1)
        
        let matrix = matrix_float4x4(
            xAxis,
            yAxis,
            zAxis,
            origin
        )
        
        let pointP = simd_float4(point, 1)
        let localP = matrix.inverse * pointP
        // 将 z 坐标置 0，得到投影点，再补 1，构成齐次坐标，方便与矩阵相乘
        let localProject = simd_float4(localP.x, localP.y, 0, 1)
        let projectP = matrix * localProject
        let projectP2 = simd_float3(projectP.x, projectP.y, projectP.z)
        
        let localDistance = localP.z
        
        return (projectP2, localDistance, localDistance < Float.toleranceThresholdLittle)
    }
    static func pointToPlaneTest() {
        let plane = Plane(position: simd_float3(1, 3, 1), normal: simd_float3(0, 0, 3))
        let pointC = simd_float3(50000, 50, 2)
        
        let distance = distanceBetween(point: pointC, plane:plane)
        let tarPoint = projectionOnPlane(from: pointC, to: plane)
        
        print("距离\(distance), 投影点\(tarPoint)")
        print(matrixRelationship(point: pointC, plane: plane))
        
        print(isPointOnPlane(point: pointC, plane:plane))
        if (abs(distance) < Float.leastNormalMagnitude) {
            print("点在平面上")
        } else {
            print("点不在平面上")
        }
    }
    static func isParallel(plane1:Plane, plane2:Plane) -> Bool {
        let crossValue = cross(plane1.normal, plane2.normal)
        if crossValue.tooLittleToBeNormalized() {
            return true
        }
        return false
    }
    static func isSame(plane1:Plane, plane2:Plane) -> Bool {
        if !isParallel(plane1:plane1, plane2:plane2) {
            return false
        }
        return isPointOnPlane(point: plane1.position, plane: plane2)
    }
    static func isParallel(line:Line, plane:Plane) -> Bool {
        let dotValue = dot(line.direction, plane.normal)
        if dotValue < Float.leastNormalMagnitude {
            return true
        }
        return false
    }
    static func crossPoint(line:Line, plane:Plane) -> simd_float3? {
        let dotValue = dot(line.direction, -normalize(plane.normal))
        if dotValue < Float.leastNormalMagnitude {
            return nil
        }
        return line.position + dotValue * line.direction
    }
    static func crossLine(plane1:Plane, plane2:Plane) -> Line? {
        let crossValue = cross(plane1.normal, plane2.normal)
        if crossValue.tooLittleToBeNormalized() {
            // 平行
            return nil
        }
        // Goldman(1990), 法线无需归一化
        let p0 = simd_float3.zero, n0 = crossValue
        let p1 = plane1.position, n1 = plane1.normal
        let p2 = plane2.position, n2 = plane2.normal
        
        let cross20 = cross(n2, n0), cross01 = cross(n0, n1), cross12 = crossValue
        let dot0 = dot(p0, n0), dot1 = dot(p1, n1), dot2 = dot(p2, n2)
        let dotCross012 = dot0 * cross12, dotCross120 = dot1 * cross20, dotCross210 = dot2 * cross01
        
        let position = (dotCross012 + dotCross120 + dotCross210) / dot(n0, cross12)
        
        return Line(position: position, direction: n0)
    }
    static func estimatePlane(from points:[simd_float3]) -> Plane? {
        if points.count < 3 {
            return nil
        }
        var normal = simd_float3.zero
        var position = simd_float3.zero
        var second = points.last!
        for vector in points {
            normal.x += (second.z + vector.z) * (second.y - vector.y)
            normal.y += (second.x + vector.x) * (second.z - vector.z)
            normal.z += (second.y + vector.y) * (second.x - vector.x)
            second = vector
            
            position += (vector / Float(points.count))
        }
        if normal.tooLittleToBeNormalized() {
            return nil
        }
        normal = normalize(normal)
        return Plane(position: position, normal: normal)
    }
    static func estimatePlaneSVD(from points:[simd_float3]) -> Plane? {
        if points.count < 3 {
            return nil
        }
        var source = [Float]()
        var position = simd_float3.zero
        for point in points {
            position += (point / Float(points.count))
        }
        for point in points {
            source.append(point.x - position.x)
            source.append(point.y - position.y)
            source.append(point.z - position.z)
        }
        
        let ss = Matrix(source: source, rowCount: points.count, columnCount:3)
        let svdResult = Matrix.svd(a: ss)
        let vt = svdResult.vt
        let offset = vt.columnCount * (vt.rowCount - 1)
        
        let normal = simd_float3(vt[0+offset], vt[1+offset], vt[2+offset])
        return Plane(position: position, normal: normal)
    }
    static func pointToPlaneTest2() {
//        let points = [
//            simd_float3(2, 1, 0),
//            simd_float3(2, -1, 0),
//            simd_float3(0, 1, 0),
//            simd_float3(0, -1, 0),
//        ]
//        let points = [
//            simd_float3.zero,
//            simd_float3(1, 0, 0),
//            simd_float3(3, -10, 0.1),
//            simd_float3(-30, 10, 0.1),
//            simd_float3(40, -50, -0.9),
//        ]
        let points = [
            simd_float3(1, 10, 0),
            simd_float3(3, 10, -10),
            simd_float3(-30, 10, 10),
            simd_float3(40, 10, -50),
        ]
        let plane = estimatePlane(from: points)
        //(-0.038009703, -0.10452669, -0.9937954)
        print(plane as Any)
        
//        let plane1 = Plane(position: simd_float3(1, 2, 1), normal: simd_float3(2, 1, 3))
//        let plane2 = Plane(position: simd_float3(1, 3, 1), normal: simd_float3(3, 3, 1))
//
//        let line = crossLine(plane1: plane1, plane2: plane2)
//        print(line as Any)
        let plane2 = estimatePlaneSVD(from: points)
        print(plane2 as Any)
        
    }
}


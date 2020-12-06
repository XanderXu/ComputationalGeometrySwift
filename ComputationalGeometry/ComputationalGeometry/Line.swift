//
//  Line.swift
//  Distance
//
//  Created by CoderXu on 2020/11/11.
//

import Foundation
import simd
//定义直线
struct Line {
    var position = simd_float3.zero
    var direction = simd_float3.zero
    
    static func projectionOnLine(from point:simd_float3, to line:Line) -> simd_float3 {
        let vector = point - line.position
        let normalizedDirection = normalize(line.direction)
        let dotValue = dot(vector, normalizedDirection)
        let tarPoint = line.position + dotValue * normalizedDirection
        return tarPoint
    }
    
    static func distanceBetween(point:simd_float3, line:Line) -> Float{
        let position = projectionOnLine(from: point, to: line)
        return distance(position, point)
    }
    static func distanceSquaredBetween(point:simd_float3, line:Line) -> Float {
        let position = projectionOnLine(from: point, to: line)
        return distance_squared(position, point)
    }
    
    /// 精度不够高
    static func distanceBetween2(point:simd_float3, line:Line) -> Float {
        let vector = point - line.position
        let normalizedDirection = normalize(line.direction)
        let dotValue = dot(vector, normalizedDirection)
        let tarPoint = line.position + dotValue * normalizedDirection
        
        let disVector = point - tarPoint
        if disVector.tooLittleToBeNormalized() || vector.tooLittleToBeNormalized()  {
            return 0
        }
        let normalizedDis = normalize(disVector)
        
        return dot(vector, normalizedDis)
    }
    
    static func isPointOnLine(point:simd_float3, line:Line) -> Bool {
        let tarPoint = projectionOnLine(from: point, to: line)
        return distance_squared(tarPoint, point) < Float.toleranceThresholdLittle
    }
    static func isPointOnLine2(point:simd_float3, line:Line) -> Bool {
        let vector = point - line.position
        let crossValue = cross(vector, line.direction)
        return length_squared(crossValue) < Float.toleranceThresholdLittle
    }
    /// 精度不够高
    static func isPointOnLine3(point:simd_float3, line:Line) -> Bool {
        let vector = point - line.position
        if vector.tooLittleToBeNormalized()  {
            return true
        }
        let normalizedVector = normalize(vector)
        let normalizedDirection = normalize(line.direction)
        let dotValue = dot(normalizedVector, normalizedDirection)
        return abs(dotValue - 1) < Float.leastNonzeroMagnitude
    }
    
    static func pointToLineTest() {
        let line = Line(position: simd_float3(0, 0, 0), direction: simd_float3(0, 0, 1))
        let pointC = simd_float3(1, 5, 2000019)
        
        let distance = distanceBetween2(point: pointC, line: line)
        let distanceSquared = distanceSquaredBetween(point: pointC, line: line)
        let tarPoint = projectionOnLine(from: pointC, to: line)
        
        print("距离\(distance),距离平方\(distanceSquared), 投影点\(tarPoint)")
        print(isPointOnLine(point: pointC, line: line),isPointOnLine2(point: pointC, line: line),isPointOnLine3(point: pointC, line: line))
        if (distanceSquared < Float.toleranceThresholdLittle) {
            print("点在直线上")
        } else {
            print("点不在直线上")
        }
    }
    static func isParallel(line1:Line, line2:Line) -> Bool {
        let crossValue = cross(line1.direction, line2.direction)
        if crossValue.tooLittleToBeNormalized() {
            return true
        }
        return false
    }
    static func isSame(line1:Line, line2:Line) -> Bool {
        if !isParallel(line1: line1, line2: line2) {
            return false
        }
        let vector = line1.position - line2.position
        let crossValue = cross(vector, line1.direction)
        if crossValue.tooLittleToBeNormalized() {
            return true
        }
        return false
    }
    static func distanceBetween(line1:Line, line2:Line) -> Float {
        let crossValue = cross(line2.direction, line1.direction)
        let vector = line1.position - line2.position
        if crossValue.tooLittleToBeNormalized() {
            // 平行
            return distanceBetween(point:line1.position, line:line2)
        }
        let distanceVector = normalize(crossValue)
        
        let dis = dot(distanceVector, vector)
        
        return abs(dis)
    }
    static func footPoints(line1:Line, line2:Line) -> (simd_float3, simd_float3)? {
        let crossValue = cross(line2.direction, line1.direction)
        let vector = line1.position - line2.position
        if crossValue.tooLittleToBeNormalized() {
            // 平行
            return nil
        }
        let distanceVector = normalize(crossValue)
        
        let dis = dot(distanceVector, vector)
        
        let point2OnPlane = line2.position + dis * distanceVector
        
        let projectionOnLine1 = projectionOnLine(from: point2OnPlane, to: line1)
        let projectionVector = projectionOnLine1 - point2OnPlane
        
        let squared = length_squared(projectionVector)
        
        if squared < Float.toleranceThresholdLittle {
            // 垂足是 line2.position
            return (point2OnPlane,line2.position)
        }
        let x1:Float = squared / dot(line2.direction, projectionVector)
        let footPoint2 = point2OnPlane + x1 * line2.direction
        let footPoint1 = footPoint2 - dis * distanceVector
        
        return (footPoint1, footPoint2)
    }
    static func pointToLineTest2() {
        let line1 = Line(position: simd_float3(0, 0, 0), direction: simd_float3(0, 0, 1))
        let line2 = Line(position: simd_float3(50000, 50000, 50000), direction: simd_float3(1, 1, 1))
        let disBetween = distanceBetween(line1: line1, line2: line2)
        print("distanceBetween\(disBetween)")
        if let (foot1, foot2) = footPoints(line1: line1, line2: line2) {
            print(foot1, foot2)
            
        }
    }
    static func estimateLine(from points:[simd_float3]) -> Line? {
        if points.count < 2 {
            return nil
        }
        var position = simd_float3.zero
        for point in points {
            position += (point / Float(points.count))
        }
        var totalDistribution = simd_float3.zero
        for point in points {
            totalDistribution += abs(point - position)
        }
        if totalDistribution.tooLittleToBeNormalized() {
            return nil
        }
        totalDistribution = normalize(totalDistribution)
        let direction1 = simd_float3(totalDistribution.x, totalDistribution.y, totalDistribution.z)
        let direction2 = simd_float3(totalDistribution.x, -totalDistribution.y, totalDistribution.z)
        let direction3 = simd_float3(totalDistribution.x, totalDistribution.y, -totalDistribution.z)
        let direction4 = simd_float3(totalDistribution.x, -totalDistribution.y, -totalDistribution.z)
        var t1:Float = 0, t2:Float = 0, t3:Float = 0, t4:Float = 0
        
        for point in points {
            let vector = point - position
            t1 += abs(dot(vector, direction1))
            t2 += abs(dot(vector, direction2))
            t3 += abs(dot(vector, direction3))
            t4 += abs(dot(vector, direction4))
        }
        let max12 = t1 > t2 ? direction1 : direction2
        let max34 = t3 > t4 ? direction3 : direction4
        let direction = max(t1, t2) > max(t3, t4) ? max12 : max34
        
        return Line(position: position, direction: direction)
    }
    static func estimateLineSVD(from points:[simd_float3]) -> Line? {
        if points.count < 2 {
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
        let vt = svdResult.vt
        let offset = 0
        
        let direction = simd_float3(vt[offset], vt[offset+vt.columnCount], vt[offset+2*vt.columnCount])
        return Line(position: position, direction: direction)
    }
    static func pointToLineTest3() {
//        let points = [
////            simd_float3.zero,
//            simd_float3(-1, 0, 1000),
//            simd_float3(3, 0.1, 1000.1),
//            simd_float3(30, 5, 1000),
//            simd_float3(-40, -1, 1000.2),
//        ]
        
        let points = [
            simd_float3(-1, 0, -100),
            simd_float3(30, 0.1, -100.1),
            simd_float3(10, 10, 100),
            simd_float3(-30, 5, 100),
            simd_float3(40, -1, 100.2),
        ]
        
        let line = estimateLine(from: points)
        //(0.9945316, 0.10403323, 0.0091611175)))
        print(line as Any)
        let line2 = estimateLineSVD(from: points)
        print(line2 as Any)
        
    }
}

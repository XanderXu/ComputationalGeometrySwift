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
    let position:simd_float3
    let direction:simd_float3
    
    ///点在直线上的投影坐标
    static func projectionOnLine(from point:simd_float3, to line:Line) -> simd_float3 {
        let vector = point - line.position
        let normalizedDirection = normalize(line.direction)
        let dotValue = dot(vector, normalizedDirection)
        let tarPoint = line.position + dotValue * normalizedDirection
        return tarPoint
    }
    ///点与直线间的距离
    static func distanceBetween(point:simd_float3, line:Line) -> Float{
        let position = projectionOnLine(from: point, to: line)
        return distance(position, point)
    }
    ///点与直线间距离的平方
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
    ///点是否在直线上（误差范围内）
    static func isPointOnLine(point:simd_float3, line:Line) -> Bool {
        let tarPoint = projectionOnLine(from: point, to: line)
        return tarPoint.isAlmostSamePoint(to: point)
    }
    ///点是否在直线上（误差范围内）
    static func isPointOnLine2(point:simd_float3, line:Line) -> Bool {
        let vector = point - line.position
        return vector.isAlmostParallel(to: line.direction)
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
    
    ///直线与直线是否平行（误差范围内）
    static func isParallel(line1:Line, line2:Line) -> Bool {
        return line1.direction.isAlmostParallel(to: line2.direction)
    }
    ///直线与直线是否重合（误差范围内）
    static func isSame(line1:Line, line2:Line) -> Bool {
        if !isParallel(line1: line1, line2: line2) {
            return false
        }
        let vector = line1.position - line2.position
        if vector.tooLittleToBeNormalized() {//防止接近0的向量被判定为平行
            return false
        } else {
            return vector.isAlmostParallel(to: line1.direction)
        }
    }
    ///直线与直线间的距离
    static func distanceBetween(line1:Line, line2:Line) -> Float {
        let parallelResult = line2.direction.almostParallelRelative(to: line1.direction)
        let crossValue = parallelResult.crossValue
        if parallelResult.isParallel {
            // 平行
            return distanceBetween(point:line1.position, line:line2)
        }
        let distanceVector = normalize(crossValue)
        
        let vector = line1.position - line2.position
        let dis = dot(distanceVector, vector)
        
        return abs(dis)
    }
    ///直线与直线最近点坐标
    static func footPoints(line1:Line, line2:Line) -> (simd_float3, simd_float3)? {
        let parallelResult = line2.direction.almostParallelRelative(to: line1.direction)
        let crossValue = parallelResult.crossValue
        if parallelResult.isParallel {
            // 平行
            return nil
        }
        let distanceVector = normalize(crossValue)
        
        let vector = line1.position - line2.position
        let dis = dot(distanceVector, vector)
        
        let point2OnPlane = line2.position + dis * distanceVector
        
        let projectionOnLine1 = projectionOnLine(from: point2OnPlane, to: line1)
        let result = projectionOnLine1.almostSamePoint(to: point2OnPlane)
        if result.isSame {
            // 垂足是 line2.position
            return (point2OnPlane,line2.position)
        }
        let projectionVector = projectionOnLine1 - point2OnPlane
        let squared = result.distanceSquared
        
        let x1:Float = squared / dot(line2.direction, projectionVector)
        let footPoint2 = point2OnPlane + x1 * line2.direction
        let footPoint1 = footPoint2 - dis * distanceVector
        
        return (footPoint1, footPoint2)
    }
    
    ///SVD 拟合直线
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
    
}
extension Line {
    static func pointToLineTest() {
        let line = Line(position: simd_float3(0, 0, 0), direction: simd_float3(0, 0, 1))
        let pointC = simd_float3(1, 5, 2000019)
        
        let distance = distanceBetween2(point: pointC, line: line)
        let distanceSquared = distanceSquaredBetween(point: pointC, line: line)
        let tarPoint = projectionOnLine(from: pointC, to: line)
        
        print("距离\(distance),距离平方\(distanceSquared), 投影点\(tarPoint)")
        print(isPointOnLine(point: pointC, line: line),isPointOnLine2(point: pointC, line: line),isPointOnLine3(point: pointC, line: line))
        if (distanceSquared < Float.toleranceThreshold) {
            print("点在直线上")
        } else {
            print("点不在直线上")
        }
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
        
        
        let line2 = estimateLineSVD(from: points)
        print(line2 as Any)
        
    }
}

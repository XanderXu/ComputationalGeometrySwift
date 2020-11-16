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
}

func distanceToLine(from point:simd_float3, to line:Line) -> Float {
//    let position = positionOnLine(from: point, to: line)
//    return distance(position, point)
    let vector = point - line.position
    let normalizedDirection = normalize(line.direction)
    let dotValue = dot(vector, normalizedDirection)
    let tarPoint = line.position + dotValue * normalizedDirection
    
    let disVector = point - tarPoint
    if (length_squared(disVector) < Float.toleranceThreshold) || (length_squared(vector) < Float.toleranceThreshold)  {
        return 0
    }
    
    return dot(vector, normalize(disVector))
}

func positionOnLine(from point:simd_float3, to line:Line) -> simd_float3 {
    let vector = point - line.position
    let normalizedDirection = normalize(line.direction)
    let dotValue = dot(vector, normalizedDirection)
    let tarPoint = line.position + dotValue * normalizedDirection
    return tarPoint
}

func isPointOnLine(point:simd_float3, line:Line) -> Bool {
    let vector = point - line.position
    if length_squared(vector) < Float.toleranceThreshold  {
        return true
    }
    let normalizedVector = normalize(vector)
    let normalizedDirection = normalize(line.direction)
    let dotValue = dot(normalizedVector, normalizedDirection)
    return abs(dotValue - 1) < Float.leastNonzeroMagnitude
}
func isPointOnLine2(point:simd_float3, line:Line) -> Bool {
    let vector = point - line.position
    // 这一步判断可以省略
    if abs(vector.x) < Float.toleranceThreshold && abs(vector.y) < Float.toleranceThreshold && abs(vector.z) < Float.toleranceThreshold  {
        return true
    }
    let crossValue = cross(vector, line.direction)
    return abs(crossValue.x) < Float.toleranceThreshold && abs(crossValue.y) < Float.toleranceThreshold && abs(crossValue.z) < Float.toleranceThreshold
}
func isPointOnLine3(point:simd_float3, line:Line) -> Bool {
    let vector = point - line.position
    let crossValue = cross(vector, line.direction)
    return length_squared(crossValue) < Float.toleranceThreshold
}

func pointToLineTest() {
    let line = Line(position: simd_float3(1, 1, 1), direction: simd_float3(1, 1, 1))
    let pointC = simd_float3(2000000, 2000000, 2000010)

    let distance = distanceToLine(from: pointC, to: line)
    let tarPoint = positionOnLine(from: pointC, to: line)

    print("距离\(distance), 投影点\(tarPoint)")
    print(isPointOnLine(point: pointC, line: line),isPointOnLine2(point: pointC, line: line),isPointOnLine3(point: pointC, line: line))
    if (abs(distance) < Float.leastNonzeroMagnitude) {
        print("点在直线上")
    } else {
        print("点不在直线上")
    }
}
func isLineParallel(line1:Line, line2:Line) -> Bool {
    let crossValue = cross(line1.direction, line2.direction)
    if length_squared(crossValue) < Float.toleranceThreshold {
        return true
    }
    return false
}
func isSameLine(line1:Line, line2:Line) -> Bool {
    if !isLineParallel(line1: line1, line2: line2) {
        return false
    }
    let vector = line1.position - line2.position
    let crossValue = cross(vector, line1.direction)
    if length_squared(crossValue) < Float.toleranceThreshold {
        return true
    }
    return false
}
func distanceToLine(from line1:Line, to line2:Line) -> Float {
    let crossValue = cross(line1.direction, line2.direction)
    let vector = line1.position - line2.position
    if length_squared(crossValue) < Float.toleranceThreshold {
        // 平行
        return distanceToLine(from: line1.position, to: line2)
    }
    let distanceVector = normalize(crossValue)
    
    let dis = dot(distanceVector, vector)
    
    return abs(dis)
}

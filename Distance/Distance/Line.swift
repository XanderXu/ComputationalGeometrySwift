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
    if abs(disVector.x) < Float.leastNonzeroMagnitude, abs(disVector.y) < Float.leastNonzeroMagnitude, abs(disVector.z) < Float.leastNonzeroMagnitude {
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
    if abs(vector.x) < Float.leastNonzeroMagnitude, abs(vector.y) < Float.leastNonzeroMagnitude, abs(vector.z) < Float.leastNonzeroMagnitude  {
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
    if abs(vector.x) < Float.leastNonzeroMagnitude, abs(vector.y) < Float.leastNonzeroMagnitude,abs(vector.z) < Float.leastNonzeroMagnitude  {
        return true
    }
    let crossValue = cross(vector, line.direction)
    return abs(crossValue.x) < Float.leastNonzeroMagnitude && abs(crossValue.y) < Float.leastNonzeroMagnitude && abs(crossValue.z) < Float.leastNonzeroMagnitude
}
func isPointOnLine3(point:simd_float3, line:Line) -> Bool {
    let vector = point - line.position
    let crossValue = cross(vector, line.direction)
    return length_squared(crossValue) < Float.leastNonzeroMagnitude
}

func pointToLineTest() {
    let line = Line(position: simd_float3(1, 1, 1), direction: simd_float3(1, 1, 1))
    let pointC = simd_float3(20000000000, 20000000000, 20000000000)

    let distance = distanceToLine(from: pointC, to: line)
    let tarPoint = positionOnLine(from: pointC, to: line)

    print("距离\(distance), 投影点\(tarPoint)")
    print(isPointOnLine2(point: pointC, line: line))
    if (abs(distance) < Float.leastNonzeroMagnitude) {
        print("点在直线上")
    } else {
        print("点不在直线上")
    }
}

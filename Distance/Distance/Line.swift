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
    let position = positionOnLine(from: point, to: line)
    return distance(position, point)
}

func positionOnLine(from point:simd_float3, to line:Line) -> simd_float3 {
    let vectorAC = point - line.position
    let dotValue = dot(vectorAC, normalize(line.direction))
    let tarPoint = point + dotValue * normalize(line.direction)
    return tarPoint
}

func pointToLineTest() {
    let line = Line(position: simd_float3(1, 1, 1), direction: simd_float3(1, 1, 1))
    let pointC = simd_float3(2, 2, 2)

    let distance = distanceToLine(from: pointC, to: line)
    let tarPoint = positionOnLine(from: pointC, to: line)

    print("距离\(distance), 投影点\(tarPoint)")

    if (abs(distance) < Float.leastNonzeroMagnitude) {
        print("点在直线上")
    } else {
        print("点不在直线上")
    }
}

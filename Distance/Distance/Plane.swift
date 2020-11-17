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
}

func distanceToPlane(from point:simd_float3, to plane:Plane) -> Float {
    let vector = point - plane.position
    let dotValue = dot(vector, normalize(plane.normal))
    return dotValue
}

func positionOnPlane(from point:simd_float3, to plane:Plane) -> simd_float3 {
    let vector = point - plane.position
    let normalizedNormal = normalize(plane.normal)
    
    let dotValue = dot(vector, normalizedNormal)
    let tarPoint = point - dotValue * normalizedNormal
    return tarPoint
}
func isPointOnPlane(point:simd_float3, plane:Plane) -> Bool {
    let vector = point - plane.position
    let dotValue = dot(vector, plane.normal)
    return dotValue < Float.toleranceThresholdLittle
}
func pointToPlaneTest() {
    let plane = Plane(position: simd_float3(1, 1, 1), normal: simd_float3(0, 0, 3))
    let pointC = simd_float3(5000000000, 5, 1)

    let distance = distanceToPlane(from: pointC, to: plane)
    let tarPoint = positionOnPlane(from: pointC, to: plane)

    print("距离\(distance), 投影点\(tarPoint)")
    print(isPointOnPlane(point: pointC, plane:plane))
    if (abs(distance) < Float.leastNonzeroMagnitude) {
        print("点在平面上")
    } else {
        print("点不在平面上")
    }
}

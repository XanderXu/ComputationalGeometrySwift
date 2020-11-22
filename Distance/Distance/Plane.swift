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
// 返回值为：投影点坐标，距离，是否在平面上
func matrixRelationship(point:simd_float3, plane:Plane) -> (simd_float3, Float, Bool) {
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
func pointToPlaneTest() {
    let plane = Plane(position: simd_float3(1, 3, 1), normal: simd_float3(0, 0, 3))
    let pointC = simd_float3(50000, 50, 2)

    let distance = distanceToPlane(from: pointC, to: plane)
    let tarPoint = positionOnPlane(from: pointC, to: plane)

    print("距离\(distance), 投影点\(tarPoint)")
    print(matrixRelationship(point: pointC, plane: plane))
    
    print(isPointOnPlane(point: pointC, plane:plane))
    if (abs(distance) < Float.leastNonzeroMagnitude) {
        print("点在平面上")
    } else {
        print("点不在平面上")
    }
}

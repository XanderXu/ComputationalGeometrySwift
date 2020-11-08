//
//  main.swift
//  Plane
//
//  Created by CoderXu on 2020/11/8.
//

import Foundation
import simd

//定义平面
struct Plane {
    var position = simd_float3.zero
    var normal = simd_float3.zero
}

let plane = Plane(position: simd_float3(1, 1, 1), normal: simd_float3(0, 0, 3))
let pointC = simd_float3(5, 5, 5)
let vectorAC = pointC - plane.position
let dotValue = dot(vectorAC, normalize(plane.normal))
let distance = abs(dotValue)
let tarPoint = pointC - dotValue * normalize(plane.normal)
print(distance, tarPoint)

if (distance < Float.leastNonzeroMagnitude) {
    print("点在平面上")
} else {
    
}

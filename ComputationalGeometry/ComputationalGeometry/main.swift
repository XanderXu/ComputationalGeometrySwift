//
//  main.swift
//  Distance
//
//  Created by CoderXu on 2020/11/11.
//

import Foundation
import simd

//Line.pointToLineTest3()
//Plane.pointToPlaneTest3()
//let m = simd_float4x4([simd_float4([0.9, 0, 0.3, 0]),
//                        simd_float4([0, 0.9, 0.3, 0]),
//                        simd_float4([0.3, 0, 0.9, 0]),
//                        simd_float4([1, 1, 1, 1])
//                        ])
//print(m.orthogonalization())
let p1 = simd_float3(0, 0, 1)
let p2 = simd_float3(0, 1, 0)
let p3 = simd_float3(1, 0, 0)
let p4 = simd_float3(0, 0, -1)
let p5 = simd_float3(0, -1, 0)
let p6 = simd_float3(-1, 0, 0)
let p7 = simd_float3(0, -1, -1)
let p8 = simd_float3(-1, -1, 0)
let p9 = simd_float3(-1, 0, -1)
let p10 = simd_float3(0, 1, 1)
let p11 = simd_float3(1, 1, 0)
let p12 = simd_float3(1, 0, 1)
let pts = [p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12].shuffled()
let s = Sphere.minSphere(points: pts)
print(s)

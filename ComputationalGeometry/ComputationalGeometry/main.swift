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
let m = simd_float4x4([simd_float4([0.9, 0, 0.3, 0]),
                        simd_float4([0, 0.9, 0.3, 0]),
                        simd_float4([0.3, 0, 0.9, 0]),
                        simd_float4([1, 1, 1, 1])
                        ])
print(m.orthogonalization())

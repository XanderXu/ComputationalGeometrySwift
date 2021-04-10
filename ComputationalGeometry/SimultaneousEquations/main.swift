//
//  main.swift
//  SimultaneousEquations
//
//  Created by CoderXu on 2021/4/10.
//

import Foundation
import simd

//let m = matrix_float3x3(simd_float3(1, 1, 1),
//                        simd_float3(0, -1, 2),
//                        simd_float3(2, -1, 0)
//                        )
//let r = simd_float3(1, 2, 3)
//let x = m.inverse * r
//print(x)//SIMD3<Float>(2.0, 0.5, -0.5)
let nums:[Float] = [1,1,1,0,-1,2,2,-1,0]
let m = Matrix(source: nums, rowCount: 3, columnCount: 3)
let r = Matrix(source: [1,2,3,3,2,1], rowCount: 3, columnCount: 2)
let x = Matrix.sv(a: m, b: r)
print(x)
/*
 2.00 2.00
0.50 -0.50
-0.50 0.50
 */


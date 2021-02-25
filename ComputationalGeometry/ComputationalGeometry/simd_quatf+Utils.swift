//
//  simd_quatf+Utils.swift
//  ComputationalGeometry
//
//  Created by CoderXu on 2021/2/25.
//

import Foundation
import simd
extension simd_quatf {
    static func areQuaternionsClose(q1:simd_quatf, q2:simd_quatf) -> Bool {
        return dot(q1, q2) >= 0
    }
}

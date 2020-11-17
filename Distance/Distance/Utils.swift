//
//  Utils.swift
//  Distance
//
//  Created by CoderXu on 2020/11/16.
//

import Foundation
import simd
extension Float {
    static let toleranceThresholdLittle:Float = 0.0001
    static let toleranceThresholdBig:Float = 100000000
}
extension simd_float3 {
    func tooLittleToBeNormalized() -> Bool {
        return length_squared(self) < Float.toleranceThresholdLittle
    }
    func tooBigToBeNormalized() -> Bool {
        return length_squared(self) > Float.toleranceThresholdBig
    }
    func canBeNormalizedAccurately() -> Bool {
        return !(tooLittleToBeNormalized() || tooBigToBeNormalized())
    }
}

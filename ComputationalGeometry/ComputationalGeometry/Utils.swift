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
}
extension simd_float3 {
    func tooLittleToBeNormalized() -> Bool {
        return length_squared(self) < Float.toleranceThresholdLittle
    }
    
    func isAlmostParallel(to vector:simd_float3) -> Bool {
        return almostParallelRelative(to: vector).isParallel
    }
    func almostParallelRelative(to vector:simd_float3, tol:Float = Float.toleranceThresholdLittle) -> (isParallel:Bool, crossValue:simd_float3) {
        let lengthS1 = length_squared(self)
        let lengthS2 = length_squared(vector)
        let crossValue = cross(self, vector)
        // (sinx)^2 = (1-cos2x)/2
        let isParallel = length_squared(crossValue)/lengthS1/lengthS2 < tol
        
        return (isParallel:isParallel, crossValue:crossValue)
    }
}

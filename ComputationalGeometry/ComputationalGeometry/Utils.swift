//
//  Utils.swift
//  Distance
//
//  Created by CoderXu on 2020/11/16.
//

import Foundation
import simd
extension Float {
    static let toleranceThreshold:Float = 0.0001
}
extension simd_float3 {
    ///向量夹角，角度制
    func angleDegree(to vector:simd_float3) -> Float {
        return angleRadian(to: vector) * 57.29578
    }
    ///向量夹角，弧度制
    func angleRadian(to vector:simd_float3) -> Float {
        let num = sqrt(simd_length_squared(self) * simd_length_squared(vector))
        if num < Float.leastNormalMagnitude {
            return 0
        }
        var num2 = dot(self, vector) / num
        num2 = Swift.max(num2, -1)
        num2 = Swift.min(num2, 1)
        return acos(num2)
    }
    ///长度过小，归一化误差大
    func tooLittleToBeNormalized() -> Bool {
        return length_squared(self) < Float.leastNormalMagnitude
    }
    ///是否是同一个点
    func isSamePoint(to point:simd_float3) -> Bool {
        return almostSamePoint(to: point, tol: Float.leastNormalMagnitude).isSame
    }
    ///是否是同一个点（误差范围内）
    func isAlmostSamePoint(to point:simd_float3) -> Bool {
        return almostSamePoint(to: point).isSame
    }
    ///是否是同一个点（误差范围内），同时返回距离平方
    func almostSamePoint(to point:simd_float3, tol:Float = Float.toleranceThreshold) -> (isSame:Bool, distanceSquared:Float) {
        let distanceSquared = distance_squared(self, point)
        return (isSame:distanceSquared < tol * tol, distanceSquared:distanceSquared)
    }
    ///是否平行
    func isParallel(to vector:simd_float3) -> Bool {
        return almostParallelRelative(to: vector, tol: Float.leastNormalMagnitude).isParallel
    }
    ///是否平行（误差范围内）
    func isAlmostParallel(to vector:simd_float3) -> Bool {
        return almostParallelRelative(to: vector).isParallel
    }
    ///是否平行（误差范围内），并返回叉乘结果
    func almostParallelRelative(to vector:simd_float3, tol:Float = Float.toleranceThreshold) -> (isParallel:Bool, crossValue:simd_float3) {
        let lengthS1 = length_squared(self)
        let lengthS2 = length_squared(vector)
        if lengthS1 < Float.leastNormalMagnitude || lengthS2 < Float.leastNormalMagnitude {
            return (isParallel:false, crossValue:.zero)
        }
        let crossValue = cross(self, vector)
        // (sinx)^2 = (1-cos2x)/2
        let isParallel = length_squared(crossValue)/lengthS1/lengthS2 < tol * tol
        
        return (isParallel:isParallel, crossValue:crossValue)
    }
    ///是否垂直
    func isPerpendicular(to vector:simd_float3) -> Bool {
        return almostPerpendicular(to: vector, tol: Float.leastNormalMagnitude).isPerpendicular
    }
    ///是否垂直（误差范围内）
    func isAlmostPerpendicular(to vector:simd_float3) -> Bool {
        return almostPerpendicular(to: vector).isPerpendicular
    }
    ///是否垂直（误差范围内），并返回点乘结果
    func almostPerpendicular(to vector:simd_float3, tol:Float = Float.toleranceThreshold) -> (isPerpendicular:Bool, dotValue:Float) {
        let lengthS1 = length_squared(self)
        let lengthS2 = length_squared(vector)
        if lengthS1 < Float.leastNormalMagnitude || lengthS2 < Float.leastNormalMagnitude {
            return (isPerpendicular:false, dotValue:.zero)
        }
        let dotValue = dot(self, vector)
        let isPerpendicular = dotValue * dotValue / lengthS1 / lengthS2 < tol * tol
        
        return (isPerpendicular:isPerpendicular, dotValue:dotValue)
    }
}
extension Collection where Self.Element == simd_float3 {
    ///SVD 拟合直线、平面、外接球、包围盒
    func estimateSVD() -> (line:Line?, plane:Plane?, sphere:Sphere?, boundingBox:simd_float4x4?) {
        if self.count < 3 {
            return (nil, nil, nil, nil)
        }
        var source:[Float] = Array(repeating: 0, count: self.count*3)
        var position = simd_float3.zero
        for point in self {
            position += (point / Float(self.count))
        }
        for (row,point) in self.enumerated() {
            source[row] = point.x - position.x
            source[row+self.count] = point.y - position.y
            source[row+2*self.count] = point.z - position.z
        }
        // source 中数据顺序为[x0,x1,x2.....y0,y1,y2.....z0,z1,z3....]，竖向按列依次填充到 rowCount行*3列 的矩阵中
        let ss = Matrix(source: source, rowCount: self.count, columnCount:3)
        let svdResult = Matrix.svd(a: ss)
        let vt = svdResult.vt
        let sigma = svdResult.sigma
        
        var offset = 0
        let direction = simd_float3(vt[offset], vt[offset+vt.columnCount], vt[offset+2*vt.columnCount])
        let line = Line(position: position, direction: direction)
        
        offset = (vt.rowCount - 1)
        let normal = simd_float3(vt[offset], vt[offset+vt.columnCount], vt[offset+2*vt.columnCount])
        let plane = Plane(position: position, normal: normal)
        
        let radius = sigma[0]
        let sphere = Sphere(position: position, radius: radius)
        
        offset = 1
        let xAxis = direction * sigma[0]
        let yAxis = simd_float3(vt[offset], vt[offset+vt.columnCount], vt[offset+2*vt.columnCount]) * sigma[1]
        let zAxis = normal * sigma[2]
        let matrix = simd_float4x4([simd_float4(xAxis, 0),
                                    simd_float4(yAxis, 0),
                                    simd_float4(zAxis, 0),
                                    simd_float4(position, 1)])
        return (line:line, plane:plane, sphere:sphere, boundingBox:matrix)
    }
}

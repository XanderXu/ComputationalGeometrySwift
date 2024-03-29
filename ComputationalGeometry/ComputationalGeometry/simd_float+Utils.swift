//
//  simd_float+Utils.swift
//  Distance
//
//  Created by CoderXu on 2020/11/16.
//

import Foundation
import simd
extension Float {
    /// 0.0001
    static let toleranceThreshold:Float = 0.0001
    ///1.0842022e-19
    static let sqrtLeastNormalMagnitude:Float = sqrtf(Float.leastNormalMagnitude)
}
extension simd_float3 {
    ///向量夹角，角度制
    func angleDegree(to vector:simd_float3) -> Float {
        return angleRadian(to: vector) * 57.29578
    }
    ///向量夹角，弧度制
    func angleRadian(to vector:simd_float3) -> Float {
        let num = sqrt(length_squared(self) * length_squared(vector))
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
        return distance_squared(self, point) < Float.leastNormalMagnitude
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
    ///是否平行。0 向量返回 true
    func isParallel(to vector:simd_float3) -> Bool {
        let crossValue = cross(self, vector)
        return length_squared(crossValue) < Float.leastNormalMagnitude
    }
    ///是否平行（误差范围内）。0 向量返回 true
    func isAlmostParallel(to vector:simd_float3) -> Bool {
        return almostParallelRelative(to: vector).isParallel
    }
    ///是否平行（误差范围内），并返回叉乘结果。数学定义：0 向量与任何向量平行，此处返回 true，请自行处理
    func almostParallelRelative(to vector:simd_float3, tol:Float = Float.toleranceThreshold) -> (isParallel:Bool, crossValue:simd_float3) {
        let lengthS1 = length_squared(self)
        let lengthS2 = length_squared(vector)
        if lengthS1 < Float.leastNormalMagnitude || lengthS2 < Float.leastNormalMagnitude {
            return (isParallel:true, crossValue:.zero)
        }
        let crossValue = cross(self, vector)
        // (sinx)^2 = (1-cos2x)/2
        let isParallel = length_squared(crossValue)/lengthS1/lengthS2 < tol * tol
        
        return (isParallel:isParallel, crossValue:crossValue)
    }
    ///是否垂直。0 向量为 false
    func isPerpendicular(to vector:simd_float3) -> Bool {
        let notPerpendicular = abs(dot(self, vector)) > Float.leastNormalMagnitude
        return !notPerpendicular
    }
    ///是否垂直（误差范围内）。0 向量为 false
    func isAlmostPerpendicular(to vector:simd_float3) -> Bool {
        return almostPerpendicular(to: vector).isPerpendicular
    }
    ///是否垂直（误差范围内），并返回点乘结果。数学定义：0 向量未明确定义，此处返回 false，请自行处理
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
extension simd_float4 {
    func firstFloat3() -> simd_float3 {
        return simd_float3(x, y, z)
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
//        let sigma = svdResult.sigma
        
        var offset = 0
        let direction = simd_float3(vt[offset], vt[offset+vt.columnCount], vt[offset+2*vt.columnCount])
        let line = Line(position: position, direction: direction)
        
        offset = (vt.rowCount - 1)
        let normal = simd_float3(vt[offset], vt[offset+vt.columnCount], vt[offset+2*vt.columnCount])
        let plane = Plane(position: position, normal: normal)
        
        
        offset = 1
        let xAxis = direction
        let yAxis = simd_float3(vt[offset], vt[offset+vt.columnCount], vt[offset+2*vt.columnCount])
        let zAxis = normal
        let matrix = simd_float4x4([simd_float4(xAxis, 0),
                                    simd_float4(yAxis, 0),
                                    simd_float4(zAxis, 0),
                                    simd_float4(position, 1)])
        var maxEdge = simd_float4(-Float.infinity, -Float.infinity, -Float.infinity, 1)
        var minEdge = simd_float4(Float.infinity, Float.infinity, Float.infinity, 1)
        for point in self {
            let p = matrix.inverse * simd_float4(point, 1)
            maxEdge = simd.max(maxEdge, p)
            minEdge = simd.min(minEdge, p)
        }
        
        let centerPoint = matrix * (maxEdge + minEdge)/2
        let lengthBox = maxEdge - minEdge
        
        let centerP = simd_float3(centerPoint.x, centerPoint.y, centerPoint.z)
        
        let radius = simd_length(simd_float3(lengthBox.x, lengthBox.y, lengthBox.z)) / 2
        let sphere = Sphere(position: centerP, radius: radius)
        
        let boundingBox = simd_float4x4([simd_float4(xAxis*lengthBox.x, 0),
                                         simd_float4(yAxis*lengthBox.y, 0),
                                         simd_float4(zAxis*lengthBox.z, 0),
                                         simd_float4(centerP, 1)])
        
        return (line:line, plane:plane, sphere:sphere, boundingBox:boundingBox)
    }
}


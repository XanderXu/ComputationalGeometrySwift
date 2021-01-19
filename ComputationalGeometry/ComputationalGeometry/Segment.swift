//
//  Segment.swift
//  ComputationalGeometry
//
//  Created by CoderXu on 2020/12/15.
//

import Foundation
import simd
//定义线段
struct Segment {
    let point1:simd_float3
    let point2:simd_float3
    
    ///点到线段的最近点坐标
    static func nearestPointOnSegment(from point:simd_float3, to segment:Segment) -> simd_float3 {
        let direction = segment.point2 - segment.point1
        
        let vector1 = point - segment.point1
        let normalizedDirection = normalize(direction)
        let dotValue1 = dot(vector1, normalizedDirection)
        if dotValue1 <= 0 {
            return segment.point1
        }
        let vector2 = point - segment.point2
        let dotValue2 = dot(vector2, -normalizedDirection)
        if dotValue2 <= 0 {
            return segment.point2
        }
        let tarPoint = segment.point1 + dotValue1 * normalizedDirection
        return tarPoint
    }
    ///点到线段的距离
    static func distanceBetween(point:simd_float3, segment:Segment) -> Float{
        let position = nearestPointOnSegment(from: point, to: segment)
        return distance(position, point)
    }
    ///点到线段距离的平方
    static func distanceSquaredBetween(point:simd_float3, segment:Segment) -> Float {
        let position = nearestPointOnSegment(from: point, to: segment)
        return distance_squared(position, point)
    }
    
    ///线段与线段最近点坐标
    static func nearestPoints(segment1:Segment, segment2:Segment) -> (simd_float3, simd_float3)? {
        //构造局部坐标系，segment1为 x 轴，point1为坐标原点；y 轴垂直于线段构成的平面；
        let direction1 = segment1.point2 - segment1.point1
        let direction2 = segment2.point2 - segment2.point1
        let p = direction1.almostParallelRelative(to: direction2)
        if p.isParallel {
            return nil
        }
        let xAxis = normalize(direction1)
        let yAxis = normalize(p.crossValue)
        let zAxis = normalize(cross(xAxis, yAxis))
        let localMatrix = matrix_float4x4(
            simd_float4(xAxis, 0),
            simd_float4(yAxis, 0),
            simd_float4(zAxis, 0),
            simd_float4(segment1.point1, 1)
        )
        
        //计算线段各个点，在局部坐标系中的位置
        let s1p1 = localMatrix.inverse * simd_float4(segment1.point1, 1)
        let s1p2 = localMatrix.inverse * simd_float4(segment1.point2, 1)
        let s2p1 = localMatrix.inverse * simd_float4(segment2.point1, 1)
        let s2p2 = localMatrix.inverse * simd_float4(segment2.point2, 1)
        
        
        
        
        return nil
    }
}

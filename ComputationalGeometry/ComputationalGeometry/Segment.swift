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
        //构造局部坐标系，segment1 为 x 轴，point1 为坐标原点；z 轴垂直于线段构成的平面；
        let direction1 = segment1.point2 - segment1.point1
        let direction2 = segment2.point2 - segment2.point1
        let p = direction1.almostParallelRelative(to: direction2)
        
        var zValue = p.crossValue
        if p.isParallel {
            // 平行时，构造特殊的矩阵
            let xDirection = simd_float3(1, 0, 0)
            let px = direction1.almostParallelRelative(to: xDirection)
            if px.isParallel {
                zValue = simd_float3(0, 0, 1)
            } else {
                zValue = cross(xDirection,direction1)
            }
        }
        let xAxis = normalize(direction1)
        let zAxis = normalize(zValue)
        let yAxis = normalize(cross(zAxis, xAxis))
        let localMatrix = matrix_float4x4(
            simd_float4(xAxis, 0),
            simd_float4(yAxis, 0),
            simd_float4(zAxis, 0),
            simd_float4(segment1.point1, 1)
        )
        
        //计算线段各个点，在局部坐标系中的位置
//        let s1p1 = localMatrix.inverse * simd_float4(segment1.point1, 1)
        let s1p2 = localMatrix.inverse * simd_float4(segment1.point2, 1)
        let s2p1 = localMatrix.inverse * simd_float4(segment2.point1, 1)
        let s2p2 = localMatrix.inverse * simd_float4(segment2.point2, 1)
        
        if p.isParallel {
            // 平行时，可能有重合部分，无数个最近点；也可能无重合部分，端点最近
            if s2p1.x < 0 && s2p2.x < 0 {
                let p2 = s2p1.x > s2p2.x ? segment2.point1 : segment2.point2
                return (segment1.point1, p2)
            } else if s2p1.x > s1p2.x && s2p2.x > s1p2.x {
                let p2 = s2p1.x < s2p2.x ? segment2.point1 : segment2.point2
                return (segment1.point2, p2)
            }
            return nil
        }
        
        let factor = s2p2.y / (s2p2.y - s2p1.y)//前面已判断，不可能平行，故除数不为0
        // segment2 或延长线必定与 x 轴相交，交点为 crossP2
        let crossP2 = factor * s2p1 + (1-factor) * s2p2
        
        if crossP2.x < 0 {
            // 相交在 segment1 范围外，左侧
            if s2p1.x < 0 || s2p2.x < 0 {
                // segment2 有部分在 segment1 左侧
                let p2 = nearestPointOnSegment(from: segment1.point1, to: segment2)
                return (segment1.point1, p2)
            } else if factor > 1 {
                // s2p1 离交点近
                let p1 = nearestPointOnSegment(from: segment2.point1, to: segment1)
                return (p1, segment2.point1)
            } else {
                // s2p2 离交点近
                let p1 = nearestPointOnSegment(from: segment2.point2, to: segment1)
                return (p1, segment2.point2)
            }
        } else if crossP2.x > s1p2.x {
            // 相交在 segment1 范围外，右侧
            if s2p1.x > s1p2.x || s2p2.x > s1p2.x {
                // segment2 有部分在 segment1 右侧
                let p2 = nearestPointOnSegment(from: segment1.point2, to: segment2)
                return (segment1.point2, p2)
            } else if factor > 1 {
                // s2p1 离交点近
                let p1 = nearestPointOnSegment(from: segment2.point1, to: segment1)
                return (p1, segment2.point1)
            } else {
                // s2p2 离交点近
                let p1 = nearestPointOnSegment(from: segment2.point2, to: segment1)
                return (p1, segment2.point2)
            }
        } else {
            // 相交在 segment1 范围内
            if factor > 1 {
                // s2p1 离交点近
                let p1 = nearestPointOnSegment(from: segment2.point1, to: segment1)
                return (p1, segment2.point1)
            } else if factor < 0 {
                // s2p2 离交点近
                let p1 = nearestPointOnSegment(from: segment2.point2, to: segment1)
                return (p1, segment2.point2)
            }
            
            let crossP1x = crossP2.x
            
            let p2 = localMatrix * crossP2
            let p1 = localMatrix * simd_float4(crossP1x, 0, 0, 1)
            return (simd_float3(p1.x, p1.y, p1.z), simd_float3(p2.x, p2.y, p2.z))
        }
    }
}

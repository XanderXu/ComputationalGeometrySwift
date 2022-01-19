//
//  Triangle.swift
//  ComputationalGeometry
//
//  Created by CoderXu on 2020/12/15.
//

import Foundation
import simd
//定义三角形
struct Triangle {
    let points:float3x3
    
    var point1: simd_float3 {
        get{
            return points.columns.0
        }
    }
    var point2: simd_float3 {
        get{
            return points.columns.1
        }
    }
    var point3: simd_float3 {
        get{
            return points.columns.2
        }
    }
    ///三条边的长度。(x,y,z) 按顺序为 point1 的对边长，point2 的对边长，point3 的对边长
    static func edgesLength(triangle:Triangle) ->simd_float3 {
        let l1 = distance(triangle.point2, triangle.point3)
        let l2 = distance(triangle.point1, triangle.point3)
        let l3 = distance(triangle.point2, triangle.point1)
        return simd_float3(l1, l2, l3)
    }
    ///三条边的长度的平方。(x,y,z) 按顺序为 point1 的对边长，point2 的对边长，point3 的对边长
    static func edgesLengthSquared(triangle:Triangle) ->simd_float3 {
        let l1 = distance_squared(triangle.point2, triangle.point3)
        let l2 = distance_squared(triangle.point1, triangle.point3)
        let l3 = distance_squared(triangle.point2, triangle.point1)
        return simd_float3(l1, l2, l3)
    }
    ///三角形的周长
    static func perimeter(triangle:Triangle) -> Float {
        return edgesLength(triangle: triangle).sum()
    }
    ///是否是钝角三角形
    static func isObtuse(triangle:Triangle) -> Bool {
        let vector1 = triangle.point2 - triangle.point1
        let vector2 = triangle.point3 - triangle.point2
        let vector3 = triangle.point1 - triangle.point3
        
        let dot1 = dot(vector1, vector2)
        let dot2 = dot(vector2, vector3)
        let dot3 = dot(vector3, vector1)
        
        return dot1 > 0 || dot2 > 0 || dot3 > 0
    }
    ///三角形的面积
    static func area(triangle:Triangle) -> Float {
        let vector1 = triangle.point2 - triangle.point1
        let vector2 = triangle.point3 - triangle.point2
        let crossValue = cross(vector1, vector2)
        
        return length(crossValue) / 2
    }
    ///由三边长度求面积（海伦公式）
    static func area(edgesLength:simd_float3) -> Float {
        let s = edgesLength.sum()*0.5
        return sqrtf(s*(s-edgesLength.x)*(s-edgesLength.y)*(s-edgesLength.z))
    }
    ///三角形的重心、几何中心
    static func barycenter(triangle:Triangle) -> simd_float3 {
        // 两者等价
//        return triangle.points * simd_float3(arrayLiteral: 1/3.0)
        return (triangle.point1 + triangle.point2 + triangle.point3)/3
    }
    ///三角形重心的重心坐标
    static func barycenterInBarycentricCoordinate(triangle:Triangle) -> simd_float3 {
        return simd_float3(arrayLiteral: 1/3.0)
    }
    ///三角形内心、三边距离相等点
    static func incenter(triangle:Triangle) -> simd_float3 {
        let coor = incenterInBarycentricCoordinate(triangle: triangle)
        let r = triangle.points * coor
        return r
    }
    ///三角形内心的重心坐标
    static func incenterInBarycentricCoordinate(triangle:Triangle) -> simd_float3 {
        let edges = edgesLength(triangle: triangle)
        let p = edges.sum()
        return edges / p
    }
    ///三角形内切圆半径
    static func incenterRadius(triangle:Triangle) -> Float {
        let edges = edgesLength(triangle: triangle)
        let p = edges.sum()
        let A = area(edgesLength: edges)
        return A / p
    }
    ///三角形外心、三点距离相等点
    static func circumcenter(triangle:Triangle) -> simd_float3 {
        let coor = circumcenterInBarycentricCoordinate(triangle: triangle)
        let s = triangle.points * coor
        return s
    }
    ///三角形外心的重心坐标
    static func circumcenterInBarycentricCoordinate(triangle:Triangle) -> simd_float3 {
        let e1 = triangle.point3 - triangle.point2
        let e2 = triangle.point1 - triangle.point3
        let e3 = triangle.point2 - triangle.point1
        
        let edgesSquared = edgesLengthSquared(triangle: triangle)
        let v = simd_float3(dot(e2,e3), dot(e3,e1), dot(e1,e2))
        let t = v * edgesSquared
        let d = dot(v, edgesSquared)
        return t / d
    }
    ///三角形外接圆（球）半径
    static func circumcenterRadius(triangle:Triangle) -> Float {
        let edges = edgesLength(triangle: triangle)
        let A = area(edgesLength: edges)
        let ss = edges.x * edges.y * edges.z / 4 / A
        return ss
    }
    ///点在三角形上的重心坐标
    static func computeBarycenricCoordinate2(of point:simd_float3, in triangle:Triangle) -> simd_float3? {
        let d1 = triangle.point2 - triangle.point1
        let d2 = triangle.point3 - triangle.point2
        let n = cross(d1, d2)
        
        let t = point - triangle.point1
        if !n.isPerpendicular(to: t) {
            // 点与三角形不共面
            return nil
        }
        var u1,u2,u3,u4:Float
        var v1,v2,v3,v4:Float
        if (fabsf(n.x) >= fabsf(n.y)) && (fabsf(n.x) >= fabsf(n.z)) {
            // 抛弃 x，向 yz 平面投影
            u1 = triangle.point1.y - triangle.point3.y
            u2 = triangle.point2.y - triangle.point3.y
            u3 = point.y - triangle.point1.y
            u4 = point.y - triangle.point3.y
            
            v1 = triangle.point1.z - triangle.point3.z
            v2 = triangle.point2.z - triangle.point3.z
            v3 = point.z - triangle.point1.z
            v4 = point.z - triangle.point3.z
        } else if fabsf(n.y) >= fabsf(n.z){
            // 抛弃 y，向 xz 平面投影
            u1 = triangle.point1.z - triangle.point3.z
            u2 = triangle.point2.z - triangle.point3.z
            u3 = point.z - triangle.point1.z
            u4 = point.z - triangle.point3.z
            
            v1 = triangle.point1.x - triangle.point3.x
            v2 = triangle.point2.x - triangle.point3.x
            v3 = point.x - triangle.point1.x
            v4 = point.x - triangle.point3.x
        } else {
            u1 = triangle.point1.x - triangle.point3.x
            u2 = triangle.point2.x - triangle.point3.x
            u3 = point.x - triangle.point1.x
            u4 = point.x - triangle.point3.x
            
            v1 = triangle.point1.y - triangle.point3.y
            v2 = triangle.point2.y - triangle.point3.y
            v3 = point.y - triangle.point1.y
            v4 = point.y - triangle.point3.y
        }
        let denom = v1 * u2 - v2 * u1
        if abs(denom) < Float.leastNormalMagnitude {
            // 退化三角形:面积为零的三角形
            return nil
        }
        // 计算重心坐标
        let oneOverDenom = 1.0 / denom
        let b0 = (v4*u2 - v2*u4) * oneOverDenom
        let b1 = (v1*u3 - v3*u1) * oneOverDenom
        let b2 = 1 - b0 - b1
        return simd_float3(b0, b1, b2)
    }
    ///点在三角形上的重心坐标
    static func computeBarycenricCoordinate(of point:simd_float3, in triangle:Triangle) -> simd_float3? {
        let e1 = triangle.point3 - triangle.point2
        let e2 = triangle.point1 - triangle.point3
        let e3 = triangle.point2 - triangle.point1
        let d1 = point - triangle.point1
        let d2 = point - triangle.point2
        let d3 = point - triangle.point3
        
        let n = cross(e1, e2)
        if !n.isPerpendicular(to: d1) {
            // 点与三角形不共面
            return nil
        }
        let an = dot(cross(e1, e2), n)
        if an < Float.leastNormalMagnitude {
            // 退化三角形:面积为零的三角形
            return nil
        }
        let b1 = dot(cross(e1, d3), n) / an
        let b2 = dot(cross(e2, d1), n) / an
        let b3 = dot(cross(e3, d2), n) / an
        return simd_float3(b1, b2, b3)
    }
    ///点到三角形的最近点坐标
    static func nearestPoint(point:simd_float3, triangle:Triangle) -> simd_float3 {
        let e1 = triangle.point3 - triangle.point2
        let e2 = triangle.point1 - triangle.point3
        let e3 = triangle.point2 - triangle.point1
        
        var midWayPoint = point
        var d1 = point - triangle.point1
        var d2 = point - triangle.point2
        var d3 = point - triangle.point3
        
        let n = cross(e1, e2)
        if !n.isPerpendicular(to: d1) {
            // 点与三角形不共面
            let normalizedNormal = normalize(n)
            
            let dotValue = dot(d1, normalizedNormal)
            midWayPoint = point - dotValue * normalizedNormal
            // 点与三角形不共面，求投影点
            d1 = midWayPoint - triangle.point1
            d2 = midWayPoint - triangle.point2
            d3 = midWayPoint - triangle.point3
        }
        // 计算点是否在三角形内部
        let p2Cross = dot(cross(d3, d1), cross(e1, -e3))
        let p3Cross = dot(cross(d2, d1), cross(e2, -e1))
        let p1Cross = dot(cross(d2, d3), cross(e3, -e2))
        
        if p1Cross >= 0 && p2Cross >= 0 && p3Cross >= 0 {
            // 全大于 0，点在三角形内部
            return midWayPoint
        } else if p1Cross * p2Cross * p3Cross > 0 {
            // 有两个小于0的，点在顶点处。（如果是钝角，可能离边更近；锐角则离端点更近）
            var segment1:Segment!
            var segment2:Segment!
            if p1Cross > 0 {
                segment1 = Segment(point1: triangle.point1, point2: triangle.point3)
                segment2 = Segment(point1: triangle.point2, point2: triangle.point1)
            } else if p2Cross > 0 {
                segment1 = Segment(point1: triangle.point2, point2: triangle.point3)
                segment2 = Segment(point1: triangle.point2, point2: triangle.point1)
            } else {
                segment1 = Segment(point1: triangle.point2, point2: triangle.point3)
                segment2 = Segment(point1: triangle.point1, point2: triangle.point3)
            }
            let t1 = Segment.nearestPointOnSegment(from: point, to: segment1)
            let t2 = Segment.nearestPointOnSegment(from: point, to: segment2)
            return distance_squared(t1, point) > distance_squared(t2, point) ? t2 : t1
        } else {
            // 有一个小于0，点在边处
            var segment:Segment!
            if p1Cross < 0 {
                segment = Segment(point1: triangle.point2, point2: triangle.point3)
            } else if p2Cross < 0 {
                segment = Segment(point1: triangle.point1, point2: triangle.point3)
            } else {
                segment = Segment(point1: triangle.point2, point2: triangle.point1)
            }
            return Segment.nearestPointOnSegment(from: point, to: segment)
        }
    }
    ///射线与三角形相交，交点
    static func intersectionPointBarycenricCoordinate(ray:Ray, triangle:Triangle) -> simd_float3? {
        let e1 = triangle.point3 - triangle.point2
        let e2 = triangle.point1 - triangle.point3
        let e3 = triangle.point2 - triangle.point1
        
        let n = cross(e1, e2)
        
        let v = ray.position - triangle.point1
        let rdn = dot(ray.direction, n)
        if rdn < Float.leastNormalMagnitude {
            // 射线与三角形所在平面，平行
            return nil
        }
        let x = -dot(v, n) / rdn
        if x < 0 {
            return nil
        } else {
            let targetPoint = ray.position + x * ray.direction
            let d1 = triangle.point1 - targetPoint
            let d2 = triangle.point2 - targetPoint
            let d3 = triangle.point3 - targetPoint
            // 计算点是否在三角形内部
            let p2Cross = dot(cross(d3, d1), cross(e1, -e3))
            let p3Cross = dot(cross(d2, d1), cross(e2, -e1))
            let p1Cross = dot(cross(d2, d3), cross(e3, -e2))
            
            if p1Cross >= 0 && p2Cross >= 0 && p3Cross >= 0 {
                // 全大于 0，点在三角形内部
                return targetPoint
            } else {
                return nil
            }
        }
    }
}

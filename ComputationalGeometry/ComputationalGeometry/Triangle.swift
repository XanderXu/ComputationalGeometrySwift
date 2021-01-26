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
        return (triangle.point1 + triangle.point2 + triangle.point3)/3
    }
    ///三角形重心的重心坐标
    static func barycenterInBarycentricCoordinate(triangle:Triangle) -> simd_float3 {
        return simd_float3(arrayLiteral: 1/3.0)
    }
    ///三角形内心、三边距离相等点
    static func incenter(triangle:Triangle) -> simd_float3 {
        let edges = edgesLength(triangle: triangle)
        let p = edges.sum()
        
        let r = triangle.points * edges
        return r / p
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
        let e1 = triangle.point3 - triangle.point2
        let e2 = triangle.point1 - triangle.point3
        let e3 = triangle.point2 - triangle.point1
//        let d1 = -dot(e2,e3)
//        let d2 = -dot(e3,e1)
//        let d3 = -dot(e1,e2)
        
//        let c1 = d2*d3
//        let c2 = d3*d1
//        let c3 = d1*d2
//        let c = c1 + c2 + c3
//        let c = dot(e3,e1)*dot(e1,e2) + dot(e1,e2)*dot(e2,e3) + dot(e2,e3)*dot(e3,e1)
//        let c = -0.5*(dot(e1,e2)*dot(e3,e3) + dot(e2,e3)*dot(e1,e1) + dot(e3,e1)*dot(e2,e2))
        
//        let r1 = Float(dot(e2,e3) * dot(-e1,e1)) * triangle.point1
//        let r2 = (c3 + c1) * triangle.point2
//        let r3 = (c1 + c2) * triangle.point3
//
//        return (r1 + r2 + r3) / (2 * c)
//        let r1 = Float(dot(e2,e3) * dot(-e1,e1)) * triangle.point1
//        let r2 = Float(dot(e3,e1) * dot(-e2,e2)) * triangle.point2
//        let r3 = Float(dot(e1,e2) * dot(-e3,e3)) * triangle.point3
        
        let edges = edgesLength(triangle: triangle)
        
//        let s = dot(e2,e3) * edges.x * triangle.point1 + dot(e3,e1) * edges.y * triangle.point2 + dot(e1,e2) * edges.z * triangle.point3
        let v = simd_float3(dot(e2,e3), dot(e3,e1), dot(e1,e2))
        let t = v * edges
        let s = triangle.points * t
        let d = dot(v, edges)
        return s / d
    }
    ///三角形外心的重心坐标
    static func circumcenterInBarycentricCoordinate(triangle:Triangle) -> simd_float3 {
        let e1 = triangle.point3 - triangle.point2
        let e2 = triangle.point1 - triangle.point3
        let e3 = triangle.point2 - triangle.point1
        
        let edges = edgesLength(triangle: triangle)
        let v = simd_float3(dot(e2,e3), dot(e3,e1), dot(e1,e2))
        let t = v * edges
        let d = dot(v, edges)
        return t / d
    }
    ///三角形外切圆半径
    static func circumcenterRadius(triangle:Triangle) -> Float {
        let e1 = triangle.point3 - triangle.point2
        let e2 = triangle.point1 - triangle.point3
        let e3 = triangle.point2 - triangle.point1
//        let d1 = -dot(e2,e3)
//        let d2 = -dot(e3,e1)
//        let d3 = -dot(e1,e2)
        
//        let c1 = d2*d3
//        let c2 = d3*d1
//        let c3 = d1*d2
//        let c = c1 + c2 + c3
//        let c = dot(e3,e1)*dot(e1,e2) + dot(e1,e2)*dot(e2,e3) + dot(e2,e3)*dot(e3,e1)
//        let c = -0.5*(dot(e1,e2)*dot(e3,e3) + dot(e2,e3)*dot(e1,e1) + dot(e3,e1)*dot(e2,e2))
       
//        let s = sqrtf(dot(e3,e3)*dot(e1,e1)*dot(e2,e2)/c)
//        return s / 2
        let edges = edgesLength(triangle: triangle)
        let v = simd_float3(dot(e2,e3), dot(e3,e1), dot(e1,e2))
        let d = dot(v, edges)
        let ss = edges.x * edges.y * edges.z / (sqrtf(-2 * d))
        return ss
    }
    ///点在三角形上的重心坐标
    static func computeBarycenricCoordinate2(of point:simd_float3, in triangle:Triangle) -> simd_float3? {
        let d1 = triangle.point2 - triangle.point1
        let d2 = triangle.point3 - triangle.point2
        let n = cross(d1, d2)
        
        let t = point - triangle.point1
        if abs(dot(t, n)) > Float.leastNormalMagnitude {
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
        if abs(dot(d1, n)) > Float.leastNormalMagnitude {
            // 点与三角形不共面
            return nil
        }
        let an = dot(cross(e1, e2), n)
        if an < Float.leastNormalMagnitude {
            return nil
        }
        let b1 = dot(cross(e1, d3), n) / an
        let b2 = dot(cross(e2, d1), n) / an
        let b3 = dot(cross(e3, d2), n) / an
        return simd_float3(b1, b2, b3)
    }
    ///点到三角形的最近点坐标
    static func nearestPoint(point:simd_float3, triangle:Triangle) -> simd_float3? {
        return nil
    }
    ///射线与三角形相交，重心坐标
    static func intersectionPointBarycenricCoordinate(ray:Ray, triangle:Triangle) -> simd_float3? {
        return nil
    }
}

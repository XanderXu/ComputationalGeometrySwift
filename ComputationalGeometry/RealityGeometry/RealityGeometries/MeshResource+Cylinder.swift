//
//  MeshResource+Cylinder.swift
//  
//
//  Created by Max Cobb on 12/06/2021.
//

import RealityKit

extension MeshResource {
    fileprivate static func cylinderIndices(
        _ sides: Int, _ lowerCenterIndex: UInt32,
        _ upperCenterIndex: UInt32, _ splitFaces: Bool, _ smoothNormals: Bool
    ) -> ([UInt32], [UInt32]) {
        var indices: [UInt32] = []
        var materialIndices: [UInt32] = []
        let uiSides = UInt32(sides) * (smoothNormals ? 1 : 2)
        for side in 0..<sides {
            let uiSide = UInt32(side) * (smoothNormals ? 1 : 2)
            let bottomLeft = uiSide
            let bottomRight = uiSide + 1
            let topLeft = uiSide + uiSides + 1
            let topRight = uiSide + uiSides + 2

            // First triangle of side
            indices.append(contentsOf: [bottomLeft, topRight, bottomRight])

            // Second triangle of side
            indices.append(contentsOf: [bottomLeft, topLeft, topRight])

            // Add bottom cap triangle
            indices.append(contentsOf: [0, UInt32(side) + 1, UInt32(side) + 2].map { $0 + lowerCenterIndex })

            // Add top cap triangle
            indices.append(contentsOf: [0, UInt32(side) + 2, UInt32(side) + 1].map { $0 + upperCenterIndex })
            if splitFaces {
                materialIndices.append(0)
                materialIndices.append(0)
                materialIndices.append(1)
                materialIndices.append(2)
            }
        }
        return (indices, materialIndices)
    }

    fileprivate struct CylinderVertices {
        var lowerEdge: [CompleteVertex]
        var upperEdge: [CompleteVertex]
        var lowerCap: [CompleteVertex]
        var upperCap: [CompleteVertex]
        var combinedVerts: [CompleteVertex]?
        var indices: [UInt32]?
        var materialIndices: [UInt32]?
        var smoothNormals: Bool
        mutating func calculateCylinderDetails(height: Float, sides: Int, splitFaces: Bool) -> Bool {
            let halfHeight = height / 2
            var combinedVerts: [CompleteVertex] = lowerEdge
            combinedVerts.append(contentsOf: upperEdge)

            let lowerCenterIndex = UInt32(combinedVerts.count)
            combinedVerts.append(CompleteVertex(
                position: [0, -halfHeight, 0], normal: [0, -1, 0], uv: [0.5, 0.5]
            ))

            combinedVerts.append(contentsOf: lowerCap)
            let upperCenterIndex = UInt32(combinedVerts.count)
            combinedVerts.append(CompleteVertex(
                position: [0, halfHeight, 0], normal: [0, 1, 0], uv: [0.5, 0.5]
            ))
            combinedVerts.append(contentsOf: upperCap)
            self.combinedVerts = combinedVerts
            (self.indices, self.materialIndices) = cylinderIndices(
                sides, lowerCenterIndex, upperCenterIndex, splitFaces, self.smoothNormals
            )
            return true
        }
    }

    fileprivate static func cylinderVertices(
        _ sides: Int, _ radius: Float, _ height: Float, _ smoothNormals: Bool = false
    ) -> CylinderVertices {
        var theta: Float = 0
        let thetaInc = 2 * .pi / Float(sides)
        let uStep: Float = 1 / Float(sides)
        // first vertices added will be bottom edges
        var vertices = [CompleteVertex]()
        // all top edge vertices of the cylinder
        var upperEdgeVertices = [CompleteVertex]()
        // bottom edge vertices
        var lowerCapVertices = [CompleteVertex]()
        // top edge vertices
        var upperCapVertices = [CompleteVertex]()

        // create vertices for all sides of the cylinder
        for side in 0...sides {
            let cosTheta = cos(theta); let sinTheta = sin(theta)

            let lowerPosition: SIMD3<Float> = [radius * cosTheta, -height / 2, radius * sinTheta]
            if side != 0, !smoothNormals {
                vertices.append(CompleteVertex(
                    position: lowerPosition,
                    normal: [cos(theta - thetaInc / 2), 0, sin(theta - thetaInc / 2)],
                    uv: [uStep * Float(side), 0]
                ))
            }

            let bottomVertex = CompleteVertex(
                position: lowerPosition,
                normal: [
                    cos(theta + (smoothNormals ? 0 : thetaInc / 2)), 0,
                    sin(theta + (smoothNormals ? 0 : thetaInc / 2))
                ], uv: [uStep * Float(side), 0]
            )

            // add vertex for bottom side of cylinder, facing out
            vertices.append(bottomVertex)

            // add vertex for bottom side facing down
            lowerCapVertices.append(CompleteVertex(
                position: bottomVertex.position,
                normal: [0, -1, 0], uv: [cosTheta + 1, sinTheta + 1] / 2)
            )

            if side != 0, !smoothNormals {
                upperEdgeVertices.append(CompleteVertex(
                    position: lowerPosition + [0, height, 0],
                    normal: [cos(theta - thetaInc / 2), 0, sin(theta - thetaInc / 2)],
                    uv: [uStep * Float(side), 1]
                ))
            }

            // add vertex for top side facing out
            let topVertex = CompleteVertex(
                position: lowerPosition + [0, height, 0],
                normal: bottomVertex.normal, uv: [uStep * Float(side), 1]
            )
            upperEdgeVertices.append(topVertex)

            upperCapVertices.append(CompleteVertex(
                position: topVertex.position, normal: [0, 1, 0], uv: [cosTheta + 1, sinTheta + 1] / 2)
            )

            theta += thetaInc
        }
        return CylinderVertices(
            lowerEdge: vertices, upperEdge: upperEdgeVertices, lowerCap: lowerCapVertices,
            upperCap: upperCapVertices, smoothNormals: smoothNormals
        )
    }

    /// Creates a new cylinder mesh with the specified values
    /// - Parameters:
    ///   - radius: Radius of the cylinder
    ///   - height: Height of the cylinder
    ///   - sides: How many sides the cone should have, default is 24, minimum is 3
    ///   - splitFaces: A Boolean you set to true to indicate that vertices shouldn’t be merged.
    ///   - smoothNormals: Whether to smooth the normals. Good for high numbers of sides to give a rounder shape.
    ///                    Smoothed normal setting also reduces the total number of vertices
    /// - Returns: A cylinder mesh.
    public static func generateCylinder(
        radius: Float, height: Float, sides: Int = 24,
        splitFaces: Bool = false, smoothNormals: Bool = false
    ) throws -> MeshResource {
        assert(sides > 2, "Sides must be an integer above 2")

        // first vertices added to vertices will be bottom edges
        // upperEdgeVertices are all top edge vertices of the cylinder
        // lowerCapVertices are the bottom edge vertices
        // upperCapVertices are the top edge vertices
        var cylinderVerts = cylinderVertices(sides, radius, height, smoothNormals)
        if !cylinderVerts.calculateCylinderDetails(
            height: height, sides: sides, splitFaces: splitFaces
        ) {
            assertionFailure("Cannot calculate cylinder")
        }
        let meshDescr = cylinderVerts.combinedVerts!.generateMeshDescriptor(
            with: cylinderVerts.indices!, materials: cylinderVerts.materialIndices!
        )
        return try MeshResource.generate(from: [meshDescr])
    }
}

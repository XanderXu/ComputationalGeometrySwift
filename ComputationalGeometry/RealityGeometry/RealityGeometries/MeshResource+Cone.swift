//
//  MeshResource+Cone.swift
//  
//
//  Created by Max Cobb on 12/06/2021.
//

import RealityKit

extension MeshResource {
    fileprivate static func coneIndices(
        _ sides: Int, _ lowerCenterIndex: UInt32, _ splitFaces: Bool,
        _ smoothNormals: Bool
    ) -> ([UInt32], [UInt32]) {
        var indices: [UInt32] = []
        var materialIndices: [UInt32] = []
        let uiSides = UInt32(sides) * (smoothNormals ? 1 : 2)
        for side in 0..<UInt32(sides) {
            let uiSideSmooth = side * (smoothNormals ? 1 : 2)
            let bottomLeft = uiSideSmooth
            let bottomRight = uiSideSmooth + 1
            let topVertex = side + uiSides + 1

            // First triangle of side
            indices.append(contentsOf: [bottomLeft, topVertex, bottomRight])

            // Add bottom cap triangle
            indices.append(contentsOf: [0, side + 1, side + 2].map { $0 + lowerCenterIndex })

            if splitFaces {
                materialIndices.append(0)
                materialIndices.append(1)
            }
        }
        return (indices, materialIndices)
    }

    fileprivate struct ConeVertices {
        var lowerEdge: [CompleteVertex]
        var upperEdge: [CompleteVertex]
        var lowerCap: [CompleteVertex]
        var combinedVerts: [CompleteVertex]?
        var indices: [UInt32]?
        var materialIndices: [UInt32]?
        var smoothNormals: Bool

        mutating func calculateDetails(
            height: Float, sides: Int, splitFaces: Bool
        ) -> Bool {
            let halfHeight = height / 2
            var vertices = lowerEdge
            print(lowerEdge.count)
            vertices.append(contentsOf: upperEdge)

            let lowerCenterIndex = UInt32(vertices.count)
            vertices.append(CompleteVertex(
                position: [0, -halfHeight, 0], normal: [0, -1, 0], uv: [0.5, 0.5]
            ))

            vertices.append(contentsOf: lowerCap)
            self.combinedVerts = vertices
            (self.indices, self.materialIndices) = coneIndices(
                sides, lowerCenterIndex, splitFaces, self.smoothNormals
            )
            return true
        }
    }

    fileprivate static func coneVertices(
        _ sides: Int, _ radius: Float, _ height: Float, _ smoothNormals: Bool = false
    ) -> ConeVertices {
        var theta: Float = 0
        let thetaInc = 2 * .pi / Float(sides)
        let uStep: Float = 1 / Float(sides)
        // first vertices added will be bottom edges
        var vertices = [CompleteVertex]()
        // all top edge vertices of the cylinder
        var upperEdgeVertices = [CompleteVertex]()
        // bottom edge vertices
        var lowerCapVertices = [CompleteVertex]()

        let hyp = sqrtf(radius * radius + height * height)
        let coneNormX = radius / hyp
        let coneNormY = height / hyp
        // create vertices for all sides of the cylinder
        for side in 0...sides {
            let cosTheta = cos(theta)
            let sinTheta = sin(theta)

            let lowerPosition: SIMD3<Float> = [radius * cosTheta, -height / 2, radius * sinTheta]
            let coneBottomNormal: SIMD3<Float> = [coneNormY * cosTheta, coneNormX, coneNormY * sinTheta]

            if side != 0, !smoothNormals {
                vertices.append(CompleteVertex(
                    position: lowerPosition,
                    normal: [coneNormY * cos(theta - thetaInc / 2), coneNormX, coneNormY * sin(theta - thetaInc / 2)],
                    uv: [1 - uStep * Float(side), 0]
                ))
            }

            let bottomVertex = CompleteVertex(
                position: lowerPosition,
                normal: smoothNormals ? coneBottomNormal : [
                    coneNormY * cos(theta + thetaInc / 2), coneNormX, coneNormY * sin(theta + thetaInc / 2)
                ],
                uv: [1 - uStep * Float(side), 0]
            )

            // add vertex for bottom side of cone
            vertices.append(bottomVertex)

            // add vertex for bottom side facing down
            lowerCapVertices.append(CompleteVertex(
                position: bottomVertex.position,
                normal: [0, -1, 0], uv: [cosTheta + 1, sinTheta + 1] / 2)
            )

            let coneTopNormal: SIMD3<Float> = [
                coneNormY * cos(theta + thetaInc / 2), coneNormX,
                coneNormY * sin(theta + thetaInc / 2)
            ]

            // add vertex for top of the cone
            let topVertex = CompleteVertex(
                position: [0, height / 2, 0],
                normal: coneTopNormal, uv: [1 - uStep * (Float(side) + 0.5), 1]
            )
            upperEdgeVertices.append(topVertex)

            theta += thetaInc
        }
        return .init(
            lowerEdge: vertices, upperEdge: upperEdgeVertices, lowerCap: lowerCapVertices, smoothNormals: smoothNormals
        )
    }

    /// Creates a new cone mesh with the specified values 🍦
    /// - Parameters:
    ///   - radius: Radius of the code base
    ///   - height: Height of the code from base to tip
    ///   - sides: How many sides the cone should have, default is 24, minimum is 3
    ///   - splitFaces: A Boolean you set to true to indicate that vertices shouldn’t be merged.
    ///   - smoothNormals: Whether to smooth the normals. Good for high numbers of sides to give a rounder shape.
    ///                    Smoothed normal setting also reduces the total number of vertices
    /// - Returns: A cone mesh
    public static func generateCone(
        radius: Float, height: Float, sides: Int = 24, splitFaces: Bool = false,
        smoothNormals: Bool = false
    ) throws -> MeshResource {
        assert(sides > 2, "Sides must be an integer above 2")
        // first vertices added to vertices will be bottom edges
        // upperEdgeVertices are all top edge vertices of the cylinder
        // lowerCapVertices are the bottom edge vertices
        var coneVerties = coneVertices(sides, radius, height, smoothNormals)
        if !coneVerties.calculateDetails(
            height: height, sides: sides, splitFaces: splitFaces
        ) {
            assertionFailure("Could not calculate cone")
        }
        let meshDescr = coneVerties.combinedVerts!.generateMeshDescriptor(
            with: coneVerties.indices!, materials: coneVerties.materialIndices!
        )
        return try MeshResource.generate(from: [meshDescr])
    }
    
    public static func generateCone(
        radius: Float, height: Float, angularResolution: Int = 24, radialResolution: Int = 1, verticalResolution: Int = 1, splitFaces: Bool = false, smoothNormals: Bool = false) throws -> MeshResource {
            var descr = MeshDescriptor()
            var meshPositions: [SIMD3<Float>] = []
            var indices: [UInt32] = []
            var normals: [SIMD3<Float>] = []
            var textureMap: [SIMD2<Float>] = []
            var materials: [UInt32] = []
            
            let vertical = verticalResolution > 0 ? verticalResolution : 1
            let angular = angularResolution > 2 ? angularResolution : 3
            let radial = radialResolution > 0 ? radialResolution : 1

            let verticalf = Float(vertical)
            let angularf = Float(angular)
            let radialf = Float(radial)

            let angularInc = (2.0 * .pi) / angularf
            let verticalInc = height / verticalf
            let radialInc = radius / radialf
            let radiusInc = radius / verticalf

            let yOffset = -0.5 * height
            let perLoop = angular + 1
            let verticesPerWall = perLoop * (vertical + 1)
            
            let hyp = sqrtf(radius * radius + height * height)
            let coneNormX = radius / hyp
            let coneNormY = height / hyp
            
            for v in 0...vertical {
                let vf = Float(v)
                let y = yOffset + vf * verticalInc
                let rad = radius - vf * radiusInc
                
                for a in 0...angular {
                    let af = Float(a)
                    let angle = af * angularInc
                    
                    let cosAngle = cos(angle)
                    let sinAngle = sin(angle)
                    
                    let x = rad * cosAngle
                    let z = rad * sinAngle
                    
                    let coneBottomNormal: SIMD3<Float> = [coneNormY * cosAngle, coneNormX, coneNormY * sinAngle]
                    
                    meshPositions.append(SIMD3<Float>(x, y, z))
                    normals.append(normalize(coneBottomNormal))
                    textureMap.append(SIMD2<Float>(1 - af / angularf, vf / verticalf))
                    
                    if (v != vertical && a != angular) {
                        let index = a + v * perLoop

                        let tl = UInt32(index)
                        let tr = tl + 1
                        let bl = UInt32(index + perLoop)
                        let br = bl + 1

                        indices.append(contentsOf: [tl, bl, tr,
                                                    tr, bl, br
                        ])
                        if splitFaces {
                            materials.append(contentsOf: [0, 0])
                        }
                    }
                }
            }
            
            for r in 0...radial {
                let rf = Float(r)
                let rad = rf * radialInc
                
                for a in 0...angular {
                    let af = Float(a)
                    let angle = af * angularInc
                    let x = rad * cos(angle)
                    let y = rad * sin(angle)
                    
                    meshPositions.append(SIMD3<Float>(x, -height * 0.5, y))
                    normals.append(SIMD3<Float>(0, -1, 0))
                    textureMap.append(SIMD2<Float>(af / angularf, 1 - rf / radialf))
                    
                    if (r != radial && a != angular) {
                        let index = verticesPerWall + a + r * perLoop;

                        let tl = UInt32(index)
                        let tr = tl + 1
                        let bl = UInt32(index + perLoop)
                        let br = bl + 1

                        indices.append(contentsOf: [tl, bl, tr,
                                                    tr, bl, br
                        ])
                        if splitFaces {
                            materials.append(contentsOf: [1, 1])
                        }
                    }
                }
            }
            
            descr.positions = MeshBuffers.Positions(meshPositions)
            descr.normals = MeshBuffers.Normals(normals)
            descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
            descr.primitives = .triangles(indices)
            if !materials.isEmpty {
                descr.materials = MeshDescriptor.Materials.perFace(materials)
            }
        return try MeshResource.generate(from: [descr])
    }
}

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
SVD function.
*/

import Accelerate

extension Matrix {
    
    /// Returns the singular value decomposition (SVD) of matrix _A_.
    ///
    /// The SVD is the factorization of the supplied matrix, _A_, into _U_, _Σ_, and _Vᵀ_:
    ///
    ///     a = u * sigma * vᵀ
    ///
    /// The SVD returns as a tuple that contains `u`, `sigma`, and `vᵀ`.
    public static func svd(a: Matrix) -> (u: Matrix,
                                          sigma: Matrix,
                                          vt: Matrix) {
        /// The _U_ in _A = U * Σ * Vᵀ_.
        var u = Matrix(rowCount: a.rowCount,
                       columnCount: a.rowCount)
        
        /// The diagonal values of _Σ_ in _A = U * Σ * Vᵀ_.
        var sigma = Matrix(rowCount: 1,
                           columnCount: min(a.columnCount, a.rowCount))
        
        /// The _Vᵀ_ in _A = U * Σ * Vᵀ_.
        var vt = Matrix(rowCount: a.columnCount,
                        columnCount: a.columnCount )
        
        // The "A" option computes all `m` columns of `u` and all `n` rows of
        // `vᵀ`.
        let options = Int8("A".utf8.first!)
        
        var workspaces = (work: [Float](),
                          iwork: [Int32]())
        
        gesddWrapper(a: a,
                     sigma: &sigma,
                     u: &u,
                     options: options,
                     vt: &vt,
                     workspaces: &workspaces)
        
        return (u, sigma, vt)
    }
    
    private static func gesddWrapper(a: Matrix,
                                     sigma: inout Matrix,
                                     u: inout Matrix,
                                     options: Int8,
                                     vt: inout Matrix,
                                     workspaces: inout(work: [Float],
                                                       iwork: [Int32])) {
        
        precondition(sigma.m == 1 && sigma.n == min(a.n, a.m),
                     "`sigma` row and column count must be the same as `a` row and column count.")
        precondition(vt.m == a.n && vt.n == a.n,
                     "`vt` row and column count must be the same as `a` column count.")
        
        var info = Int32(0)
        
        var m = a.m
        var lda = a.m
        var n = a.n
        
        var ldu = u.m
        var ldvt = vt.m
        
        var jobz = options
        
        if workspaces.iwork.isEmpty {
            workspaces.iwork = [Int32](repeating: 0,
                                       count: 8 * a.minimumDimension)
        }
        
        if workspaces.work.isEmpty {
            var minusOne = Int32(-1)
            
            var workDimension: Float = 0
            
            // Workspace query that computes the workspace size by passing
            // `-1` to `__lwork`.
            sgesdd_(&jobz,
                    &m, &n, a.data.baseAddress, &lda,
                    sigma.data.baseAddress,
                    u.data.baseAddress, &ldu,
                    vt.data.baseAddress, &ldvt,
                    &workDimension, &minusOne, &workspaces.iwork,
                    &info)
            
            var lwork = Int32(workDimension)
            
            workspaces.work = [Float](unsafeUninitializedCapacity: Int(workDimension)) {
                buffer, initializedCount in
                
                // Call to `sgesdd_` with a positive `lwork` value that
                // computes the SVD and writes the result to `sigma`, `u`, and
                // `vt` matrices.
                sgesdd_(&jobz,
                        &m, &n, a.data.baseAddress, &lda,
                        sigma.data.baseAddress,
                        u.data.baseAddress, &ldu,
                        vt.data.baseAddress, &ldvt,
                        buffer.baseAddress, &lwork, &workspaces.iwork,
                        &info)
                
                initializedCount = Int(workDimension)
            }
        } else {
            var lwork = Int32(workspaces.work.count)
            
            sgesdd_(&jobz,
                    &m, &n, a.data.baseAddress, &lda,
                    sigma.data.baseAddress,
                    u.data.baseAddress, &ldu,
                    vt.data.baseAddress, &ldvt,
                    &workspaces.work, &lwork,
                    &workspaces.iwork,
                    &info)
        }
        
        if info < 0 {
            fatalError("`sgesdd_` info = \(info)")
        } else if info > 0 {
            fatalError("algorithmDidNotConverge")
        }
    }
    
}

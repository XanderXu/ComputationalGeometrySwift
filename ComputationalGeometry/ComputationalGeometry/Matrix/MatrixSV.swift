//
//  MatrixSV.swift
//  ComputationalGeometry
//
//  Created by CoderXu on 2021/4/10.
//

import Foundation
import Accelerate

extension Matrix {
    /// 方程组求解，a为系数矩阵，b 为结果（可多组），返回值实际存储在 b 中
    public static func sv(a:Matrix,b:Matrix) -> Matrix {
        //info = 0, 程序正常运行结束。
        var info = Int32(0)
        //矩阵的size，系数矩阵应该是方阵，一个5x5的矩阵，则n=5；
        var n = a.n
        //rhs的列数，LAPACK可以同时对一个系数矩阵，多个rhs进行求解，因为对系数矩阵只需要进行一次LU分解，多个rhs一起求解更方便；
        var nrhs = Int32(b.n)
        //leading dimension of a，lda>=max(1,n)；
        var lda = n
        //leading dimension of b, ldb>=max(1,n)
        var ldb = n
        //pivot的行交换记录，第i行被交换到第ipiv[i]行；
        var ipiv = Array(repeating: Int32(0), count: Int(n))
        //求解后的结果存储在 b 中
        sgesv_(&n, &nrhs, a.data.baseAddress, &lda, &ipiv, b.data.baseAddress, &ldb, &info)
        
        if info < 0 {
            fatalError("`sgesv_` info = \(info)")
        } else if info > 0 {
            fatalError("algorithmDidNotConverge")
        }
        return b
    }
}

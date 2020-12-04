/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Simple matrix class.
*/

import Accelerate

/// A basic single-precision matrix object.
public struct Matrix {
    /// The number of rows in the matrix.
    public let rowCount: Int
    
    /// The number of columns in the matrix.
    public let columnCount: Int
    
    /// A pointer to the matrix's underlying data.
    public var data: UnsafeMutableBufferPointer<Float> {
        get {
            return dataRef.data
        }
        set {
            dataRef.data = newValue
        }
    }
    
    /// Returns a new matrix using the specified buffer pointer.
    fileprivate init(data: UnsafeMutableBufferPointer<Float>,
                     rowCount: Int,
                     columnCount: Int) {
        
        precondition(data.count == rowCount * columnCount,
                     "The number of elements in `data` must equal `rowCount * columnCount`.")
        
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.dataRef = MatrixDataRef(data: data)
    }
    
    /// A pointer to the matrix's underlying data reference.
    private var dataRef: MatrixDataRef
    
    /// An object that wraps the structure's data and provides deallocation when the code releases the structure.
    private class MatrixDataRef {
        var data: UnsafeMutableBufferPointer<Float>
        
        init(data: UnsafeMutableBufferPointer<Float>) {
            self.data = data
        }
        
        deinit {
            self.data.deallocate()
        }
    }
}

/// Properties for BLAS and LAPACK interoperability.
extension Matrix {
    /// The number of rows as a 32-bit integer.
    public var m: Int32 {
        return Int32(rowCount)
    }
    
    /// The number of columns as a 32-bit integer.
    public var n: Int32 {
        return Int32(columnCount)
    }
    
    /// The minimum dimension of the matrix.
    public var minimumDimension: Int {
        return min(rowCount, columnCount)
    }
}

/// Static allocation functions.
extension Matrix {
    /// Returns a matrix with the specified vImage buffer.
    public init(imageBuffer buffer: vImage_Buffer) {
        let count = Int(buffer.width * buffer.height)
        
        let pixelsPointer = buffer.data.assumingMemoryBound(to: Pixel_8.self)
        
        let floatPixels = vDSP.integerToFloatingPoint(
            UnsafeMutableBufferPointer(start: pixelsPointer,
                                       count: count),
            floatingPointType: Float.self)
        
        let rowCount = Int(buffer.height)
        let columnCount = Int(buffer.width)
        
        self.init(source: floatPixels,
                  rowCount: rowCount,
                  columnCount: columnCount)
    }
    
    /// Returns a matrix with the specified elements.
    public init<C>(source: C,
                   rowCount: Int,
                   columnCount: Int)
    where
        C: Collection,
        C.Element == Float {
        
        precondition(source.count == rowCount * columnCount,
                     "The source collection must contain `rowCount * columnCount` elements.")
        
        let x = UnsafeMutablePointer<C.Element>.allocate(capacity: source.count)
        
        let buffer = UnsafeMutableBufferPointer(start: x,
                                                count: source.count)
        let (_, endIndex) = buffer.initialize(from: source)
        
        precondition(endIndex == buffer.endIndex,
                     "The collection has fewer elements than required to initialize the array.")
        
        self.init(data: buffer,
                  rowCount: rowCount,
                  columnCount: columnCount)
    }
    
    /// Returns a zero-filled matrix.
    public init(rowCount: Int,
                columnCount: Int) {
        
        let count = rowCount * columnCount
        
        let start = UnsafeMutablePointer<Float>.allocate(capacity: count)
        
        let buffer = UnsafeMutableBufferPointer(start: start,
                                                count: count)
        buffer.initialize(repeating: 0)
        
        self.init(data: buffer,
                  rowCount: rowCount,
                  columnCount: columnCount)
    }
    
    /// Returns a column-major matrix with the specified diagonal elements.
    public init<C>(diagonal: C,
                   rowCount: Int,
                   columnCount: Int)
    where
        C: Collection,
        C.Index == Int,
        C.Element == Float {
        
        self.init(rowCount: rowCount,
                  columnCount: columnCount)
        
        for i in 0 ..< min(rowCount, columnCount, diagonal.count) {
            self[i * rowCount + i] = diagonal[i]
        }
    }
}

/// Subscript access
extension Matrix {
    /// Accesses the element at the specified index.
    public subscript(index: Int) -> Float {
        get {
            assert(index < dataRef.data.count, "Index out of range")
            return dataRef.data[index]
        }
        set {
            assert(index < dataRef.data.count, "Index out of range")
            dataRef.data[index] = newValue
        }
    }
    
    private func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rowCount && column >= 0 && column < columnCount
    }
    
    /// Accesses the element at the specified row and column.
    public subscript(row: Int, column: Int) -> Float {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return dataRef.data[(row * columnCount) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            dataRef.data[(row * columnCount) + column] = newValue
        }
    }
}

extension Matrix: CustomStringConvertible {
    /// A textual representation of this instance.
    public var description: String {
        var returnString = ""
        for y in 0 ..< columnCount {
            var str = ""
            for x in 0 ..< rowCount {
                str += String(format: "%.2f ", self[x, y])
            }
            returnString += str + "\n"
        }
        return returnString
    }
}

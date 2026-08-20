///|
pub struct DenseMatrix {
  data : Array[Array[Double]]
}

///|
pub struct MatrixStats {
  rows : Int
  columns : Int
  non_zero : Int
  frobenius_norm : Double
  max_abs : Double
}

///|
pub fn DenseMatrix::from_rows(rows : Array[Array[Double]]) -> DenseMatrix {
  let copy : Array[Array[Double]] = []
  for row in rows {
    copy.push(row.map(fn(value) { value }))
  }
  { data: copy }
}

///|
pub fn DenseMatrix::zeros(rows : Int, columns : Int) -> DenseMatrix {
  let data : Array[Array[Double]] = []
  for _ in 0..<rows {
    data.push(Array::make(columns, 0.0))
  }
  { data, }
}

///|
pub fn DenseMatrix::identity(size : Int) -> DenseMatrix {
  let matrix = DenseMatrix::zeros(size, size)
  for index in 0..<size {
    matrix.data[index][index] = 1.0
  }
  matrix
}

///|
pub fn DenseMatrix::rows(self : DenseMatrix) -> Array[Array[Double]] {
  self.data.map(fn(row) { row.map(fn(value) { value }) })
}

///|
pub fn DenseMatrix::row_count(self : DenseMatrix) -> Int {
  self.data.length()
}

///|
pub fn DenseMatrix::column_count(self : DenseMatrix) -> Int {
  if self.data.is_empty() {
    0
  } else {
    self.data[0].length()
  }
}

///|
pub fn DenseMatrix::get(self : DenseMatrix, row : Int, column : Int) -> Double {
  self.data[row][column]
}

///|
pub fn DenseMatrix::set(
  self : DenseMatrix,
  row : Int,
  column : Int,
  value : Double,
) -> Unit {
  self.data[row][column] = value
}

///|
pub fn DenseMatrix::add(self : DenseMatrix, other : DenseMatrix) -> DenseMatrix {
  let result = DenseMatrix::zeros(self.row_count(), self.column_count())
  for row in 0..<self.row_count() {
    for column in 0..<self.column_count() {
      result.data[row][column] = self.data[row][column] +
        other.data[row][column]
    }
  }
  result
}

///|
pub fn DenseMatrix::scale(self : DenseMatrix, factor : Double) -> DenseMatrix {
  let result = DenseMatrix::zeros(self.row_count(), self.column_count())
  for row in 0..<self.row_count() {
    for column in 0..<self.column_count() {
      result.data[row][column] = self.data[row][column] * factor
    }
  }
  result
}

///|
pub fn DenseMatrix::transpose(self : DenseMatrix) -> DenseMatrix {
  let result = DenseMatrix::zeros(self.column_count(), self.row_count())
  for row in 0..<self.row_count() {
    for column in 0..<self.column_count() {
      result.data[column][row] = self.data[row][column]
    }
  }
  result
}

///|
pub fn DenseMatrix::multiply_vector(
  self : DenseMatrix,
  vector : Array[Double],
) -> Array[Double] {
  let output = Array::make(self.row_count(), 0.0)
  for row in 0..<self.row_count() {
    for column in 0..<self.column_count() {
      output[row] = output[row] + self.data[row][column] * vector[column]
    }
  }
  output
}

///|
pub fn DenseMatrix::residual(
  self : DenseMatrix,
  solution : Array[Double],
  rhs : Array[Double],
) -> Double {
  let product = self.multiply_vector(solution)
  let mut largest = 0.0
  for index in 0..<product.length() {
    let error = (product[index] - rhs[index]).abs()
    if error > largest {
      largest = error
    }
  }
  largest
}

///|
pub fn DenseMatrix::stats(self : DenseMatrix) -> MatrixStats {
  let mut non_zero = 0
  let mut square_sum = 0.0
  let mut max_abs = 0.0
  for row in self.data {
    for value in row {
      if value != 0.0 {
        non_zero = non_zero + 1
      }
      square_sum = square_sum + value * value
      if value.abs() > max_abs {
        max_abs = value.abs()
      }
    }
  }
  {
    rows: self.row_count(),
    columns: self.column_count(),
    non_zero,
    frobenius_norm: square_sum.sqrt(),
    max_abs,
  }
}

///|
pub fn DenseMatrix::is_square(self : DenseMatrix) -> Bool {
  self.row_count() == self.column_count()
}

///|
pub fn DenseMatrix::is_symmetric(
  self : DenseMatrix,
  tolerance? : Double = 1.0e-12,
) -> Bool {
  if !self.is_square() {
    return false
  }
  for row in 0..<self.row_count() {
    for column in row..<self.column_count() {
      if (self.data[row][column] - self.data[column][row]).abs() > tolerance {
        return false
      }
    }
  }
  true
}

///|
pub fn DenseMatrix::diagonal(self : DenseMatrix) -> Array[Double] {
  let result : Array[Double] = []
  let size = if self.row_count() < self.column_count() {
    self.row_count()
  } else {
    self.column_count()
  }
  for index in 0..<size {
    result.push(self.data[index][index])
  }
  result
}

///|
pub fn DenseMatrix::trace(self : DenseMatrix) -> Double {
  self.diagonal().fold(init=0.0, fn(total, value) { total + value })
}

///|
pub fn DenseMatrix::map(
  self : DenseMatrix,
  transform : (Double) -> Double,
) -> DenseMatrix {
  DenseMatrix::from_rows(self.data.map(fn(row) { row.map(transform) }))
}

///|
pub fn DenseMatrix::clamp(
  self : DenseMatrix,
  low : Double,
  high : Double,
) -> DenseMatrix {
  self.map(fn(value) {
    if value < low {
      low
    } else if value > high {
      high
    } else {
      value
    }
  })
}

///|
pub fn DenseMatrix::to_csv(self : DenseMatrix) -> String {
  let output = StringBuilder::new()
  for row in self.data {
    for column, value in row {
      if column > 0 {
        output.write_char(',')
      }
      output.write_string(value.to_string())
    }
    output.write_char('\n')
  }
  output.to_string()
}

///|
pub fn DenseMatrix::flatten(self : DenseMatrix) -> Array[Double] {
  let output : Array[Double] = []
  for row in self.data {
    for value in row {
      output.push(value)
    }
  }
  output
}

///|
pub fn matrix_vector_dot(left : Array[Double], right : Array[Double]) -> Double {
  let mut total = 0.0
  let size = if left.length() < right.length() {
    left.length()
  } else {
    right.length()
  }
  for index in 0..<size {
    total = total + left[index] * right[index]
  }
  total
}

///|
pub fn vector_norm(vector : Array[Double]) -> Double {
  matrix_vector_dot(vector, vector).sqrt()
}

///|
pub fn vector_distance(left : Array[Double], right : Array[Double]) -> Double {
  let mut total = 0.0
  let size = if left.length() < right.length() {
    left.length()
  } else {
    right.length()
  }
  for index in 0..<size {
    let delta = left[index] - right[index]
    total = total + delta * delta
  }
  total.sqrt()
}

///|
pub fn vector_sum(vector : Array[Double]) -> Double {
  vector.fold(init=0.0, fn(total, value) { total + value })
}

///|
pub fn vector_mean(vector : Array[Double]) -> Double {
  if vector.is_empty() {
    0.0
  } else {
    vector_sum(vector) / vector.length().to_double()
  }
}

///|
pub fn vector_min(vector : Array[Double]) -> Double {
  if vector.is_empty() {
    0.0
  } else {
    let mut result = vector[0]
    for value in vector {
      if value < result {
        result = value
      }
    }
    result
  }
}

///|
pub fn vector_max(vector : Array[Double]) -> Double {
  if vector.is_empty() {
    0.0
  } else {
    let mut result = vector[0]
    for value in vector {
      if value > result {
        result = value
      }
    }
    result
  }
}

///|
pub struct SweepPoint {
  parameter : Double
  value : Double
}

///|
pub fn sweep_linear(
  start : Double,
  stop : Double,
  step : Double,
) -> Array[Double] {
  if step == 0.0 {
    return []
  }
  let values : Array[Double] = []
  let mut value = start
  let direction = if stop >= start { 1.0 } else { -1.0 }
  let stride = step.abs() * direction
  let mut limit = 0
  while limit < 100000 &&
        (
          (direction > 0.0 && value <= stop) ||
          (direction < 0.0 && value >= stop)
        ) {
    values.push(value)
    value = value + stride
    limit = limit + 1
  }
  values
}

///|
pub fn sweep_map(
  values : Array[Double],
  transform : (Double) -> Double,
) -> Array[Double] {
  values.map(transform)
}

///|
pub fn sweep_points(
  values : Array[Double],
  transform : (Double) -> Double,
) -> Array[SweepPoint] {
  values.map(fn(parameter) { { parameter, value: transform(parameter) } })
}

///|
pub fn sweep_minimum(points : Array[SweepPoint]) -> SweepPoint? {
  if points.is_empty() {
    None
  } else {
    let mut result = points[0]
    for point in points {
      if point.value < result.value {
        result = point
      }
    }
    Some(result)
  }
}

///|
pub fn sweep_maximum(points : Array[SweepPoint]) -> SweepPoint? {
  if points.is_empty() {
    None
  } else {
    let mut result = points[0]
    for point in points {
      if point.value > result.value {
        result = point
      }
    }
    Some(result)
  }
}

///|
pub fn sweep_average(points : Array[SweepPoint]) -> Double {
  if points.is_empty() {
    0.0
  } else {
    points
    .map(fn(point) { point.value })
    .fold(init=0.0, fn(total, value) { total + value }) /
    points.length().to_double()
  }
}

///|
pub fn sweep_range(points : Array[SweepPoint]) -> Double {
  match (sweep_minimum(points), sweep_maximum(points)) {
    (Some(low), Some(high)) => high.value - low.value
    _ => 0.0
  }
}

///|
pub fn sweep_interpolate(
  points : Array[SweepPoint],
  parameter : Double,
) -> Double {
  if points.is_empty() {
    return 0.0
  }
  if parameter <= points[0].parameter {
    return points[0].value
  }
  for index in 1..<points.length() {
    let left = points[index - 1]
    let right = points[index]
    if parameter <= right.parameter {
      let span = right.parameter - left.parameter
      if span == 0.0 {
        return right.value
      }
      let ratio = (parameter - left.parameter) / span
      return left.value + ratio * (right.value - left.value)
    }
  }
  points[points.length() - 1].value
}

///|
pub fn sweep_filter(
  points : Array[SweepPoint],
  predicate : (SweepPoint) -> Bool,
) -> Array[SweepPoint] {
  points.filter(predicate)
}

///|
pub fn sweep_scale(
  points : Array[SweepPoint],
  factor : Double,
) -> Array[SweepPoint] {
  points.map(fn(point) {
    { parameter: point.parameter, value: point.value * factor }
  })
}

///|
pub fn sweep_to_csv(points : Array[SweepPoint]) -> String {
  let output = StringBuilder::new()
  output.write_string("parameter,value\n")
  for point in points {
    output.write_string(point.parameter.to_string())
    output.write_char(',')
    output.write_string(point.value.to_string())
    output.write_char('\n')
  }
  output.to_string()
}

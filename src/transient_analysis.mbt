///|
pub struct TimeSample {
  time : Double
  values : Array[Double]
}

///|
pub struct TransientSeries {
  samples : Array[TimeSample]
  step : Double
  stop : Double
}

///|
pub fn time_grid(
  start : Double,
  stop : Double,
  step : Double,
) -> Array[Double] raise SpiceError {
  if step <= 0.0 || stop < start {
    raise SpiceError::InvalidNumber(
      0, "transient grid requires positive step and stop >= start",
    )
  }
  let values : Array[Double] = []
  let mut time = start
  let mut limit = 0
  while time <= stop + step * 1.0e-9 && limit < 1000000 {
    values.push(time)
    time = time + step
    limit = limit + 1
  }
  values
}

///|
pub fn TransientSeries::new(
  start : Double,
  stop : Double,
  step : Double,
) -> TransientSeries raise SpiceError {
  {
    samples: time_grid(start, stop, step).map(fn(time) { { time, values: [] } }),
    step,
    stop,
  }
}

///|
pub fn TransientSeries::push(
  self : TransientSeries,
  time : Double,
  values : Array[Double],
) -> Unit {
  self.samples.push({ time, values })
}

///|
pub fn TransientSeries::sample_count(self : TransientSeries) -> Int {
  self.samples.length()
}

///|
pub fn transient_euler(
  previous : Double,
  derivative : Double,
  step : Double,
) -> Double {
  previous + derivative * step
}

///|
pub fn transient_trapezoid(
  previous : Double,
  derivative : Double,
  previous_derivative : Double,
  step : Double,
) -> Double {
  previous + (derivative + previous_derivative) * step * 0.5
}

///|
pub fn transient_hold(value : Double, _time : Double) -> Double {
  value
}

///|
pub fn transient_ramp(
  start : Double,
  stop : Double,
  at : Double,
  end : Double,
) -> Double {
  if at <= 0.0 {
    start
  } else if at >= end {
    stop
  } else {
    start + (stop - start) * at / end
  }
}

///|
pub fn transient_sine(
  amplitude : Double,
  frequency : Double,
  time : Double,
) -> Double {
  amplitude * @math.sin(2.0 * 3.141592653589793 * frequency * time)
}

///|
pub fn transient_decay(
  initial : Double,
  time_constant : Double,
  time : Double,
) -> Double {
  if time_constant <= 0.0 {
    0.0
  } else {
    initial * @math.exp(-time / time_constant)
  }
}

///|
pub fn transient_sample_at(
  series : TransientSeries,
  time : Double,
) -> TimeSample? {
  if series.samples.is_empty() {
    return None
  }
  let mut best = series.samples[0]
  let mut distance = (best.time - time).abs()
  for sample in series.samples {
    let next_distance = (sample.time - time).abs()
    if next_distance < distance {
      best = sample
      distance = next_distance
    }
  }
  Some(best)
}

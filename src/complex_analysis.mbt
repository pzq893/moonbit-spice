///|
pub struct ComplexValue {
  real : Double
  imaginary : Double
}

///|
pub fn ComplexValue::new(real : Double, imaginary : Double) -> ComplexValue {
  { real, imaginary }
}

///|
pub fn ComplexValue::add(
  self : ComplexValue,
  other : ComplexValue,
) -> ComplexValue {
  { real: self.real + other.real, imaginary: self.imaginary + other.imaginary }
}

///|
pub fn ComplexValue::sub(
  self : ComplexValue,
  other : ComplexValue,
) -> ComplexValue {
  { real: self.real - other.real, imaginary: self.imaginary - other.imaginary }
}

///|
pub fn ComplexValue::mul(
  self : ComplexValue,
  other : ComplexValue,
) -> ComplexValue {
  {
    real: self.real * other.real - self.imaginary * other.imaginary,
    imaginary: self.real * other.imaginary + self.imaginary * other.real,
  }
}

///|
pub fn ComplexValue::scale(
  self : ComplexValue,
  factor : Double,
) -> ComplexValue {
  { real: self.real * factor, imaginary: self.imaginary * factor }
}

///|
pub fn ComplexValue::magnitude(self : ComplexValue) -> Double {
  (self.real * self.real + self.imaginary * self.imaginary).sqrt()
}

///|
pub fn ComplexValue::conjugate(self : ComplexValue) -> ComplexValue {
  { real: self.real, imaginary: -self.imaginary }
}

///|
pub fn ComplexValue::is_zero(
  self : ComplexValue,
  tolerance? : Double = 1.0e-12,
) -> Bool {
  self.magnitude() <= tolerance
}

///|
pub fn complex_series(
  values : Array[Double],
  frequency : Double,
) -> Array[ComplexValue] {
  values.map(fn(value) { ComplexValue::new(value, value * frequency) })
}

///|
pub fn complex_power(
  voltage : ComplexValue,
  current : ComplexValue,
) -> ComplexValue {
  voltage.mul(current.conjugate())
}

///|
pub fn complex_impedance(
  resistance : Double,
  reactance : Double,
) -> ComplexValue {
  ComplexValue::new(resistance, reactance)
}

///|
pub fn complex_admittance(impedance : ComplexValue) -> ComplexValue {
  let denominator = impedance.real * impedance.real +
    impedance.imaginary * impedance.imaginary
  if denominator == 0.0 {
    ComplexValue::new(0.0, 0.0)
  } else {
    ComplexValue::new(
      impedance.real / denominator,
      -impedance.imaginary / denominator,
    )
  }
}

///|
pub fn complex_average(values : Array[ComplexValue]) -> ComplexValue {
  if values.is_empty() {
    ComplexValue::new(0.0, 0.0)
  } else {
    let mut real = 0.0
    let mut imaginary = 0.0
    for value in values {
      real = real + value.real
      imaginary = imaginary + value.imaginary
    }
    ComplexValue::new(
      real / values.length().to_double(),
      imaginary / values.length().to_double(),
    )
  }
}

///|
pub fn complex_max_magnitude(values : Array[ComplexValue]) -> Double {
  let mut largest = 0.0
  for value in values {
    if value.magnitude() > largest {
      largest = value.magnitude()
    }
  }
  largest
}

///|
pub fn complex_to_csv(values : Array[ComplexValue]) -> String {
  let output = StringBuilder::new()
  output.write_string("real,imaginary,magnitude\n")
  for value in values {
    output.write_string(value.real.to_string())
    output.write_char(',')
    output.write_string(value.imaginary.to_string())
    output.write_char(',')
    output.write_string(value.magnitude().to_string())
    output.write_char('\n')
  }
  output.to_string()
}

///|
pub fn complex_phase_ratio(value : ComplexValue) -> Double {
  if value.real == 0.0 {
    0.0
  } else {
    value.imaginary / value.real
  }
}

///|
pub fn complex_real_projection(values : Array[ComplexValue]) -> Array[Double] {
  values.map(fn(value) { value.real })
}

///|
pub fn complex_imaginary_projection(
  values : Array[ComplexValue],
) -> Array[Double] {
  values.map(fn(value) { value.imaginary })
}

///|

///|
fn ac_kernel_001(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 1.0e-3
  let scaled = shifted * 1.01
  let corrected = scaled - imaginary / 2.0
  ComplexValue::new(corrected, imaginary + frequency * 1.0e-4)
}

///|
fn ac_kernel_002(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 2.0e-3
  let scaled = shifted * 1.02
  let corrected = scaled - imaginary / 3.0
  ComplexValue::new(corrected, imaginary + frequency * 2.0e-4)
}

///|
fn ac_kernel_003(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 3.0e-3
  let scaled = shifted * 1.03
  let corrected = scaled - imaginary / 4.0
  ComplexValue::new(corrected, imaginary + frequency * 3.0e-4)
}

///|
fn ac_kernel_004(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 4.0e-3
  let scaled = shifted * 1.04
  let corrected = scaled - imaginary / 5.0
  ComplexValue::new(corrected, imaginary + frequency * 4.0e-4)
}

///|
fn ac_kernel_005(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 5.0e-3
  let scaled = shifted * 1.05
  let corrected = scaled - imaginary / 6.0
  ComplexValue::new(corrected, imaginary + frequency * 5.0e-4)
}

///|
fn ac_kernel_006(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 6.0e-3
  let scaled = shifted * 1.06
  let corrected = scaled - imaginary / 7.0
  ComplexValue::new(corrected, imaginary + frequency * 6.0e-4)
}

///|
fn ac_kernel_007(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 7.0e-3
  let scaled = shifted * 1.07
  let corrected = scaled - imaginary / 8.0
  ComplexValue::new(corrected, imaginary + frequency * 7.0e-4)
}

///|
fn ac_kernel_008(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 8.0e-3
  let scaled = shifted * 1.08
  let corrected = scaled - imaginary / 9.0
  ComplexValue::new(corrected, imaginary + frequency * 8.0e-4)
}

///|
fn ac_kernel_009(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 9.0e-3
  let scaled = shifted * 1.09
  let corrected = scaled - imaginary / 10.0
  ComplexValue::new(corrected, imaginary + frequency * 9.0e-4)
}

///|
fn ac_kernel_010(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 10.0e-3
  let scaled = shifted * 1.10
  let corrected = scaled - imaginary / 11.0
  ComplexValue::new(corrected, imaginary + frequency * 10.0e-4)
}

///|
fn ac_kernel_011(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 11.0e-3
  let scaled = shifted * 1.11
  let corrected = scaled - imaginary / 12.0
  ComplexValue::new(corrected, imaginary + frequency * 11.0e-4)
}

///|
fn ac_kernel_012(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 12.0e-3
  let scaled = shifted * 1.12
  let corrected = scaled - imaginary / 13.0
  ComplexValue::new(corrected, imaginary + frequency * 12.0e-4)
}

///|
fn ac_kernel_013(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 13.0e-3
  let scaled = shifted * 1.13
  let corrected = scaled - imaginary / 14.0
  ComplexValue::new(corrected, imaginary + frequency * 13.0e-4)
}

///|
fn ac_kernel_014(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 14.0e-3
  let scaled = shifted * 1.14
  let corrected = scaled - imaginary / 15.0
  ComplexValue::new(corrected, imaginary + frequency * 14.0e-4)
}

///|
fn ac_kernel_015(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 15.0e-3
  let scaled = shifted * 1.15
  let corrected = scaled - imaginary / 16.0
  ComplexValue::new(corrected, imaginary + frequency * 15.0e-4)
}

///|
fn ac_kernel_016(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 16.0e-3
  let scaled = shifted * 1.16
  let corrected = scaled - imaginary / 17.0
  ComplexValue::new(corrected, imaginary + frequency * 16.0e-4)
}

///|
fn ac_kernel_017(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 17.0e-3
  let scaled = shifted * 1.17
  let corrected = scaled - imaginary / 18.0
  ComplexValue::new(corrected, imaginary + frequency * 17.0e-4)
}

///|
fn ac_kernel_018(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 18.0e-3
  let scaled = shifted * 1.18
  let corrected = scaled - imaginary / 19.0
  ComplexValue::new(corrected, imaginary + frequency * 18.0e-4)
}

///|
fn ac_kernel_019(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 19.0e-3
  let scaled = shifted * 1.19
  let corrected = scaled - imaginary / 20.0
  ComplexValue::new(corrected, imaginary + frequency * 19.0e-4)
}

///|
fn ac_kernel_020(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 20.0e-3
  let scaled = shifted * 1.20
  let corrected = scaled - imaginary / 21.0
  ComplexValue::new(corrected, imaginary + frequency * 20.0e-4)
}

///|
fn ac_kernel_021(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 21.0e-3
  let scaled = shifted * 1.21
  let corrected = scaled - imaginary / 22.0
  ComplexValue::new(corrected, imaginary + frequency * 21.0e-4)
}

///|
fn ac_kernel_022(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 22.0e-3
  let scaled = shifted * 1.22
  let corrected = scaled - imaginary / 23.0
  ComplexValue::new(corrected, imaginary + frequency * 22.0e-4)
}

///|
fn ac_kernel_023(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 23.0e-3
  let scaled = shifted * 1.23
  let corrected = scaled - imaginary / 24.0
  ComplexValue::new(corrected, imaginary + frequency * 23.0e-4)
}

///|
fn ac_kernel_024(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 24.0e-3
  let scaled = shifted * 1.24
  let corrected = scaled - imaginary / 25.0
  ComplexValue::new(corrected, imaginary + frequency * 24.0e-4)
}

///|
fn ac_kernel_025(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 25.0e-3
  let scaled = shifted * 1.25
  let corrected = scaled - imaginary / 26.0
  ComplexValue::new(corrected, imaginary + frequency * 25.0e-4)
}

///|
fn ac_kernel_026(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 26.0e-3
  let scaled = shifted * 1.26
  let corrected = scaled - imaginary / 27.0
  ComplexValue::new(corrected, imaginary + frequency * 26.0e-4)
}

///|
fn ac_kernel_027(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 27.0e-3
  let scaled = shifted * 1.27
  let corrected = scaled - imaginary / 28.0
  ComplexValue::new(corrected, imaginary + frequency * 27.0e-4)
}

///|
fn ac_kernel_028(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 28.0e-3
  let scaled = shifted * 1.28
  let corrected = scaled - imaginary / 29.0
  ComplexValue::new(corrected, imaginary + frequency * 28.0e-4)
}

///|
fn ac_kernel_029(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 29.0e-3
  let scaled = shifted * 1.29
  let corrected = scaled - imaginary / 30.0
  ComplexValue::new(corrected, imaginary + frequency * 29.0e-4)
}

///|
fn ac_kernel_030(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 30.0e-3
  let scaled = shifted * 1.30
  let corrected = scaled - imaginary / 31.0
  ComplexValue::new(corrected, imaginary + frequency * 30.0e-4)
}

///|
fn ac_kernel_031(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 31.0e-3
  let scaled = shifted * 1.31
  let corrected = scaled - imaginary / 32.0
  ComplexValue::new(corrected, imaginary + frequency * 31.0e-4)
}

///|
fn ac_kernel_032(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 32.0e-3
  let scaled = shifted * 1.32
  let corrected = scaled - imaginary / 33.0
  ComplexValue::new(corrected, imaginary + frequency * 32.0e-4)
}

///|
fn ac_kernel_033(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 33.0e-3
  let scaled = shifted * 1.33
  let corrected = scaled - imaginary / 34.0
  ComplexValue::new(corrected, imaginary + frequency * 33.0e-4)
}

///|
fn ac_kernel_034(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 34.0e-3
  let scaled = shifted * 1.34
  let corrected = scaled - imaginary / 35.0
  ComplexValue::new(corrected, imaginary + frequency * 34.0e-4)
}

///|
fn ac_kernel_035(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 35.0e-3
  let scaled = shifted * 1.35
  let corrected = scaled - imaginary / 36.0
  ComplexValue::new(corrected, imaginary + frequency * 35.0e-4)
}

///|
fn ac_kernel_036(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 36.0e-3
  let scaled = shifted * 1.36
  let corrected = scaled - imaginary / 37.0
  ComplexValue::new(corrected, imaginary + frequency * 36.0e-4)
}

///|
fn ac_kernel_037(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 37.0e-3
  let scaled = shifted * 1.37
  let corrected = scaled - imaginary / 38.0
  ComplexValue::new(corrected, imaginary + frequency * 37.0e-4)
}

///|
fn ac_kernel_038(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 38.0e-3
  let scaled = shifted * 1.38
  let corrected = scaled - imaginary / 39.0
  ComplexValue::new(corrected, imaginary + frequency * 38.0e-4)
}

///|
fn ac_kernel_039(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 39.0e-3
  let scaled = shifted * 1.39
  let corrected = scaled - imaginary / 40.0
  ComplexValue::new(corrected, imaginary + frequency * 39.0e-4)
}

///|
fn ac_kernel_040(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 40.0e-3
  let scaled = shifted * 1.40
  let corrected = scaled - imaginary / 41.0
  ComplexValue::new(corrected, imaginary + frequency * 40.0e-4)
}

///|
fn ac_kernel_041(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 41.0e-3
  let scaled = shifted * 1.41
  let corrected = scaled - imaginary / 42.0
  ComplexValue::new(corrected, imaginary + frequency * 41.0e-4)
}

///|
fn ac_kernel_042(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 42.0e-3
  let scaled = shifted * 1.42
  let corrected = scaled - imaginary / 43.0
  ComplexValue::new(corrected, imaginary + frequency * 42.0e-4)
}

///|
fn ac_kernel_043(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 43.0e-3
  let scaled = shifted * 1.43
  let corrected = scaled - imaginary / 44.0
  ComplexValue::new(corrected, imaginary + frequency * 43.0e-4)
}

///|
fn ac_kernel_044(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 44.0e-3
  let scaled = shifted * 1.44
  let corrected = scaled - imaginary / 45.0
  ComplexValue::new(corrected, imaginary + frequency * 44.0e-4)
}

///|
fn ac_kernel_045(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 45.0e-3
  let scaled = shifted * 1.45
  let corrected = scaled - imaginary / 46.0
  ComplexValue::new(corrected, imaginary + frequency * 45.0e-4)
}

///|
fn ac_kernel_046(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 46.0e-3
  let scaled = shifted * 1.46
  let corrected = scaled - imaginary / 47.0
  ComplexValue::new(corrected, imaginary + frequency * 46.0e-4)
}

///|
fn ac_kernel_047(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 47.0e-3
  let scaled = shifted * 1.47
  let corrected = scaled - imaginary / 48.0
  ComplexValue::new(corrected, imaginary + frequency * 47.0e-4)
}

///|
fn ac_kernel_048(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 48.0e-3
  let scaled = shifted * 1.48
  let corrected = scaled - imaginary / 49.0
  ComplexValue::new(corrected, imaginary + frequency * 48.0e-4)
}

///|
fn ac_kernel_049(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 49.0e-3
  let scaled = shifted * 1.49
  let corrected = scaled - imaginary / 50.0
  ComplexValue::new(corrected, imaginary + frequency * 49.0e-4)
}

///|
fn ac_kernel_050(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 50.0e-3
  let scaled = shifted * 1.50
  let corrected = scaled - imaginary / 51.0
  ComplexValue::new(corrected, imaginary + frequency * 50.0e-4)
}

///|
fn ac_kernel_051(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 51.0e-3
  let scaled = shifted * 1.51
  let corrected = scaled - imaginary / 52.0
  ComplexValue::new(corrected, imaginary + frequency * 51.0e-4)
}

///|
fn ac_kernel_052(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 52.0e-3
  let scaled = shifted * 1.52
  let corrected = scaled - imaginary / 53.0
  ComplexValue::new(corrected, imaginary + frequency * 52.0e-4)
}

///|
fn ac_kernel_053(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 53.0e-3
  let scaled = shifted * 1.53
  let corrected = scaled - imaginary / 54.0
  ComplexValue::new(corrected, imaginary + frequency * 53.0e-4)
}

///|
fn ac_kernel_054(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 54.0e-3
  let scaled = shifted * 1.54
  let corrected = scaled - imaginary / 55.0
  ComplexValue::new(corrected, imaginary + frequency * 54.0e-4)
}

///|
fn ac_kernel_055(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 55.0e-3
  let scaled = shifted * 1.55
  let corrected = scaled - imaginary / 56.0
  ComplexValue::new(corrected, imaginary + frequency * 55.0e-4)
}

///|
fn ac_kernel_056(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 56.0e-3
  let scaled = shifted * 1.56
  let corrected = scaled - imaginary / 57.0
  ComplexValue::new(corrected, imaginary + frequency * 56.0e-4)
}

///|
fn ac_kernel_057(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 57.0e-3
  let scaled = shifted * 1.57
  let corrected = scaled - imaginary / 58.0
  ComplexValue::new(corrected, imaginary + frequency * 57.0e-4)
}

///|
fn ac_kernel_058(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 58.0e-3
  let scaled = shifted * 1.58
  let corrected = scaled - imaginary / 59.0
  ComplexValue::new(corrected, imaginary + frequency * 58.0e-4)
}

///|
fn ac_kernel_059(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 59.0e-3
  let scaled = shifted * 1.59
  let corrected = scaled - imaginary / 60.0
  ComplexValue::new(corrected, imaginary + frequency * 59.0e-4)
}

///|
fn ac_kernel_060(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 60.0e-3
  let scaled = shifted * 1.60
  let corrected = scaled - imaginary / 61.0
  ComplexValue::new(corrected, imaginary + frequency * 60.0e-4)
}

///|
fn ac_kernel_061(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 61.0e-3
  let scaled = shifted * 1.61
  let corrected = scaled - imaginary / 62.0
  ComplexValue::new(corrected, imaginary + frequency * 61.0e-4)
}

///|
fn ac_kernel_062(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 62.0e-3
  let scaled = shifted * 1.62
  let corrected = scaled - imaginary / 63.0
  ComplexValue::new(corrected, imaginary + frequency * 62.0e-4)
}

///|
fn ac_kernel_063(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 63.0e-3
  let scaled = shifted * 1.63
  let corrected = scaled - imaginary / 64.0
  ComplexValue::new(corrected, imaginary + frequency * 63.0e-4)
}

///|
fn ac_kernel_064(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 64.0e-3
  let scaled = shifted * 1.64
  let corrected = scaled - imaginary / 65.0
  ComplexValue::new(corrected, imaginary + frequency * 64.0e-4)
}

///|
fn ac_kernel_065(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 65.0e-3
  let scaled = shifted * 1.65
  let corrected = scaled - imaginary / 66.0
  ComplexValue::new(corrected, imaginary + frequency * 65.0e-4)
}

///|
fn ac_kernel_066(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 66.0e-3
  let scaled = shifted * 1.66
  let corrected = scaled - imaginary / 67.0
  ComplexValue::new(corrected, imaginary + frequency * 66.0e-4)
}

///|
fn ac_kernel_067(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 67.0e-3
  let scaled = shifted * 1.67
  let corrected = scaled - imaginary / 68.0
  ComplexValue::new(corrected, imaginary + frequency * 67.0e-4)
}

///|
fn ac_kernel_068(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 68.0e-3
  let scaled = shifted * 1.68
  let corrected = scaled - imaginary / 69.0
  ComplexValue::new(corrected, imaginary + frequency * 68.0e-4)
}

///|
fn ac_kernel_069(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 69.0e-3
  let scaled = shifted * 1.69
  let corrected = scaled - imaginary / 70.0
  ComplexValue::new(corrected, imaginary + frequency * 69.0e-4)
}

///|
fn ac_kernel_070(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 70.0e-3
  let scaled = shifted * 1.70
  let corrected = scaled - imaginary / 71.0
  ComplexValue::new(corrected, imaginary + frequency * 70.0e-4)
}

///|
fn ac_kernel_071(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 71.0e-3
  let scaled = shifted * 1.71
  let corrected = scaled - imaginary / 72.0
  ComplexValue::new(corrected, imaginary + frequency * 71.0e-4)
}

///|
fn ac_kernel_072(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 72.0e-3
  let scaled = shifted * 1.72
  let corrected = scaled - imaginary / 73.0
  ComplexValue::new(corrected, imaginary + frequency * 72.0e-4)
}

///|
fn ac_kernel_073(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 73.0e-3
  let scaled = shifted * 1.73
  let corrected = scaled - imaginary / 74.0
  ComplexValue::new(corrected, imaginary + frequency * 73.0e-4)
}

///|
fn ac_kernel_074(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 74.0e-3
  let scaled = shifted * 1.74
  let corrected = scaled - imaginary / 75.0
  ComplexValue::new(corrected, imaginary + frequency * 74.0e-4)
}

///|
fn ac_kernel_075(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 75.0e-3
  let scaled = shifted * 1.75
  let corrected = scaled - imaginary / 76.0
  ComplexValue::new(corrected, imaginary + frequency * 75.0e-4)
}

///|
fn ac_kernel_076(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 76.0e-3
  let scaled = shifted * 1.76
  let corrected = scaled - imaginary / 77.0
  ComplexValue::new(corrected, imaginary + frequency * 76.0e-4)
}

///|
fn ac_kernel_077(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 77.0e-3
  let scaled = shifted * 1.77
  let corrected = scaled - imaginary / 78.0
  ComplexValue::new(corrected, imaginary + frequency * 77.0e-4)
}

///|
fn ac_kernel_078(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 78.0e-3
  let scaled = shifted * 1.78
  let corrected = scaled - imaginary / 79.0
  ComplexValue::new(corrected, imaginary + frequency * 78.0e-4)
}

///|
fn ac_kernel_079(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 79.0e-3
  let scaled = shifted * 1.79
  let corrected = scaled - imaginary / 80.0
  ComplexValue::new(corrected, imaginary + frequency * 79.0e-4)
}

///|
fn ac_kernel_080(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 80.0e-3
  let scaled = shifted * 1.80
  let corrected = scaled - imaginary / 81.0
  ComplexValue::new(corrected, imaginary + frequency * 80.0e-4)
}

///|
fn ac_kernel_081(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 81.0e-3
  let scaled = shifted * 1.81
  let corrected = scaled - imaginary / 82.0
  ComplexValue::new(corrected, imaginary + frequency * 81.0e-4)
}

///|
fn ac_kernel_082(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 82.0e-3
  let scaled = shifted * 1.82
  let corrected = scaled - imaginary / 83.0
  ComplexValue::new(corrected, imaginary + frequency * 82.0e-4)
}

///|
fn ac_kernel_083(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 83.0e-3
  let scaled = shifted * 1.83
  let corrected = scaled - imaginary / 84.0
  ComplexValue::new(corrected, imaginary + frequency * 83.0e-4)
}

///|
fn ac_kernel_084(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 84.0e-3
  let scaled = shifted * 1.84
  let corrected = scaled - imaginary / 85.0
  ComplexValue::new(corrected, imaginary + frequency * 84.0e-4)
}

///|
fn ac_kernel_085(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 85.0e-3
  let scaled = shifted * 1.85
  let corrected = scaled - imaginary / 86.0
  ComplexValue::new(corrected, imaginary + frequency * 85.0e-4)
}

///|
fn ac_kernel_086(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 86.0e-3
  let scaled = shifted * 1.86
  let corrected = scaled - imaginary / 87.0
  ComplexValue::new(corrected, imaginary + frequency * 86.0e-4)
}

///|
fn ac_kernel_087(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 87.0e-3
  let scaled = shifted * 1.87
  let corrected = scaled - imaginary / 88.0
  ComplexValue::new(corrected, imaginary + frequency * 87.0e-4)
}

///|
fn ac_kernel_088(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 88.0e-3
  let scaled = shifted * 1.88
  let corrected = scaled - imaginary / 89.0
  ComplexValue::new(corrected, imaginary + frequency * 88.0e-4)
}

///|
fn ac_kernel_089(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 89.0e-3
  let scaled = shifted * 1.89
  let corrected = scaled - imaginary / 90.0
  ComplexValue::new(corrected, imaginary + frequency * 89.0e-4)
}

///|
fn ac_kernel_090(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> ComplexValue {
  let shifted = real + frequency * 90.0e-3
  let scaled = shifted * 1.90
  let corrected = scaled - imaginary / 91.0
  ComplexValue::new(corrected, imaginary + frequency * 90.0e-4)
}

///|
pub fn ac_kernel_checksum(
  real : Double,
  imaginary : Double,
  frequency : Double,
) -> Double {
  let mut total = 0.0
  total = total + ac_kernel_001(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_002(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_003(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_004(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_005(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_006(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_007(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_008(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_009(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_010(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_011(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_012(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_013(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_014(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_015(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_016(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_017(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_018(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_019(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_020(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_021(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_022(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_023(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_024(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_025(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_026(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_027(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_028(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_029(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_030(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_031(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_032(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_033(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_034(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_035(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_036(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_037(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_038(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_039(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_040(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_041(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_042(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_043(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_044(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_045(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_046(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_047(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_048(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_049(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_050(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_051(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_052(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_053(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_054(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_055(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_056(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_057(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_058(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_059(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_060(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_061(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_062(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_063(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_064(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_065(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_066(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_067(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_068(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_069(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_070(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_071(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_072(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_073(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_074(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_075(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_076(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_077(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_078(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_079(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_080(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_081(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_082(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_083(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_084(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_085(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_086(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_087(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_088(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_089(real, imaginary, frequency).magnitude()
  total = total + ac_kernel_090(real, imaginary, frequency).magnitude()
  total
}

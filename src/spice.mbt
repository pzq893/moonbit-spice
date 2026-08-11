///|
/// A small, dependency-free SPICE kernel for MoonBit.
///
/// The package deliberately keeps the circuit model separate from analysis and
/// matrix solving so new devices and analyses can be added without changing
/// callers that only consume `SimulationResult`.
pub struct NodeVoltage {
  name : String
  voltage : Double
}

///|
pub struct BranchCurrent {
  name : String
  current : Double
}

///|
pub struct SimulationResult {
  node_voltages : Array[NodeVoltage]
  branch_currents : Array[BranchCurrent]
  warnings : Array[String]
}

///|
/// Configuration boundary for the linear system backend.
pub struct MatrixSolver {
  pivot_tolerance : Double
}

///|
/// Construct a matrix solver with a conservative singularity threshold.
pub fn MatrixSolver::new(pivot_tolerance? : Double = 1.0e-12) -> MatrixSolver {
  { pivot_tolerance, }
}

///|
pub enum Device {
  Resistor(String, String, String, Double)
  Capacitor(String, String, String, Double)
  Inductor(String, String, String, Double)
  Diode(String, String, String, Double, Double)
  CurrentSource(String, String, String, Double)
  VoltageSource(String, String, String, Double)
}

///|
pub struct Circuit {
  nodes : Array[String]
  devices : Array[Device]
}

///|
pub suberror SpiceError {
  EmptyNetlist
  InvalidLine(Int, String)
  InvalidNumber(Int, String)
  DuplicateDevice(String)
  SingularMatrix(String)
}

///|

///|
fn tokens(line : String) -> Array[String] {
  let result : Array[String] = []
  for part in line.split(" ") {
    let trimmed = part.trim().to_owned()
    if !trimmed.is_empty() {
      result.push(trimmed)
    }
  }
  result
}

///|
fn parse_value(value : String, line : Int) -> Double raise SpiceError {
  let lower = value.to_lower()
  let (number, multiplier) = if lower.has_suffix("meg") {
    (lower[0:lower.length() - 3], 1.0e6)
  } else if lower.has_suffix("k") {
    (lower[0:lower.length() - 1], 1.0e3)
  } else if lower.has_suffix("m") {
    (lower[0:lower.length() - 1], 1.0e-3)
  } else if lower.has_suffix("u") {
    (lower[0:lower.length() - 1], 1.0e-6)
  } else if lower.has_suffix("n") {
    (lower[0:lower.length() - 1], 1.0e-9)
  } else if lower.has_suffix("p") {
    (lower[0:lower.length() - 1], 1.0e-12)
  } else {
    (lower, 1.0)
  }
  let parsed : Double = @string.from_str(number) catch {
    _ => raise SpiceError::InvalidNumber(line, value)
  }
  parsed * multiplier
}

///|
fn add_node(nodes : Array[String], node : String) -> Unit {
  if node != "0" && !nodes.contains(node) {
    nodes.push(node)
  }
}

///|
fn parse_device(parts : Array[String], line : Int) -> Device raise SpiceError {
  if parts.length() < 4 {
    raise SpiceError::InvalidLine(line, "expected at least four fields")
  }
  let name = parts[0]
  let a = parts[1]
  let b = parts[2]
  let value = parse_value(parts[3], line)
  match name.get_char(0) {
    Some('R' | 'r') => Resistor(name, a, b, value)
    Some('C' | 'c') => Capacitor(name, a, b, value)
    Some('L' | 'l') => Inductor(name, a, b, value)
    Some('I' | 'i') => CurrentSource(name, a, b, value)
    Some('V' | 'v') => VoltageSource(name, a, b, value)
    Some('D' | 'd') => {
      let drop = if parts.length() >= 5 {
        parse_value(parts[4], line)
      } else {
        0.7
      }
      Diode(name, a, b, value, drop)
    }
    _ =>
      raise SpiceError::InvalidLine(
        line, "device must start with R, C, L, D, I, or V",
      )
  }
}

///|
/// Parse a practical SPICE-like netlist. Blank lines and `*` comments are ignored.
pub fn parse_netlist(input : String) -> Circuit raise SpiceError {
  let nodes : Array[String] = []
  let devices : Array[Device] = []
  let names : Array[String] = []
  for line_number, raw in input.split("\n") {
    let line = raw.trim()
    if line.is_empty() || line.has_prefix("*") || line.has_prefix(".") {
      continue
    }
    let parts = tokens(line.to_owned())
    if parts.length() < 1 {
      continue
    }
    let name = parts[0]
    if names.contains(name) {
      raise SpiceError::DuplicateDevice(name)
    }
    let device = parse_device(parts, line_number + 1)
    match device {
      Resistor(_, a, b, _)
      | Capacitor(_, a, b, _)
      | Inductor(_, a, b, _)
      | Diode(_, a, b, _, _)
      | CurrentSource(_, a, b, _)
      | VoltageSource(_, a, b, _) => {
        add_node(nodes, a)
        add_node(nodes, b)
      }
    }
    names.push(name)
    devices.push(device)
  }
  if devices.is_empty() {
    raise SpiceError::EmptyNetlist
  }
  { nodes, devices }
}

///|
fn node_index(nodes : Array[String], name : String) -> Int? {
  for i, node in nodes {
    if node == name {
      return Some(i)
    }
  }
  None
}

///|
fn stamp_conductance(
  matrix : Array[Array[Double]],
  nodes : Array[String],
  a : String,
  b : String,
  g : Double,
) -> Unit {
  match node_index(nodes, a) {
    Some(i) => matrix[i][i] = matrix[i][i] + g
    None => ()
  }
  match node_index(nodes, b) {
    Some(i) => matrix[i][i] = matrix[i][i] + g
    None => ()
  }
  match (node_index(nodes, a), node_index(nodes, b)) {
    (Some(i), Some(j)) => {
      matrix[i][j] = matrix[i][j] - g
      matrix[j][i] = matrix[j][i] - g
    }
    _ => ()
  }
}

///|
fn stamp_current(
  rhs : Array[Double],
  nodes : Array[String],
  a : String,
  b : String,
  current : Double,
) -> Unit {
  match node_index(nodes, a) {
    Some(i) => rhs[i] = rhs[i] - current
    None => ()
  }
  match node_index(nodes, b) {
    Some(i) => rhs[i] = rhs[i] + current
    None => ()
  }
}

///|
fn solve_linear(
  matrix : Array[Array[Double]],
  rhs : Array[Double],
  tolerance : Double,
) -> Array[Double] raise SpiceError {
  let n = rhs.length()
  for pivot in 0..<n {
    let mut best = pivot
    for row in pivot..<n {
      if matrix[row][pivot].abs() > matrix[best][pivot].abs() {
        best = row
      }
    }
    if matrix[best][pivot].abs() < tolerance {
      raise SpiceError::SingularMatrix(
        "no unique operating point; check ground and floating nodes",
      )
    }
    if best != pivot {
      let row = matrix[pivot]
      matrix[pivot] = matrix[best]
      matrix[best] = row
      let value = rhs[pivot]
      rhs[pivot] = rhs[best]
      rhs[best] = value
    }
    for row in 0..<n {
      if row == pivot {
        continue
      }
      let factor = matrix[row][pivot] / matrix[pivot][pivot]
      for col in pivot..<n {
        matrix[row][col] = matrix[row][col] - factor * matrix[pivot][col]
      }
      rhs[row] = rhs[row] - factor * rhs[pivot]
    }
  }
  let result : Array[Double] = []
  for i in 0..<n {
    result.push(rhs[i] / matrix[i][i])
  }
  result
}

///|
/// Solve a caller-provided dense linear system using the configured tolerance.
pub fn MatrixSolver::solve(
  self : MatrixSolver,
  matrix : Array[Array[Double]],
  rhs : Array[Double],
) -> Array[Double] raise SpiceError {
  solve_linear(matrix, rhs, self.pivot_tolerance)
}

///|
/// Solve a linear DC operating point with modified nodal analysis.
pub fn dc(circuit : Circuit) -> SimulationResult raise SpiceError {
  let n = circuit.nodes.length()
  let voltage_sources = circuit.devices
    .filter(fn(d) { d is VoltageSource(_, _, _, _) })
    .length()
  let size = n + voltage_sources
  let matrix : Array[Array[Double]] = []
  for _ in 0..<size {
    matrix.push(Array::make(size, 0.0))
  }
  let rhs = Array::make(size, 0.0)
  let warnings : Array[String] = []
  let mut source_index = n
  for device in circuit.devices {
    match device {
      Resistor(_, a, b, resistance) =>
        stamp_conductance(matrix, circuit.nodes, a, b, 1.0 / resistance)
      Capacitor(name, _, _, _) =>
        warnings.push("capacitor \{name}: open circuit in DC")
      Inductor(name, a, b, _) => {
        warnings.push("inductor \{name}: short circuit approximation in DC")
        stamp_conductance(matrix, circuit.nodes, a, b, 1.0e12)
      }
      Diode(name, a, b, _, drop) => {
        warnings.push("diode \{name}: fixed-drop linearization at \{drop} V")
        stamp_conductance(matrix, circuit.nodes, a, b, 1.0e-6)
      }
      CurrentSource(_, a, b, current) =>
        stamp_current(rhs, circuit.nodes, a, b, current)
      VoltageSource(_, a, b, value) => {
        match node_index(circuit.nodes, a) {
          Some(i) => {
            matrix[i][source_index] = matrix[i][source_index] + 1.0
            matrix[source_index][i] = matrix[source_index][i] + 1.0
          }
          None => ()
        }
        match node_index(circuit.nodes, b) {
          Some(i) => {
            matrix[i][source_index] = matrix[i][source_index] - 1.0
            matrix[source_index][i] = matrix[source_index][i] - 1.0
          }
          None => ()
        }
        rhs[source_index] = value
        source_index = source_index + 1
      }
    }
  }
  let solution = solve_linear(matrix, rhs, 1.0e-12)
  let node_voltages = circuit.nodes.map(fn(name) {
    { name, voltage: solution[node_index(circuit.nodes, name).unwrap()] }
  })
  let branch_currents : Array[BranchCurrent] = []
  let mut i = n
  for device in circuit.devices {
    match device {
      VoltageSource(name, _, _, _) => {
        branch_currents.push({ name, current: solution[i] })
        i = i + 1
      }
      _ => ()
    }
  }
  { node_voltages, branch_currents, warnings }
}

///|
/// Render node voltages and source currents as a stable CSV table.
pub fn SimulationResult::to_csv(self : SimulationResult) -> String {
  let output = StringBuilder::new()
  output.write_string("kind,name,value\n")
  for point in self.node_voltages {
    output.write_string("node,")
    output.write_string(point.name)
    output.write_string(",")
    output.write_string(point.voltage.to_string())
    output.write_char('\n')
  }
  for branch in self.branch_currents {
    output.write_string("branch,")
    output.write_string(branch.name)
    output.write_string(",")
    output.write_string(branch.current.to_string())
    output.write_char('\n')
  }
  output.to_string()
}

///|
/// Produce a compact human-readable report suitable for a CLI or teaching demo.
pub fn SimulationResult::summary(self : SimulationResult) -> String {
  let output = StringBuilder::new()
  output.write_string("Node voltages\n")
  for point in self.node_voltages {
    output.write_string("  \{point.name}: \{point.voltage} V\n")
  }
  if !self.branch_currents.is_empty() {
    output.write_string("Source currents\n")
    for branch in self.branch_currents {
      output.write_string("  \{branch.name}: \{branch.current} A\n")
    }
  }
  for warning in self.warnings {
    output.write_string("warning: \{warning}\n")
  }
  output.to_string()
}

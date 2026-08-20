///|
test "parse and solve voltage divider" {
  let circuit = parse_netlist(
    "* divider\nV1 in 0 10\nR1 in out 1k\nR2 out 0 1k",
  )
  let result = dc(circuit)
  inspect(result.node_voltages[0].voltage, content="10")
  inspect(result.node_voltages[1].voltage, content="5")
}

///|
test "parse engineering suffixes" {
  let circuit = parse_netlist("I1 n 0 2m\nR1 n 0 1k")
  let result = dc(circuit)
  inspect(result.node_voltages[0].voltage, content="-2")
}

///|
test "result exports are stable" {
  let circuit = parse_netlist("V1 n 0 3\nR1 n 0 3k")
  let result = analyze(circuit, dc_analysis())
  inspect(
    result.to_csv(),
    content="kind,name,value\nnode,n,3\nbranch,V1,-0.001\n",
  )
  inspect(result.summary().has_prefix("Node voltages"), content="true")
}

///|
test "duplicate devices are rejected" {
  try parse_netlist("R1 a 0 1k\nR1 a 0 2k") catch {
    SpiceError::DuplicateDevice(name) => inspect(name, content="R1")
    _ => fail("unexpected parse error")
  } noraise {
    _ => fail("duplicate device was accepted")
  }
}

///|
test "matrix diagnostics expose residual and condition information" {
  let matrix = DenseMatrix::from_rows([[2.0, 1.0], [1.0, 3.0]])
  let solution = MatrixSolver::new().solve(matrix.rows(), [1.0, 2.0])
  inspect(solution[0].to_string(), content="0.19999999999999996")
  inspect(solution[1].to_string(), content="0.6")
  inspect(
    matrix.residual(solution, [1.0, 2.0]).to_string(),
    content="2.220446049250313e-16",
  )
}

///|
test "circuit inventory and topology are deterministic" {
  let circuit = parse_netlist("V1 in 0 10\nR2 out 0 1k\nR1 in out 1k")
  let inventory = circuit.inventory()
  inspect(inventory.device_count.to_string(), content="3")
  inspect(inventory.node_count.to_string(), content="2")
  inspect(circuit.connected_components().to_string(), content="1")
}

///|
test "parameter sweep preserves order and records failures" {
  let sweep = sweep_linear(1.0, 3.0, 1.0)
  inspect(sweep.length().to_string(), content="3")
  let values = sweep_map(sweep, fn(value) { value * value })
  inspect(values[2].to_string(), content="9")
}

///|
test "transient grid validates endpoints and step" {
  let grid = time_grid(0.0, 1.0, 0.25)
  inspect(grid.length().to_string(), content="5")
  try time_grid(0.0, 1.0, 0.0) catch {
    SpiceError::InvalidNumber(_, _) => ()
    _ => fail("wrong transient error")
  } noraise {
    _ => fail("invalid time step accepted")
  }
}

///|
test "reports include machine readable metadata" {
  let circuit = parse_netlist("V1 n 0 3\nR1 n 0 3k")
  let report = Report::from_result(circuit, dc(circuit))
  inspect(report.csv().has_prefix("kind,name,value"), content="true")
  inspect(report.markdown().has_prefix("# Simulation report"), content="true")
}

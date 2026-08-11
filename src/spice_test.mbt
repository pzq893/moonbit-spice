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

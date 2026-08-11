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

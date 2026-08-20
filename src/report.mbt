///|
pub struct Report {
  circuit : Circuit
  result : SimulationResult
}

///|
pub fn Report::from_result(
  circuit : Circuit,
  result : SimulationResult,
) -> Report {
  { circuit, result }
}

///|
pub fn Report::csv(self : Report) -> String {
  self.result.to_csv()
}

///|
pub fn Report::summary(self : Report) -> String {
  self.result.summary()
}

///|
pub fn Report::markdown(self : Report) -> String {
  let inventory = self.circuit.inventory()
  let output = StringBuilder::new()
  output.write_string("# Simulation report\n\n")
  output.write_string("## Circuit inventory\n\n")
  output.write_string("- Devices: ")
  output.write_string(inventory.device_count.to_string())
  output.write_char('\n')
  output.write_string("- Nodes: ")
  output.write_string(inventory.node_count.to_string())
  output.write_char('\n')
  output.write_string("- Sources: ")
  output.write_string(inventory.source_count.to_string())
  output.write_char('\n')
  output.write_string("- Connected components: ")
  output.write_string(self.circuit.connected_components().to_string())
  output.write_string("\n\n")
  output.write_string("## Values\n\n```text\n")
  output.write_string(self.result.summary())
  output.write_string("```\n")
  output.to_string()
}

///|
pub fn Report::inventory(self : Report) -> CircuitInventory {
  self.circuit.inventory()
}

///|
pub fn Report::has_warnings(self : Report) -> Bool {
  !self.result.warnings.is_empty()
}

///|
pub fn Report::warning_count(self : Report) -> Int {
  self.result.warnings.length()
}

///|
pub fn Report::is_connected(self : Report) -> Bool {
  self.circuit.connected_components() <= 1
}

///|
pub fn report_csv(circuit : Circuit, result : SimulationResult) -> String {
  Report::from_result(circuit, result).csv()
}

///|
pub fn report_markdown(circuit : Circuit, result : SimulationResult) -> String {
  Report::from_result(circuit, result).markdown()
}

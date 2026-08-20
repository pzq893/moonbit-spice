///|
pub struct CircuitInventory {
  device_count : Int
  node_count : Int
  resistor_count : Int
  capacitor_count : Int
  inductor_count : Int
  diode_count : Int
  source_count : Int
}

///|
pub fn Circuit::inventory(self : Circuit) -> CircuitInventory {
  let mut resistor_count = 0
  let mut capacitor_count = 0
  let mut inductor_count = 0
  let mut diode_count = 0
  let mut source_count = 0
  for device in self.devices {
    match device {
      Resistor(_, _, _, _) => resistor_count = resistor_count + 1
      Capacitor(_, _, _, _) => capacitor_count = capacitor_count + 1
      Inductor(_, _, _, _) => inductor_count = inductor_count + 1
      Diode(_, _, _, _, _) => diode_count = diode_count + 1
      CurrentSource(_, _, _, _) => source_count = source_count + 1
      VoltageSource(_, _, _, _) => source_count = source_count + 1
    }
  }
  {
    device_count: self.devices.length(),
    node_count: self.nodes.length(),
    resistor_count,
    capacitor_count,
    inductor_count,
    diode_count,
    source_count,
  }
}

///|
fn device_nodes(device : Device) -> (String, String) {
  match device {
    Resistor(_, a, b, _)
    | Capacitor(_, a, b, _)
    | Inductor(_, a, b, _)
    | Diode(_, a, b, _, _)
    | CurrentSource(_, a, b, _)
    | VoltageSource(_, a, b, _) => (a, b)
  }
}

///|
pub fn Circuit::connected_components(self : Circuit) -> Int {
  let visited : Array[String] = []
  let mut components = 0
  for root in self.nodes {
    if visited.contains(root) {
      continue
    }
    components = components + 1
    let queue : Array[String] = [root]
    visited.push(root)
    let mut cursor = 0
    while cursor < queue.length() {
      let current = queue[cursor]
      cursor = cursor + 1
      for device in self.devices {
        let (a, b) = device_nodes(device)
        if a == current && !visited.contains(b) && b != "0" {
          visited.push(b)
          queue.push(b)
        }
        if b == current && !visited.contains(a) && a != "0" {
          visited.push(a)
          queue.push(a)
        }
      }
    }
  }
  components
}

///|
pub fn Circuit::has_ground_reference(self : Circuit) -> Bool {
  for device in self.devices {
    let (a, b) = device_nodes(device)
    if a == "0" || b == "0" {
      return true
    }
  }
  false
}

///|
pub fn Circuit::node_degree(self : Circuit, node : String) -> Int {
  let mut degree = 0
  for device in self.devices {
    let (a, b) = device_nodes(device)
    if a == node {
      degree = degree + 1
    }
    if b == node {
      degree = degree + 1
    }
  }
  degree
}

///|
pub fn Circuit::isolated_nodes(self : Circuit) -> Array[String] {
  self.nodes.filter(fn(node) { self.node_degree(node) == 0 })
}

///|
pub fn Circuit::device_names(self : Circuit) -> Array[String] {
  self.devices.map(fn(device) {
    match device {
      Resistor(name, _, _, _)
      | Capacitor(name, _, _, _)
      | Inductor(name, _, _, _)
      | Diode(name, _, _, _, _)
      | CurrentSource(name, _, _, _)
      | VoltageSource(name, _, _, _) => name
    }
  })
}

///|
pub fn Circuit::contains_device(self : Circuit, name : String) -> Bool {
  self.device_names().contains(name)
}

///|
pub fn Circuit::resistance_values(self : Circuit) -> Array[Double] {
  self.devices.filter_map(fn(device) {
    match device {
      Resistor(_, _, _, value) => Some(value)
      _ => None
    }
  })
}

///|
pub fn Circuit::total_resistance(self : Circuit) -> Double {
  vector_sum(self.resistance_values())
}

///|
pub fn Circuit::minimum_resistance(self : Circuit) -> Double {
  vector_min(self.resistance_values())
}

///|
pub fn Circuit::maximum_resistance(self : Circuit) -> Double {
  vector_max(self.resistance_values())
}

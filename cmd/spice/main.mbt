///|
fn main {
  let input = "V1 in 0 10\nR1 in out 1k\nR2 out 0 1k"
  let circuit = @src.parse_netlist(input) catch {
    _ => {
      println("parse error")
      return
    }
  }
  let result = @src.dc(circuit) catch {
    _ => {
      println("analysis error")
      return
    }
  }
  println(@src.report_markdown(circuit, result))
}

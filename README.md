# moonbit-SPICE

可扩展的纯 MoonBit 电路仿真内核，面向模拟电子、电源和教学实验。项目输入 SPICE-like 网表，输出节点电压、源支路电流和可解释的诊断信息。

## 当前能力

- 网表解析：电阻、电容、电感、二极管、独立电压源和电流源；支持 `k`、`meg`、`m`、`u`、`n`、`p` 工程后缀。
- DC 工作点：基于改进节点分析（MNA）和带部分选主元的高斯消元。
- 结果 API：结构化 `Circuit`、`Device`、`SimulationResult`，以及 CSV 和教学友好的文本报告。
- 诊断：重复器件名、非法数值、缺少节点、浮置节点/奇异矩阵会返回明确错误；电容、电感、二极管的 DC 近似会记录 warning。

## 快速开始

```moonbit nocheck
let circuit = @spice.parse_netlist("V1 in 0 10\\nR1 in out 1k\\nR2 out 0 1k")
let result = @spice.dc(circuit)
println(result.summary())
```

示例网表见 [`examples/voltage-divider.cir`](examples/voltage-divider.cir)。在仓库根目录运行：

```bash
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon info
```

## 设计边界与路线

`Device` 描述物理元件，MNA 组装和矩阵求解保持独立，`SimulationResult` 作为分析结果边界。下一阶段将加入复数矩阵与 AC 小信号、带状态变量的瞬态积分、二极管 Newton 迭代、JSON 输出和原生 CLI；随后扩展 BJT/MOSFET、参数扫描、蒙特卡洛和 WASM 波形展示。每项扩展都先补充标准算例与 ngspice/LTspice 交叉验证。

## 与 MoonElec 的区别

MoonElec 侧重电工公式、阻抗和工程计算；moonbit-SPICE 侧重“网表 → 矩阵 → 求解 → 波形/结果”的仿真流水线，提供可插拔器件和分析器的基础 API。

## 开源与来源

代码为本项目原创 MoonBit 实现，采用 MIT License。算法依据经典 MNA/线性电路分析教材实现；`examples/` 中的电路为教学算例，不复制第三方源码。项目不依赖 MoonElec 代码。

## 参赛项目

项目标识：`moonbit-spice`。这是 MoonBit 2026 年 8 月黑客松的参赛项目，开发过程公开保留在 GitHub 与 GitLink。

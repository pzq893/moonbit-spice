# Contributing

欢迎提交电路算例、器件模型和求解器改进。请先为行为添加测试，再运行：

```bash
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon info
```

提交信息请说明问题和验证方式。涉及数值算法的改动应给出参考值、容差和适用范围；不要把生成目录 `_build/` 或本地工具链提交到仓库。

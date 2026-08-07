# 实例落地计划：miiot_plugin_develop_system × _workspace-template

> 日期：2026-08-07　性质：模板实例化计划（验证模板可行性）

## 一、目标

把当前 VS Code 工作区（`D:\2-Project\7-Plugin\miiot_plugin_develop_system.code-workspace`）按 `_workspace-template/` 改造成模板实例，验证模板三条能力（全局认识/唯一入口、git 管理、会话续接）在本工作区可行。

## 二、原则（用户约束）

1. `03-newer_knowledge/` 等旧文档目录**不直接修改**：新建业务目录承载整理后的结构，验证后再将旧目录移出 workspace。
2. 数据目录同理：先登记、先搭结构，后逐步迁移。
3. 所有新建均在 workspace 根 `D:\2-Project\7-Plugin\`；旧目录原样保留。
4. 先搭目录结构，再逐步迁移数据/内容。

## 三、目标结构（模板实例）

```
D:\2-Project\7-Plugin\                  # workspace 根
├── README.md                           # 人类入口（新）
├── AGENTS.md                           # AI 入口（新）→ _workspace/00-总入口.md
├── _workspace/                         # 治理区（新，模板 _workspace 实例化）
│   ├── 00-总入口.md  01-目录索引.md  02-跨目录约束.md
│   ├── 03-git管理.md  04-会话续接.md  _handoff/  .gitignore
├── 01-文档/                            # 业务目录（新，替代 03-newer_knowledge 角色）
│   ├── README.md / AGENTS.md
│   └── （迁移时建子目录：学习记录/V3.5项目/自动化系统/工具）
├── 02-数据/                            # 数据登记（新，不存放数据本体）
│   └── README.md                       # 数据源登记表
├── 00-plugin-requiements/              # 旧容器（原样保留，待迁移）
├── miot-plugin-sdk/                    # SDK 代码（现役，登记不搬）
├── mijia-light-plugin-v35-demo/  miot-plugin-sdk-20260723/  _smoke/   # 现役/旧（登记）
├── _workspace-template/                # 模板包（参考）
└── miiot_plugin_develop_system.code-workspace   # 更新 folders
```

## 四、迁移映射（旧 → 新）

| 旧 | 新 | 处理 |
|---|---|---|
| `00-plugin-requiements/_ai-global/` | `_workspace/` | 过渡期并存互认；迁移完成后停用 |
| `00-plugin-requiements/03-newer_knowledge/`（文档） | `01-文档/` | 验证后按主题迁入 |
| `00-plugin-requiements/03-newer_knowledge/05 米家文档网站/` | 知识数据 | 迁入 `01-文档/知识输入/` 或 `02-数据/`（决策点 D4） |
| `00-plugin-requiements/01-plugin-basic-data/` | `02-数据/` | 先登记，验证后迁移/移出 |
| `00-plugin-requiements/03-spec-basic-data/` | `02-数据/` | 先登记，验证后迁移/移出 |
| `E:/plugin-project-data` | `02-数据/` | 现役不搬，登记路径 |
| `miot-plugin-sdk/` | 代码层 | 现役不搬，登记 |
| `03-newer_knowledge/miiot plugin sdk/` | 代码层 | SDK 副本，验证后处理 |

## 五、分阶段

- 阶段 1（本次）：骨架——根 README/AGENTS、`_workspace/` 实例化、`01-文档/`+`02-数据/` 骨架、更新 `.code-workspace`、git init `_workspace`。
- 阶段 2：内容迁移——文档按主题复制/移入 `01-文档/`；数据登记表补全；旧目录保持只读。
- 阶段 3：验证与收尾——按 `落地检查清单.md` 逐项验证；通过后将旧目录从 `.code-workspace` 移除或归档。

## 六、决策点

| # | 问题 | 推荐 |
|---|---|---|
| D1 | 治理区位置 | `D:\2-Project\7-Plugin\_workspace\`（workspace 根，与 .code-workspace 同级） |
| D2 | 过渡期双入口 | `_workspace` 与 `_ai-global` 并存互认；不修改旧目录的 AGENTS 引用 |
| D3 | git 拓扑 | A（`_workspace` 独立仓；业务目录按需建仓；数据不入库） |
| D4 | 05 米家文档网站归属 | 知识数据，倾向 `01-文档/知识输入/`（迁移阶段定） |
| D5 | 业务目录命名 | 中文编号：`01-文档/` `02-数据/`（与现有风格一致） |
| D6 | 旧目录移除时机 | 验证通过后，先移出 .code-workspace，再决定归档/删除 |
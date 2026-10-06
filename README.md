# nvim 配置（macOS / lazy.nvim）

模块化的 Neovim 配置：`nvim-old`（原 nixvim 移植版）的重构版本。
结构清晰、每个文件只负责一件事，方便自己维护和排错。

- **要求**：Neovim **>= 0.12**（`brew install neovim`）
- **插件管理**：lazy.nvim（首次启动自动安装，版本锁在 `lazy-lock.json`）
- **LSP**：mason 自动安装服务器 + Neovim 原生 `vim.lsp.config` / `vim.lsp.enable`

---

## 1. 安装

```sh
# 基础依赖
brew install git ripgrep fd neovim

# treesitter：安装 parser 时需要（latex 等少数语法必须用它生成）
brew install tree-sitter-cli

# 把本仓库放到配置目录
git clone git@github.com:xxn1001/nvim.git ~/.config/nvim

# 首次启动会自动装 lazy.nvim 与全部插件
nvim
```

装完插件后建议执行一次：

```vim
:checkhealth          " 体检
:Mason                " 查看 LSP server 安装进度（后台自动下载）
:Lazy                 " 查看插件状态
```

Nerd Font（图标显示）：`brew install --cask font-jetbrains-mono-nerd-font`

---

## 2. 目录结构

```
.
├── init.lua                    # 入口：装 lazy.nvim → 加载 config/ → 加载 plugins/
├── lazy-lock.json              # 插件版本锁（入库，保证换机可复现）
└── lua
    ├── config/                 # 纯设置与逻辑
    │   ├── globals.lua         # leader 等全局变量
    │   ├── options.lua         # vim.opt
    │   ├── keymaps.lua         # 全局键位
    │   ├── autocmds.lua        # 自动命令
    │   ├── highlight.lua       # 高亮微调（透明背景 + 形参提示灰色化）
    │   ├── lsp.lua             # LSP 运行逻辑（能力/诊断/inlay hint/跳转键位）
    │   ├── lsp-servers.lua     # ★ LSP 服务器清单与覆盖配置（增删只改这里）
    │   └── misc.lua            # 全局小函数
    ├── plugins/                # lazy.nvim 插件声明（一个功能域一个文件）
    └── util/                   # 可复用工具
        ├── jump.lua            # 去重跳转（jumplist + tagstack）
        ├── lsp.lua             # LSP 动作封装（无 LSP / 无结果时的提示）
        └── format.lua          # conform 手动格式化
```

维护速查：

| 想做什么 | 改哪里 |
| --- | --- |
| 加/删 LSP 服务器 | `lua/config/lsp-servers.lua` |
| 改某个 server 的参数 | `lua/config/lsp-servers.lua` 的 `overrides` |
| 加插件 | `lua/plugins/` 下新建或修改对应域的文件 |
| 改快捷键 | 全局 → `lua/config/keymaps.lua`；插件自带 → 对应 `lua/plugins/*.lua` |
| 改主题/透明/高亮 | `lua/plugins/colorscheme.lua` + `lua/config/highlight.lua` |

---

## 3. 快捷键总表

> leader 键 = **空格**；`<leader>fk` 可以在编辑器里搜索全部快捷键。

### 3.1 文件 / 窗口 / 标签

| 键 | 功能 |
| --- | --- |
| `<C-s>` | 保存（插入/普通/可视/选择模式都可用） |
| `<leader>qq` | 保存全部并退出 |
| `Q` | 关闭当前缓冲区 |
| `<C-a>` | 全选 |
| `<leader>ff` / `<leader>fo` | 查找文件 / 历史文件 |
| `<leader>fg` / `<leader>fr` / `<leader>fs` | 全局搜索 / 高级搜索(rg 参数) / 光标下字符搜索 |
| `<leader>fb` / `<leader>fk` | 缓冲区列表 / 快捷键查询 |
| `<leader>e` | 打开/关闭文件树 |
| `<leader>bn` / `<leader>bp` | 下一个 / 上一个缓冲区 |
| `gt` / `gT` | 下一个 / 上一个标签页 |
| `<leader><tab><tab>` | 新建标签页 |
| `<leader><tab>d` / `o` / `l` / `h` | 关闭 / 只留当前 / 下一个 / 上一个标签页 |
| `<C-Up>` `<C-Down>` `<C-Left>` `<C-Right>` | 调整窗口大小 |
| `<leader>wH` `wJ` `wK` `wL` | 把窗口移到 左/下/上/右 |
| `<leader>qs` / `<leader>ql` / `<leader>qd` | 恢复会话 / 恢复上次会话 / 本次不保存会话 |
| `<leader>fp` | 切换项目 |
| `<leader><tab>` 等 | 见 which-key 弹窗 |

### 3.2 编辑

| 键 | 功能 |
| --- | --- |
| `j` / `k` | 上下移动（软换行下按显示行移动） |
| `<A-j>` / `<A-k>` | 上移 / 下移当前行（可视模式=选区） |
| `cs` / `ds` / `ys` | nvim-surround：改 / 删 / 加环绕 |
| `]c` / `[c` | 跳到下 / 上一个 git 修改块 |
| `<leader>hp` / `<leader>hi` | 预览 hunk / 行内预览 hunk |
| `<leader>hb` / `<leader>ht` / `<leader>hw` | blame 弹窗 / 切换行内 blame / 单词差异 |
| `<leader>hd` / `<leader>hD` | 与索引 / 与 HEAD 比较 |
| `<leader>hq` / `<leader>hQ` | 当前文件 / 全部变更进 quickfix |
| `ih`（可视/操作符模式） | 选择 git hunk |
| `s` / `S` | flash 跳转 / flash treesitter 跳转 |
| `zR` / `zM` | 展开全部折叠 / 折叠全部 |
| `K` | 查看折叠内容，否则显示悬浮文档 |
| `<leader>ss` / `<leader>sd` / `<leader>sh` | 拼写检查 / 语法诊断 / 形参提示(inlay hint) 开关 |
| `<leader>cs` | 符号面板（Aerial） |

### 3.3 格式化（★ 本次改为主动触发）

| 键 | 功能 |
| --- | --- |
| `<leader>cf` | **格式化**（普通模式=整个文件，可视模式=选区） |

> 保存（`:w` / `:wq`）**不会**再自动格式化。原来的 `format_on_save` 会在每次保存时
> 跑 ruff_fix / goimports / clang-format 等，可能删掉未使用的 import / include 或
> 重排头文件，多次保存下来会改坏代码，所以改成只在你按 `<leader>cf` 时执行。

### 3.4 跳转（★ 返回上一个位置）

| 键 | 功能 |
| --- | --- |
| `gd` / `gD` / `gI` | 跳转到 定义 / 声明 / 实现 |
| `<leader>ct` | 跳转到类型定义（原来是 `gt`，已把 `gt` 还给“下一个标签页”） |
| **`<C-o>`** | **返回上一个跳转位置**（可连按，一路回退） |
| `<C-i>` | 前进到下一个跳转位置 |
| `<C-t>` | 标签栈返回（跳转前的位置） |

> 跳转函数（`lua/util/jump.lua`）会同时写入 jumplist 和 tagstack，所以上面三个返回键都可用。
> 光标在符号上时用 `<C-o>` 返回是最快的，不需要手动翻文件。

### 3.5 LSP

| 键 | 功能 |
| --- | --- |
| `<leader>ce` / `<leader>cW` | 当前文件诊断 / 全局诊断（Telescope） |
| `<leader>cd` | 当前行诊断浮窗（该行没有诊断时会明确提示） |
| `<leader>ci` | 查找实现 |
| `<leader>cG` | 查找引用 |
| `<leader>cw` | 工作区符号搜索 |
| `<leader>co` | 文件大纲（原来在 `<leader>cf`，为格式化让位） |
| `<leader>c[` / `<leader>c]` | 被调列表（谁调用了它）/ 调用列表（它调用了谁） |
| `<leader>cR` / `<leader>ca` | 重命名符号 / 代码操作 |
| `<leader>cl` | LSP 引用面板（Trouble） |
| `<leader>cL` | LSP 汇总面板（定义+引用+实现+调用，信息全但较慢） |
| `<leader>xx` / `<leader>xX` | 诊断面板（全部 / 当前文件） |
| `<leader>xL` / `<leader>xQ` | 位置列表 / quickfix 面板 |
| `[q` / `]q` | 上 / 下一个诊断或 quickfix 项 |

> 若提示「当前缓冲区没有 LSP 客户端」，说明对应 server 没起来：
> `:Mason` 看是否安装、`:LspInfo` 看是否附着、`:checkhealth vim.lsp` 看报错。

### 3.6 插件自带 / 其它

| 键 / 命令 | 功能 |
| --- | --- |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | mini.move：左/下/上/右移动当前行或选区 |
| `ga` / `gA`（可视模式） | mini.align：对齐选区 / 带预览对齐 |
| `#RRGGBB` 色值 | 自动显示颜色块（mini.hipatterns） |
| `s` / `S` / `r` / `R` | flash 跳转（普通 / treesitter / 操作符模式远程 / treesitter 搜索） |
| `:MarkdownPreview` | Markdown 浏览器预览（首次需 `:MarkdownPreviewInstall`） |
| `:ConformInfo` | 查看当前 buffer 用到的格式化器 |
| `:Mason` / `:Lazy` / `:checkhealth` | 插件与 LSP 状态 |

---

## 4. 本次重构修了什么

| # | 问题 | 原因 | 修法 |
| --- | --- | --- | --- |
| 1 | clangd 的**形参提示（inlay hint）是白色**，和注释区分不开 | 主题覆盖用了 `nvim_set_hl(0, g, { bg = "NONE" })`，那是**整体替换**，把 `LineNr`/`Normal` 的前景色一起清成 nil → 白色；而 everforest 里 `LspInlayHint → InlayHints → LineNr`，于是提示也变白 | `config/highlight.lua`：改成非破坏式覆盖（只改 bg），并把 `LspInlayHint` 的前景色固定为 **Comment 的灰色**（换主题自动跟随） |
| 2 | 跳转后回不去，只能手动翻 | 其实 `<C-o>` 可用，但原实现没写 tagstack（`<C-t>` 用不了），且键位说明缺失 | `util/jump.lua` 同时写 jumplist + tagstack；README 明确写出 `<C-o>`/`<C-i>`/`<C-t>` |
| 3 | `<leader>ce/cd/cG/cl/c[/c]` 感觉有 bug | 这些键本身是好的，但在「没有 LSP 客户端 / server 不支持该能力 / 没有结果」时**完全静默**；`<leader>cl` 用的 Trouble `lsp` 聚合模式一次发 7 类请求、跟着 CursorHold 刷新，大文件会卡；`gt` 被占用导致标签页导航失效 | `util/lsp.lua` 统一加提示；`cl` 改为只查引用（聚合模式挪到 `cL`）；`gt` 还给标签页，类型定义改到 `<leader>ct` |
| 4 | 每次 `:w` / `:wq` 都自动格式化，改坏代码 | `conform.nvim` 的 `format_on_save` | 去掉 `format_on_save`，改为 `<leader>cf` 主动触发（可视模式支持选区） |

另外顺手修掉的问题：

- **nvim-treesitter 整块失效（两个原因叠加）**：
  1. 分支问题：原配置锁定的是重写版 `main` 分支，但用的是旧版 master 的 API
     （`nvim-treesitter.configs` 在 main 分支不存在）；
  2. 入口问题：只写 `opts` 时 lazy.nvim 会调用 `require("nvim-treesitter").setup(opts)`，
     而 master 分支的这个 `setup()` **不接收参数**（只注册 `:TSInstall` 等命令），
     于是 `ensure_installed` / `highlight.enable` / `indent.enable` 被静默丢弃
     （实测：`get_ensure_installed_parsers() = {}`、`highlight.enable = false`、parser 数 = 0）。
  现在：显式 `branch = "master"` + 显式 `config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end`，
  语法高亮、缩进、折叠、彩虹括号一并恢复。安装 parser 需要 `tree-sitter` CLI（`brew install tree-sitter-cli`）。
- `nvim-cmp` 没把补全能力（snippet）发给 LSP 服务器 → 已加 `cmp_nvim_lsp.default_capabilities()`。
- telescope 的 `load_extension("fzf")` 没做保护，fzf-native 编译失败会连带
  `live_grep_args` / `projects` / `todo-comments` 全失效 → 改为逐个 pcall 并提示。
- 删掉了 45 行基于 `vim.lsp._enabled_configs` 私有 API 的“懒加载兜底启动”代码：
  nvim 0.12 的 `vim.lsp.enable()` 会自动处理已打开的缓冲区。
- 删掉了 nixvim 遗留的无用自定义事件（`CookLazy` / `LazyFile`），保留仍被使用的 `DeferredUIEnter`。
- 废弃 API 清理：`nvim_get_hl_by_name` → `nvim_get_hl`，`vim.highlight.on_yank` → `vim.hl.on_yank`。
- 拆分了原来 308 行的 `plugins/lsp.lua` 与塞了 8 个插件的 `plugins/misc.lua`。

---

## 5. 依赖（mason 装不了的格式化器 / 工具）

```sh
# brew
brew install shfmt shellcheck shellharden clang-format taplo yamlfmt

# npm（需要 node）
npm i -g prettier prettierd

# rustup / cargo
rustup component add rustfmt
cargo install typstyle

# go
go install golang.org/x/tools/cmd/goimports@latest

# python
pipx install cmakelang ruff
```

Markdown 浏览器预览首次使用前执行 `:MarkdownPreviewInstall`。

---

## 6. 常见问题

**Q：打开文件后没有语法高亮？**
先 `:TSInstall c cpp lua python rust` 手动补装 parser（master 分支的 `ensure_installed` 会在启动时自动补，
首次装可能较慢），`:checkhealth nvim-treesitter` 可看状态。

**Q：LSP 没反应 / 没有补全？**
`:Mason` 确认服务器已安装；`:LspInfo` 看当前 buffer 是否附着；`:checkhealth vim.lsp` 看具体报错。
mason 的 bin 目录由 mason 自动加入 PATH，无需手动配置。

**Q：格式化没反应？**
`<leader>cf` 依赖对应语言的 formatter 在 PATH 中；`:ConformInfo` 会列出当前 buffer 用到的
formatter 以及是否找到。

**Q：形参提示太多想关掉？**
`<leader>sh`。

**Q：想临时改配置不污染仓库？**
把本地改动写进 `lua/plugins/local.lua`（已在 `.gitignore` 中忽略）。

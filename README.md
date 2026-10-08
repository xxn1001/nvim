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
├── AGENTS.md                   # ★ 给「以后来维护的 agent / 人」的维护手册（坑 + 验证方法）
├── scripts/
│   └── healthcheck.lua         # ★ 一键自检（20 项，覆盖所有历史 bug 的回归）
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

改完配置后自检（改坏了会明确告诉你是哪一项）：

```sh
cd ~/.config/nvim
nvim --headless "+luafile scripts/healthcheck.lua"
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
| `<leader>wv` / `<leader>ws` | **垂直分屏（左右）/ 水平分屏（上下）** |
| `<leader>wd` / `<leader>wo` | 关闭当前窗口 / 只保留当前窗口 |
| `<leader>ww` / `<leader>w=` | 切到下一个窗口 / 所有窗口等宽等高 |
| `<leader>wH` `wJ` `wK` `wL` | 把**当前窗口**挪到最 左/下/上/右（不是分屏；只有一个窗口时会提示先分屏） |
| `<C-Up>` `<C-Down>` `<C-Left>` `<C-Right>` | 调整窗口大小 |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | 聚焦 左/下/上/右 窗口（详见 3.7） |
| `<leader>qs` / `<leader>ql` / `<leader>qd` | 恢复会话 / 恢复上次会话 / 本次不保存会话 |
| `<leader>fp` | 切换项目 |
| `<leader><tab>` 等 | 见 which-key 弹窗 |

### 3.2 编辑

| 键 | 功能 |
| --- | --- |
| `j` / `k` | 上下移动（软换行下按显示行移动） |
| `<A-j>` / `<A-k>` | 上移 / 下移当前行（可视模式=选区），并自动重排缩进 |
| `<A-h>` / `<A-l>` | 减少 / 增加缩进（可视模式=整块左右移动） |
| `cs` / `ds` / `ys` | nvim-surround：改 / 删 / 加环绕（普通模式；可视模式见 3.3 的 `S`） |
| `]c` / `[c` | 跳到下 / 上一个 git 修改块 |
| `<leader>hp` / `<leader>hi` | 预览 hunk / 行内预览 hunk |
| `<leader>hb` / `<leader>ht` / `<leader>hw` | blame 弹窗 / 切换行内 blame / 单词差异 |
| `<leader>hd` / `<leader>hD` | 与索引 / 与 HEAD 比较 |
| `<leader>hq` / `<leader>hQ` | 当前文件 / 全部变更进 quickfix |
| `ih`（可视/操作符模式） | 选择 git hunk |
| `s` / `S` | flash 跳转 / flash treesitter 跳转（**`S` 仅普通模式**） |
| `zR` / `zM` | 展开全部折叠 / 折叠全部 |
| `K` | 查看折叠内容，否则显示悬浮文档 |
| `<leader>ss` / `<leader>sd` / `<leader>sh` | 拼写检查 / 语法诊断 / 形参提示(inlay hint) 开关 |
| `<leader>cs` | 符号面板（Aerial） |

### 3.3 可视模式速查（先选中，再按键）

选中文本后可以对它做的操作：

| 键 | 功能 |
| --- | --- |
| **`S`** | **包裹选中文本**，然后输入配对符：`}` `)` `]` `"` `'` `` ` ``… 例：选中 `foo` 按 `S}` → `{foo}` |
| `gS` | 同上，但把内容换行包起来。例：`gS}` → `{` 换行 `foo` 换行 `}` |
| `<leader>cf` | **只格式化选中的行**（不碰选区外） |
| `<A-j>` / `<A-k>` | 选区整体上移 / 下移（自动重排缩进） |
| `<A-h>` / `<A-l>` | 选区整体左移 / 右移 |
| `gc` | 注释 / 取消注释选区（Neovim 内置） |
| `>` / `<` | 增加 / 减少缩进（内置，`gv` 可保持选中继续操作） |
| `ga` / `gA` | mini.align 对齐选区 / 带预览对齐 |
| `s` / `S`（X 模式） | flash 跳转 |

用 surround 的完整写法（按 `S` 进入待输入状态后可以给更多信息）：

| 输入 | `foo` 的结果 | 说明 |
| --- | --- | --- |
| `S}` | `{foo}` | 大括号 |
| `S)` `S]` `S>` | `(foo)` `[foo]` `<foo>` | 其它配对符 |
| `S"` `S'` `` S` `` | `"foo"` `'foo'` `` `foo` `` | 引号 |
| `Stdiv<CR>` | `<div>foo</div>` | HTML/XML 标签；`t` 之后输入标签名再回车 |
| `Sth1 id="x"<CR>` | `<h1 id="x">foo</h1>` | 标签可以带属性 |

> 完整的别名表（函数包裹 `f`、自定义配对 `i` 等）见 `:help nvim-surround`；
> 上面只列了本仓库实测过的写法。
>
> 普通模式下的环绕键保持原样：`ys{motion}` 加环绕、`cs` 改环绕、`ds` 删环绕
> （例：`ysiw}` 给当前单词包大括号、`cs"'` 把双引号改成单引号、`ds"` 删掉双引号）。
>
> ⚠️ **取舍**：可视模式的 `S` 原来被 flash.nvim 占作「treesitter 搜索」；为了能直接包裹选中
> 文本，现在可视模式的 `S` 归 nvim-surround（这是更常用的操作）。flash 的跳转 `s`、
> 操作符模式的 `r`/`R` 都不受影响。

### 3.4 格式化（★ 本次改为主动触发）

| 键 | 功能 |
| --- | --- |
| `<leader>cf` | **格式化**（普通模式=整个文件，可视模式=选区） |

> 保存（`:w` / `:wq`）**不会**再自动格式化。原来的 `format_on_save` 会在每次保存时
> 跑 ruff_fix / goimports / clang-format 等，可能删掉未使用的 import / include 或
> 重排头文件，多次保存下来会改坏代码，所以改成只在你按 `<leader>cf` 时执行。

### 3.5 跳转（★ 返回上一个位置）

| 键 | 功能 |
| --- | --- |
| `gd` / `gD` / `gI` | 跳转到 定义 / 声明 / 实现 |
| `<leader>ct` | 跳转到类型定义（原来是 `gt`，已把 `gt` 还给“下一个标签页”） |
| **`<C-o>`** | **返回上一个跳转位置**（可连按，一路回退） |
| `<C-i>` | 前进到下一个跳转位置 |
| `<C-t>` | 标签栈返回（跳转前的位置） |

> 跳转函数（`lua/util/jump.lua`）会同时写入 jumplist 和 tagstack，所以上面三个返回键都可用。
> 光标在符号上时用 `<C-o>` 返回是最快的，不需要手动翻文件。

### 3.6 LSP

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

### 3.7 窗口 / 面板之间切换焦点

| 键 | 功能 |
| --- | --- |
| **`<C-h>` `<C-j>` `<C-k>` `<C-l>`** | **聚焦 左 / 下 / 上 / 右 的窗口**（文件树、Trouble 面板、分屏通用） |
| `<C-w>w` | 在所有窗口之间循环切换 |
| `<C-w>p` | 回到上一个窗口 |
| `<C-w>c` / `<C-w>o` | 关闭当前窗口 / 只保留当前窗口 |
| `<C-h/j/k/l>`（终端里） | 直接从终端窗口跳到相邻窗口（不用先按 `<Esc><Esc>`） |

三种常用面板的进出方式：

| 场景 | 怎么进去 | 怎么回到代码区 | 备注 |
| --- | --- | --- | --- |
| 文件树 `<leader>e` | `<leader>e` | **`<C-l>`** 或 `q` | 树里 `<CR>` 打开文件并自动回到代码窗口；`s` 垂直分屏、`S` 水平分屏、`t` 新标签打开；树窗口内 `<space>` 被禁用，所以额外给树加了 `<leader>e` = 关闭文件树 |
| Trouble `<leader>cl` | `<leader>cl` | 焦点**本来就留在代码区**（面板在右侧，`focus=false`） | 按 **`<C-l>`** 进面板浏览，`j`/`k` 移动、`<CR>` 跳到对应位置并关闭、`o` 跳过去但保留面板、`<C-v>` 垂直分屏打开、`q` 关闭面板 |
| Telescope `<leader>ci`/`cG`/`ff`… | `<leader>ci` 等 | **`<Esc>`** 直接关闭并回到代码 | 焦点在搜索框（插入模式）：`<C-n>`/`<C-p>` 上下选择、`<CR>` 打开选中项 |
| LSP 跳转 `gd`/`gD` | — | `<C-o>` 返回、`<C-i>` 前进 | 见 3.4 |

### 3.8 插件自带 / 其它

| 键 / 命令 | 功能 |
| --- | --- |
| `<A-h>` / `<A-l>` | 减少 / 增加缩进；可视模式下整块左右移动（mini.move） |
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
| 5 | **按 `<CR>` 不自动缩进**（C/C++ 尤其明显，每行都顶格） | treesitter 的 indent 模块把 `indentexpr` 换成 `nvim_treesitter#indent()`，而 master 分支在新版 nvim 上解析 c/cpp 的 `indents.scm`（用到 `#not-kind-eq?` 谓词）时报 `query_predicates.lua:106: attempt to call method 'type' (a nil value)` → `indentexpr` 抛异常 → 缩进算成 0 | `lua/plugins/treesitter.lua` 里 `indent = { enable = false }`，交给 Neovim 内置 indent 脚本（`indent/c.vim`+cindent、python、go、lua…）。实测逐行缩进与老配置完全一致（C++ 0/4/8/12…） |
| 6 | 函数补全后**残留的形参删不掉**（如 `kill(a, int sig)` 里的 `int sig`） | clangd 的函数补全带 snippet 占位符 `kill(${1:__pid_t pid}, ${2:int sig})`，**占位符是真实文本**；而配置里 `<Tab>` 只映射到 cmp 的「选下一个候选」，菜单关掉后 cmp 会 fallback 成插入 Tab —— 没有任何键能跳到下一个占位符 | `lua/plugins/completion.lua`：`<Tab>`/`<S-Tab>` 变为「补全菜单 → snippet 占位符跳转 → 主动补全 → 原生行为」，并以 `cmp.mapping.preset.insert()` 为基底（顺带找回 `<C-n>/<C-p>/<C-y>/<C-e>`）。活体实测：`kill(a, int sig)` 按 `<Tab>` → 选中 `int sig` → 输入 `b` → `kill(a, b)` |
| 7 | 每次算折叠都报 `E5108: attempt to index field 'ufo'` | 老配置（nixvim 时代旧版 ufo）留下的 `foldmethod=expr` + `foldexpr=v:lua.vim.ufo.foldexpr()`；而 nvim-ufo 源码里**既没有 `vim.ufo` 也没有 `foldexpr`**，它靠 `foldtext` 接管折叠 | `config/options.lua` 删除这两行（ufo 官方最小配置只需要 `foldlevel`/`foldlevelstart`/`foldenable`），实测 `foldexpr` 恢复默认、`foldmethod=manual`、`zR`/`zM` 正常、无报错 |
| 8 | 打开含代码块的 **markdown 文件反复报错**：`vim/treesitter.lua:197: attempt to call method 'range' (a nil value)`（栈里是 `query_predicates.lua:141` → `#set-lang-from-info-string!`） | nvim-treesitter **master 分支**（官方已冻结）注册的自定义 directive 与 nvim 0.12 的 query API 不兼容：`match[capture_id]` 不再是裸 TSNode，插件仍当成节点调用 `:range()` | **整体迁移到 main 分支**（详见下节）。main 不再注册任何自定义 predicate/directive，markdown 注入直接用 nvim 内置的 `@injection.language` 捕获 → 结构性问题消失 |
| 9 | **选中一段文本后没法用快捷键包裹**（例如给选区包上大括号）：按 `S` 没反应 | `plugins/editing.lua` 里 nvim-surround 写成 `keys = { "cs", "ds", "ys" }`，而 lazy.nvim 对**字符串形式的键位只在普通模式**注册懒加载触发（`value.mode = value.mode or "n"`），可视模式下插件根本没被加载；同时 flash.nvim 把可视模式的 `S` 占作 treesitter 搜索 → 按 `S` 进了 flash 搜索 | 可视模式单独声明 `{ "S", mode = "x" }` / `{ "gS", mode = "x" }`（**每个键必须单独一个 table**，否则第 2 个元素会被当成 rhs）。实测 `viwS}` → `{foo}`、`viwS)` → `(foo)`、`VgS}` 换行包裹；顺带确认 `<leader>cf` 可视模式只格式化选中行（上下相邻行不受影响） |

### 为什么 nvim-treesitter 用 main 分支（而不是 master）

`master` 已被官方**冻结**，而它的三处实现与 nvim 0.12 不兼容，且不会再修：

| 现象 | master 的根因 | main 的情况 |
| --- | --- | --- |
| 按 `<CR>` 不缩进（C/C++ 顶格） | `#not-kind-eq?` → `query_predicates.lua:106` `attempt to call method 'type'` | main 不自注册 predicate |
| 含代码块的 markdown 刷屏报错 | `#set-lang-from-info-string!` → `query_predicates.lua:141` `attempt to call method 'range'` | main 用 nvim 内置 `@injection.language` 捕获 |
| 启动弹 latex 安装失败（`--no-bindings`） | install.lua 写死了被 CLI ≥0.26 移除的参数 | main 用 `tree-sitter generate/build`，兼容新版 CLI |

迁移后的落地方式（已实测）：

- `branch = "main"` + `lazy = false`（main 官方声明不支持懒加载）+ `build = ":TSUpdate"`
- `require("nvim-treesitter").setup({ install_dir = stdpath("data").."/site" })`：
  该目录会被**前置**到 `runtimepath`，因此插件安装的 parser/queries **优先于** nvim 自带的同名文件
  （实测 `parser/lua.so` 查找顺序：`site` → 旧 master 目录 → nvim 自带；旧的 master parser 不再干扰）
- `require("nvim-treesitter").install({...})` 安装 37 个 parser（异步，已装则跳过）
- 高亮改由 nvim 原生提供：`FileType` autocmd 里 `pcall(vim.treesitter.start, ev.buf)`
- 缩进仍交给 Neovim 内置 indent 脚本（main 的 TS indent 也还是 experimental，不用）
- `jsonc` 在 main 里已并入 `json`：用 `vim.treesitter.language.register("json", "jsonc")` 兼容

> **要求**：`tree-sitter` CLI ≥ 0.26.1（`brew install tree-sitter-cli`；你机器上已是 0.26/0.27 ✅）。

另外顺手修掉的问题：

- **nvim-treesitter 整块失效（两个原因叠加）**：
  1. 分支问题：原配置锁定的是重写版 `main` 分支，但用的是旧版 master 的 API
     （`nvim-treesitter.configs` 在 main 分支不存在）；
  2. 入口问题：只写 `opts` 时 lazy.nvim 会调用 `require("nvim-treesitter").setup(opts)`，
     而 master 分支的这个 `setup()` **不接收参数**（只注册 `:TSInstall` 等命令），
     于是 `ensure_installed` / `highlight.enable` / `indent.enable` 被静默丢弃
     （实测：`get_ensure_installed_parsers() = {}`、`highlight.enable = false`、parser 数 = 0）。
  现在：显式 `branch = "master"` + 显式 `config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end`，
  语法高亮、折叠、彩虹括号一并恢复（**缩进模块仍故意关闭**，原因见上表第 5 条）。
  安装 parser 需要 `tree-sitter` CLI（`brew install tree-sitter-cli`）。
- `config/autocmds.lua` 里两处 FileType autocommand 用了同一个 `augroup(..., { clear = true })`，
  第二次 `clear` 会把第一处删掉 → `formatoptions` 的 `c`/`r` 没被移除（注释会自动续行）。
  现在 group 只创建一次，两处共用。
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

**Q：按 `<CR>` 不自动缩进 / 缩进不对？**
本配置**故意关闭了 treesitter 的缩进模块**（`lua/plugins/treesitter.lua` 里 `indent = { enable = false }`）。
原因：开启后它会把 `indentexpr` 换成 `nvim_treesitter#indent()`，而 master 分支解析 c/cpp 的
`indents.scm`（含 `#not-kind-eq?` 谓词）时在新版 nvim 上抛
`query_predicates.lua:106: attempt to call method 'type' (a nil value)`，异常导致缩进直接算成 0 ——
表现就是"每行 Enter 后都顶格"。关掉后改用 Neovim 自带的 indent 脚本（cindent / python / go / lua…），
行为与老配置逐行一致。

自检方式（进入某个 buffer 后）：

```vim
:lua print(vim.bo.filetype, "indentexpr=", vim.bo.indentexpr, "cindent=", vim.bo.cindent)
" C/C++ 期望： indentexpr= (空)  cindent=true
" 若看到 indentexpr=nvim_treesitter#indent()，说明缩进模块又被打开了
```

**Q：报错 `module 'nvim-treesitter.configs' not found`（或 `nvim-treesitter.config`）？**
module 名取决于**插件所在的分支**，与 nvim 版本无关：

| 分支 | 实际文件 | 入口函数 | 说明 |
| --- | --- | --- | --- |
| `master`（本配置 `branch = "master"` 锁定） | `lua/nvim-treesitter/configs.lua` | `require("nvim-treesitter.configs").setup(opts)` | parser 自动安装 + 高亮 + 缩进，功能完整 |
| `main`（官方重写版） | `lua/nvim-treesitter/config.lua` | `require("nvim-treesitter.config").setup(opts)` | 其 `setup()` 源码里**只处理 `install_dir`**，`ensure_installed`/`highlight`/`indent` 会被静默忽略；main 也没有 `highlight` 模块，高亮要自己 `FileType → vim.treesitter.start()` |

⚠️ 所以停在 main 分支时**不会报错，但 treesitter 实际是死的**（parser 不装、高亮不开）—— 这是最难排查的状态。
旧配置锁的就是 main，`~/.local/share/nvim/lazy/nvim-treesitter` 很可能还停在 main。执行
`:Lazy sync`（或 `:Lazy restore`）切到 master；确认方式：

```vim
:lua print(vim.fn.system("git -C " .. vim.fn.stdpath("data") .. "/lazy/nvim-treesitter branch --show-current"))
" 期望输出 master
```

本配置已经做了兜底：万一插件仍在 main 分支，启动时会用 `vim.treesitter.start()` 打开高亮，
并弹出一条警告提示你切分支（不会像以前那样悄无声息）。

**Q：启动时弹窗报 `nvim-treesitter[latex]: Error during "tree-sitter generate"`（unexpected argument '--no-bindings'）？**
如果你还看到这个，说明**插件目录仍停在 master 分支**（旧配置遗留）：

| tree-sitter CLI | master 的 `--no-bindings` |
| --- | --- |
| 0.23 / 0.24 / 0.25 | ✅ |
| 0.26 / 0.27 | ❌ 已移除 → master 每次启动都会重试安装 latex 并弹错 |

本配置已迁移到 **main 分支**（见上文「为什么用 main 分支」），main 用 `tree-sitter generate/build`，
新版 CLI 完全正常，latex 也能装。执行一次即可切过去：

```vim
:Lazy sync        " 或 :Lazy restore —— 会按 lazy-lock.json 切到 main 并重装 parser 到 stdpath('data')/site
```

**Q：LSP 没反应 / 没有补全？**
`:Mason` 确认服务器已安装；`:LspInfo` 看当前 buffer 是否附着；`:checkhealth vim.lsp` 看具体报错。
mason 的 bin 目录由 mason 自动加入 PATH，无需手动配置。

**Q：函数补全后括号里残留形参（例如 `kill(a, int sig)` 里的 `int sig`）删不掉？**
这是 clangd 的 snippet 占位符（`kill(${1:__pid_t pid}, ${2:int sig})`），占位符是真实文本。
正确用法：**填完第一个参数后按 `<Tab>`** 跳到下一个占位符（内容会被选中），直接输入即可替换；
`<S-Tab>` 往回跳。`printf` 只有一个形参，所以只有它"看起来没问题"。

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| 想完全不出现形参占位符，只要 `kill()` 并把光标停进括号 | `--function-arg-placeholders` | 配置里 clangd 已经是 `false`；若仍出现，说明本地 clangd 版本不认这个参数或有 `.clangd`/项目配置覆盖，用 `:LspInfo` 看实际 cmdline，或在项目根 `.clangd` 里写 `Completion: { ArgumentPlaceholders: false }` |
| `<Tab>` 不跳转 | 旧配置没有 snippet 跳转映射 | 已修（`lua/plugins/completion.lua`），用 `scripts/healthcheck.lua` 可回归验证 |

**Q：格式化没反应？**
`<leader>cf` 依赖对应语言的 formatter 在 PATH 中；`:ConformInfo` 会列出当前 buffer 用到的
formatter 以及是否找到。

**Q：形参提示太多想关掉？**
`<leader>sh`。

**Q：想临时改配置不污染仓库？**
把本地改动写进 `lua/plugins/local.lua`（已在 `.gitignore` 中忽略）。

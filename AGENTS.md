# AGENTS.md —— 给维护这份 Neovim 配置的 agent

本文件面向「以后来改这个仓库的 AI / 人」。**先读 `README.md`（用户手册 + 快捷键表），再读本文件（维护手册）。**

---

## 0. 环境与约束

- 目标平台：**macOS**（用户主力机）；要求 **Neovim >= 0.12**
- 插件管理：lazy.nvim，版本锁 `lazy-lock.json`（**必须入库**，保证换机可复现）
- 仓库：`git@github.com:xxn1001/nvim`，分支 `main`；配置目录 `~/.config/nvim`
- 注释与提交信息用**中文**；代码风格跟随现有文件（2 空格缩进）

## 1. 目录职责（改东西只改对应文件）

| 想改什么 | 改哪里 |
| --- | --- |
| 编辑器选项 | `lua/config/options.lua` |
| 全局键位 | `lua/config/keymaps.lua` |
| 自动命令 | `lua/config/autocmds.lua` |
| 主题 / 透明背景 / 高亮 | `lua/plugins/colorscheme.lua` + `lua/config/highlight.lua` |
| LSP 服务器增删与参数 | `lua/config/lsp-servers.lua` |
| LSP 运行逻辑（能力 / 诊断 / inlay hint / 跳转键） | `lua/config/lsp.lua` |
| LSP 键位与插件声明 | `lua/plugins/lsp.lua` |
| 补全 / snippet 行为 | `lua/plugins/completion.lua` |
| 格式化 | `lua/plugins/conform.lua` + `lua/util/format.lua` |
| 跳转（jumplist/tagstack） | `lua/util/jump.lua` |
| LSP 动作的提示反馈 | `lua/util/lsp.lua` |
| 插件清单 | `lua/plugins/*.lua`（一个功能域一个文件） |

## 2. 改完必须跑的自检

```sh
cd ~/.config/nvim
nvim --headless "+luafile scripts/healthcheck.lua"
```

共 20 项，覆盖本项目所有历史 bug 的回归（高亮、自动缩进、手动格式化、跳转返回、treesitter 分支与 markdown 注入、
snippet 跳转、插件/nvim API 清单、键位齐全等）。退出码 `0` = 全部通过，`1` = 有失败项。

## 3. 已踩过的坑（**不要重犯**）

1. **不要设置 `foldexpr = "v:lua.vim.ufo.foldexpr()"`**
   nvim-ufo 源码里既没有 `vim.ufo` 也没有 `foldexpr` 函数 → 每次计算折叠都报
   `E5108: attempt to index field 'ufo' (a nil value)`。ufo 是靠 `foldtext` 接管的，
   官方最小配置只需要 `foldlevel` / `foldlevelstart` / `foldenable`。
2. **nvim-treesitter 必须用 `branch = "main"`（不要再回 master）**
   master 已被官方**冻结**，它的实现与 nvim 0.12 的 query API 不兼容，且不会再修 ——
   本项目在 master 上连续踩了三个坑（都是结构性、无法在配置里根治，最后整体迁移）：
   - `#not-kind-eq?` → `query_predicates.lua:106 attempt to call method 'type'`：indentexpr 抛异常，
     C/C++ 按 `<CR>` 缩进归零；
   - `#set-lang-from-info-string!` → `query_predicates.lua:141 attempt to call method 'range'`：
     **含代码块的 markdown 文件反复刷屏报错**（栈底是 render-markdown）；
   - `install.lua` 写死 `tree-sitter generate --no-bindings`，而 CLI ≥ 0.26 已移除该参数 →
     每次启动重试安装 latex 并弹错。
   main 分支：不注册任何自定义 predicate/directive（用 nvim 内置 `@injection.language` 捕获）、
   安装走 `tree-sitter generate/build`。落地要点（都已实测）：
   ```lua
   branch = "main", lazy = false, build = ":TSUpdate"   -- main 官方声明不支持懒加载
   require("nvim-treesitter").setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
   require("nvim-treesitter").install({ ... })           -- 异步，已装则跳过
   vim.treesitter.language.register("json", "jsonc")     -- main 已无独立 jsonc parser
   vim.api.nvim_create_autocmd("FileType", { callback = function(ev) pcall(vim.treesitter.start, ev.buf) end })
   ```
   - **不要再写 `ensure_installed` / `highlight` / `indent`**：这些是 master 的 opts；
     main 的 `setup()` 只认 `install_dir`，其余靠上面的显式 API。
   - parser/queries 装在 `stdpath("data")/site`，该目录被**前置**到 rtp，所以优先于 nvim 自带
     以及 lazy 插件目录里的旧文件（实测 `parser/lua.so` 顺序：site → 旧 master 目录 → 自带），
     从 master 迁过来**不需要**手动清理旧的 parser/*.so。
   - 要求 `tree-sitter` CLI ≥ 0.26.1（`brew install tree-sitter-cli`），缺了装不了 parser。
3. **treesitter 的 indent（缩进）继续用 Neovim 内置脚本**
   main 的 TS indent 仍是 experimental，且历史坑极多（见第 2 条）。`indentexpr` 应为空，
   由 `indent/c.vim`+cindent / python / go / lua 等内置脚本负责；healthcheck 有回归检查。
4. **不要用 `nvim_set_hl(0, g, { bg = "NONE" })` 表达「只改背景」**
   那是整体替换语义，会把 fg 一起清空（`Normal` / `LineNr` 变白）；everforest 里
   `LspInlayHint → InlayHints → LineNr`，于是形参提示也变白。
   请用 `config/highlight.lua` 的 `clear_bg()`（读出现有定义 → 只改 bg → 写回）。
5. **`augroup(name, { clear = true })` 同一个 group 只能调用一次**
   调用两次，第二次会把第一次注册的 autocmd 删掉（曾导致 `formatoptions` 的 `c`/`r`
   没被移除、注释自动续行）。
6. **不要给 conform 打开 `format_on_save`**
   用户明确要求手动格式化：保存时跑 ruff_fix / goimports / clang-format 会删 import、
   重排 include，多次保存会改坏代码。格式化统一走 `<leader>cf`（`util/format.lua`）。
7. **`<Tab>` 必须兼顾 snippet 占位符**
   clangd 的函数补全可能带 `${1:...}` 占位符（例如
   `kill(${1:__pid_t pid}, ${2:int sig})`），**占位符是真实文本**。
   只映射 cmp 的 `select_next_item` 会导致「填完第一个形参后，`int sig` 留在缓冲区里删不掉」。
   现在 `<Tab>` / `<S-Tab>` 依次尝试：补全菜单 → `luasnip.expand_or_locally_jumpable()` →
   `cmp.complete()` → fallback；并且以 `cmp.mapping.preset.insert()` 为基底，
   否则会丢掉 `<C-n>` / `<C-p>` / `<C-y>` / `<C-e>`。
8. **LSP 动作要有反馈**：telescope 的 call hierarchy 在「不支持 / 无结果」时完全静默，
   用户会以为键坏了。统一用 `util/lsp.lua` 的 `guard()` / `call_hierarchy()` 包一层提示。
9. **`gt` 是内置的「下一个标签页」**，不要拿去做 LSP 跳转（类型定义在 `<leader>ct`）。
10. **远端可能有人工提交**：push 前先 `git fetch`，`git rebase origin/main` 后再 push，
    **禁止 force push**（会毁掉用户自己的提交）。

## 4. 怎么验证（沙箱套路）

本机没有 macOS，但可以完整复现。用隔离的 XDG 目录 + 软链接指向仓库（保证测的是真实文件）：

```sh
mkdir -p /tmp/nt/{config,share,state,cache}
ln -s "$PWD" /tmp/nt/config/nvim          # 在仓库根目录执行
export XDG_CONFIG_HOME=/tmp/nt/config XDG_DATA_HOME=/tmp/nt/share \
       XDG_STATE_HOME=/tmp/nt/state XDG_CACHE_HOME=/tmp/nt/cache
PATH=/tmp/nvim/bin/bin:$PATH

nvim --headless "+Lazy! sync" +qa                       # 首次装插件
cd /tmp/nt/config/nvim
nvim --headless "+luafile scripts/healthcheck.lua"      # 自检
```

常用技巧：

- **headless 里 `+luafile` 执行期间的按键不会被处理**：`feedkeys(keys, "x")` 能同步执行，
  但结束时**会退出插入模式**。需要「插入模式下的连续按键」时，用
  `vim.defer_fn(step, ms)` 分步 + `nvim_feedkeys(keys, "", false)`：每个 step 在主循环执行，
  上一步排队的按键会被真正处理。
- **`nvim_get_mode()` 在命令执行期间会误报 `n`**，要在 defer 回调里读才准。
- **假 LSP server**：`vim.lsp.start({ name = "fake", cmd = function(dispatchers) ... end })`
  可返回固定的 definition / references / prepareCallHierarchy / completion 结果，
  用于验证 `<leader>ce/cd/cG/c[/c]` 这类需要 LSP 的键位。
- **真 clangd**：`sudo apt-get install -y clangd`；测补全用
  `vim.lsp.buf_request_sync(0, "textDocument/completion", params, 8000)` 读 `insertText`
  / `insertTextFormat`；`--function-arg-placeholders=false` 会返回 `kill($0)`，
  `true` 则返回 `kill(${1:__pid_t pid}, ${2:int sig})`。
- **treesitter 分支兼容测试**：直接 `git -C <lazy>/nvim-treesitter checkout main|master` 各跑一遍。
- 插件源码就在 `~/.local/share/nvim/lazy/<plugin>/`，拿不准 API 时先读源码再改。

## 5. 提交规范

- 中文 commit message：`type(scope): 一句话总结`，空行，然后写**根因 / 证据 / 验证方式**。
- 一次提交只做一件事；修 bug 必须写清「怎么复现、怎么验证的」，最好附上实测输出。
- 改了键位 → 同步更新 `README.md` 的快捷键表（用户靠它认功能）。
- 新增修复 → 在 `scripts/healthcheck.lua` 里补一条回归检查。
- 流程：`git fetch` → `git rebase origin/main` → `git push`。

## 6. 已知的「非 bug」（想改先问用户）

- **全局没有设置 `expandtab`**（沿用老配置）：由 vim-sleuth 按文件内容探测，
  新文件（没有缩进线索时）默认用 Tab 缩进。
- **`<C-s>` 保存**：部分终端默认把 Ctrl-S 当流控（XOFF）吞掉，需要在 shell 里 `stty -ixon`。
- **`s` / `S` 被 flash.nvim 占用**：内置的「替换字符 / 整行替换」被覆盖（老配置即如此）。
- **cmp `sources` 顺序**是 `buffer` → `path` → `luasnip` → `nvim_lsp`，buffer 可能排在 LSP 前面。
- **markdown-preview 首次使用需要 `:MarkdownPreviewInstall`**；LuaSnip 的 `jsregexp`
  未编译（可选组件，只影响少数正则类 snippet）。
- **拼写检查全局开启**（`spell = true`，含 `cjk`），用 `<leader>ss` 临时关闭。

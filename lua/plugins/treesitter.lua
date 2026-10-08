-- Treesitter 语法高亮 —— 使用 nvim-treesitter 的 **main** 分支（官方重写版 / 默认分支）
--
-- ============================ 为什么从 master 迁到 main ============================
-- master 分支已被官方冻结，它的自定义 predicate/directive 与 nvim 0.12 的 query API 不兼容，
-- 实测踩到过三个坑（都在 master 上无法修复，因为不再更新）：
--   1. 缩进：c/cpp 的 indents.scm 用 #not-kind-eq? → query_predicates.lua:106
--      `attempt to call method 'type' (a nil value)` → indentexpr 抛异常 → 按 <CR> 缩进归零
--   2. markdown：#set-lang-from-info-string! → query_predicates.lua:141
--      `attempt to call method 'range' (a nil value)` → 含代码块的 md 文件反复报错刷屏
--   3. 安装：install.lua 写死 `tree-sitter generate --no-bindings`，而 CLI >= 0.26 移除了该参数
--      → 每次启动重试安装 latex 并弹错
--
-- main 分支：
--   * 不再注册任何自定义 predicate/directive（markdown 注入直接用 nvim 内置的
--     `@injection.language` 捕获），上面前两个问题结构性消失
--   * 安装走 `tree-sitter generate` / `tree-sitter build`（不带 --no-bindings），与新版 CLI 兼容
--   * 官方声明「不支持懒加载」，所以必须 lazy = false
--
-- 要求：Neovim >= 0.12 + tree-sitter CLI >= 0.26.1（brew install tree-sitter-cli）
-- 说明：main 不再有 highlight / indent 模块——高亮由 nvim 原生 vim.treesitter.start() 提供，
--       缩进继续交给 Neovim 内置 indent 脚本（cindent / python / go / lua…），见 options.lua。
-- =================================================================================

--- 需要安装的 parser（main 的 parsers.lua 里已没有 jsonc，改为把 json 注册给 jsonc 文件类型）
local PARSERS = {
  "bash", "fish", "python", "yaml", "lua", "json", "nix",
  "regex", "toml", "vim", "markdown", "markdown_inline",
  "glsl", "css", "scss", "html", "hyprlang",
  "c", "cpp", "rust",
  "go", "gomod", "gowork",
  "javascript", "typescript", "tsx",
  "latex", "typst",
  "cmake", "make", "dockerfile",
  "diff", "git_config", "gitignore",
  "sql", "graphql",
  "query",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- main 官方明确「不支持懒加载」
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      -- install_dir 会被**前置**到 runtimepath，从而优先于 nvim 自带的同名 parser/queries。
      -- 默认值就是 stdpath('data')/site，这里写出来是为了让行为一目了然。
      ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

      -- jsonc 文件类型复用 json 语法（main 已移除独立的 jsonc parser）
      vim.treesitter.language.register("json", "jsonc")

      -- 安装 parser：异步执行，已装过的会被跳过（等价于旧配置的 ensure_installed）。
      -- main 依赖 tree-sitter CLI 来构建，缺了会直接报错，所以先检测并给一次性提示。
      if vim.fn.executable("tree-sitter") == 1 then
        ts.install(PARSERS)
      else
        vim.notify_once(
          "未找到 tree-sitter CLI，无法自动安装 treesitter parser。\n请先 `brew install tree-sitter-cli`，然后执行 :TSUpdate",
          vim.log.levels.WARN
        )
      end

      -- 高亮：main 不再提供 highlight 模块，按官方文档用 FileType autocmd 开 nvim 原生高亮。
      -- 没有对应 parser 的文件类型会报错，用 pcall 兜住（退回正则语法高亮）。
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("config.treesitter", { clear = true }),
        desc = "开启 nvim 原生 treesitter 高亮",
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },
  {
    -- 自带 queries，不依赖 nvim-treesitter
    "HiPhish/rainbow-delimiters.nvim",
    lazy = false,
  },
}

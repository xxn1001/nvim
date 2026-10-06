-- Treesitter 语法高亮
--
-- 【修复】nvim-treesitter 的默认分支已经改成重写版 main（master 被官方标记为锁定分支）。
-- main 分支要求 nvim >= 0.12 + tree-sitter-cli + C 编译器，且 API 完全不同
-- （没有 nvim-treesitter.configs）。原配置写的是旧版 master 的 API，却拉到了 main 分支，
-- 结果 `require("nvim-treesitter.configs")` 直接 module not found：
--   * 语法高亮没有生效（悄悄退回老式正则 syntax）
--   * ensure_installed 里的 parser 一个都没装（实测 parser 数 = 0）
--   * ufo 折叠 / rainbow-delimiters 也一起退化
-- 这里显式锁定 master 分支（官方仍维护、兼容 0.11 / 0.12）。
--
-- 【第二处修复】还必须写显式 config：
-- lazy.nvim 对只写 opts 的插件会推断模块并调用 require("nvim-treesitter").setup(opts)，
-- 但 master 分支的 nvim-treesitter.setup() 是不接收参数的（只注册 :TSInstall 等命令），
-- 于是 opts 被静默丢弃 —— 实测 highlight.enable = false、ensure_installed = {}。
-- 正确的入口是 nvim-treesitter.configs.setup(opts)。
--
-- ⚠️ 注意 module 名：master 分支是 configs（复数），main 分支才是 config（单数）。
-- 两个分支的文件名实测如下：
--   master: lua/nvim-treesitter/configs.lua  存在，config.lua   不存在
--   main  : lua/nvim-treesitter/config.lua   存在，configs.lua 不存在
-- 所以 branch = "master" 时必须写 configs；写成 config 会 module not found，
-- 结果是语法高亮全丢、parser 不安装。
-- 如果你看到 “module 'nvim-treesitter.configs' not found”，多半是本地插件目录
-- 还停留在 main 分支（旧配置遗留），执行 :Lazy sync（或 :Lazy restore）让它切到 master。
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
    opts = {
      auto_install = false,
      ensure_installed = {
        "bash", "fish", "python", "yaml", "lua", "json", "nix",
        "regex", "toml", "vim", "markdown", "markdown_inline", "jsonc",
        "glsl", "css", "scss", "html", "hyprlang",
        "c", "cpp", "rust",
        "go", "gomod", "gowork",
        "javascript", "typescript", "tsx",
        "latex", "typst",
        "cmake", "make", "dockerfile",
        "diff", "git_config", "gitignore",
        "sql", "graphql",
        "query",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  {
    -- 新版无 setup API，靠自身 FileType autocmd 附着；常驻避免错过第一个 buffer
    "HiPhish/rainbow-delimiters.nvim",
    lazy = false,
  },
}

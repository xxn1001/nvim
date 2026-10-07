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
-- ⚠️ 注意 module 名取决于**插件所在的分支**（不是 nvim 版本）：
--   master: lua/nvim-treesitter/configs.lua  存在，config.lua   不存在
--           → require("nvim-treesitter.configs").setup(opts)  ← 本配置走这条
--   main  : lua/nvim-treesitter/config.lua   存在，configs.lua 不存在
--           → require("nvim-treesitter.config").setup(opts)
-- 两个分支的 setup 语义完全不同：main 的 config.setup() 源码里只处理 install_dir
-- 一个字段，ensure_installed / highlight / indent 会被静默忽略，而且 main 没有
-- highlight 模块（高亮要自己 FileType → vim.treesitter.start()），
-- 所以停在 main 上不会报错、但 treesitter 实际是死的。
-- 如果你看到 “module 'nvim-treesitter.configs' not found”，说明本地插件目录还停在
-- main（旧配置遗留），执行 :Lazy sync / :Lazy restore 切到 master 即可。
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function(_, opts)
      -- 正常路径：master 分支，功能完整（parser 自动安装 + 高亮 + 缩进）
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok and type(configs.setup) == "function" then
        configs.setup(opts)
        return
      end

      -- 兜底路径：插件目录停在 main 分支时，至少把高亮打开，并明确告知怎么修，
      -- 避免出现“没有报错但语法高亮全没了”这种最难排查的状态。
      local ok_main, main = pcall(require, "nvim-treesitter.config")
      if ok_main and type(main.setup) == "function" then
        main.setup({})
        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("config.treesitter_main_fallback", { clear = true }),
          desc = "main 分支兜底：开启 treesitter 高亮",
          callback = function()
            pcall(vim.treesitter.start)
          end,
        })
        vim.notify(
          "nvim-treesitter 当前处于 main 分支，但本配置按 master 编写：\n"
            .. "ensure_installed（parser 自动安装）和缩进不会生效。\n"
            .. "请执行 :Lazy sync 或 :Lazy restore 切回 master；详见 README 常见问题。",
          vim.log.levels.WARN
        )
        return
      end

      vim.notify("nvim-treesitter 未安装或结构异常，请执行 :Lazy sync", vim.log.levels.ERROR)
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

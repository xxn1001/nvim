-- 格式化：conform.nvim
--
-- 【修复】已移除 format_on_save。
-- 原配置 { format_on_save = { timeout_ms = 600, lsp_fallback = true } } 会在每次
-- :w / :wq 时自动格式化：ruff_fix / ruff_organize_imports / goimports 会删除未使用的
-- import，clang-format 会重排合并 include，多次保存下来会把代码改坏。
-- 现在只在主动按 <leader>cf 时格式化（普通模式=整个文件，可视模式=选区）。
--
-- 依赖：格式化器命令需在 PATH 中；mason 装不了的部分见 README.md
return {
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>cf",
        function()
          require("util.format").format()
        end,
        mode = { "n", "v" },
        desc = "格式化（可视模式=选区）",
      },
    },
    opts = {
      notify_on_error = true,
      formatters_by_ft = {
        bash = { "shfmt", "shellcheck", "shellharden" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        cmake = { "cmake_format" },
        css = { "prettierd", "prettier" },
        scss = { "prettierd", "prettier" },
        html = { "prettierd", "prettier" },
        go = { "goimports" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd" },
        lua = { "stylua" },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        rust = { "rustfmt" },
        toml = { "taplo" },
        yaml = { "yamlfmt" },
        typst = { "typstyle" },
      },
    },
  },
}

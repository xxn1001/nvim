-- 格式化封装
--
-- 【修复】原配置在 conform 里设置了 format_on_save，
-- 于是每次 :w / :wq 都会自动格式化（ruff_fix / goimports / clang-format 等
-- 会重排甚至删除 import 与 include），多次下来改坏代码。
-- 现在改为完全主动触发：<leader>cf（普通模式=整个文件，可视模式=选区）。

local M = {}

--- 手动格式化当前缓冲区 / 选区
---@param opts? table 透传给 conform.format 的额外参数
function M.format(opts)
  local ok, conform = pcall(require, "conform")
  if not ok then
    vim.notify("conform.nvim 尚未加载，无法格式化", vim.log.levels.WARN)
    return
  end

  -- 可视模式下 conform 会自己识别 range，这里不需要额外处理
  conform.format(vim.tbl_extend("force", {
    async = true,
    lsp_format = "fallback", -- 该文件类型没有配置 formatter 时退回 LSP 格式化
    timeout_ms = 1500,
  }, opts or {}))
end

return M

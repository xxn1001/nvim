-- LSP 插件声明与键位
--
--   * 服务器清单 / 覆盖配置：lua/config/lsp-servers.lua
--   * 运行逻辑（能力、诊断、inlay hint、gd 跳转）：lua/config/lsp.lua
--   * 键位的反馈封装：lua/util/lsp.lua

local lsp_util = require("util.lsp")
local servers = require("config.lsp-servers")

--- 调用 telescope picker（lazy.nvim 会按需加载 telescope）
---@param picker string
---@return fun()
local function telescope(picker)
  return function()
    vim.cmd("Telescope " .. picker)
  end
end

return {
  {
    "mason-org/mason.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    -- 注意：这里必须填 nvim-lspconfig 的服务器名（不是 mason 包名），
    -- mason-lspconfig 内部会映射到对应的 mason 包自动安装
    opts = {
      ensure_installed = servers.enabled,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    event = "VeryLazy",
    -- 说明：这些键通过 guard() 包了一层，遇到“没有 LSP 客户端 / 服务器不支持该能力”
    -- 会明确提示，而不是像原来那样静默无反应（详见 lua/util/lsp.lua）
    keys = {
      { "<leader>ci", lsp_util.guard("textDocument/implementation", "查找实现", telescope("lsp_implementations")), desc = "查找实现" },
      { "<leader>cG", lsp_util.guard("textDocument/references", "查找引用", telescope("lsp_references")), desc = "查找引用" },
      { "<leader>cw", lsp_util.guard("workspace/symbol", "查找工作区符号", telescope("lsp_workspace_symbols")), desc = "查找工作区符号" },
      { "<leader>co", lsp_util.guard("textDocument/documentSymbol", "文件大纲", telescope("lsp_document_symbols")), desc = "文件大纲" },
      { "<leader>c[", function() lsp_util.call_hierarchy("incoming") end, desc = "被调列表（谁调用了它）" },
      { "<leader>c]", function() lsp_util.call_hierarchy("outgoing") end, desc = "调用列表（它调用了谁）" },
      { "<leader>ce", telescope("diagnostics bufnr=0"), desc = "当前文件诊断" },
      { "<leader>cW", telescope("diagnostics"), desc = "全局诊断" },
      { "<leader>cd", lsp_util.diagnostic_float, desc = "当前行诊断浮窗" },
      { "<leader>cR", lsp_util.guard("textDocument/rename", "重命名符号", function() vim.lsp.buf.rename() end), desc = "重命名符号" },
      { "<leader>ca", lsp_util.guard("textDocument/codeAction", "代码操作", function() vim.lsp.buf.code_action() end), desc = "代码操作" },
      -- 类型定义跳转是全局键位，定义在 lua/config/lsp.lua（原来的 gt，已还给标签页）
    },
    config = function()
      require("config.lsp").setup()
    end,
  },
}

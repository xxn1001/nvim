-- LSP 核心逻辑（由 lua/plugins/lsp.lua 的 config() 调用）
--
-- 相比原 lua/plugins/lsp.lua（308 行单文件）拆成三块：
--   config/lsp.lua         —— 运行逻辑（本文件）
--   config/lsp-servers.lua —— 服务器清单与覆盖配置（数据表）
--   plugins/lsp.lua        —— 插件声明与键位

local M = {}

function M.setup()
  -- 1. 客户端能力：ufo 折叠 + nvim-cmp 补全 --------------------------------
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument = capabilities.textDocument or {}
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  -- 【修复】原配置没有把 cmp 的能力发给服务器，导致 LSP 补全缺少 snippet 支持
  local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end
  vim.lsp.config("*", { capabilities = capabilities })

  -- 2. 服务器 ---------------------------------------------------------------
  local servers = require("config.lsp-servers")
  for name, cfg in pairs(servers.overrides) do
    vim.lsp.config(name, cfg)
  end
  vim.lsp.enable(servers.enabled)
  -- 注：nvim >= 0.12 的 vim.lsp.enable() 内部会对已打开的缓冲区重放 FileType 事件，
  -- 所以原配置里那段 45 行基于 vim.lsp._enabled_configs 私有 API 的
  -- “懒加载竞态兜底启动”已经没有必要，已删除。

  -- 3. 诊断外观（全局设置一次；原配置每次 LspAttach 都重设一遍）-------------
  vim.diagnostic.config({
    virtual_text = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    signs = {
      active = true,
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "💡",
      },
    },
    float = {
      border = "rounded",
      source = true,
    },
  })

  -- 4. inlay hint（clangd 的形参名提示，颜色见 config/highlight.lua）--------
  -- nvim 内部已经注册了 LspAttach 钩子，这里全局开一次即可
  --（原配置每 attach 一个缓冲区就调一次 enable，属多余）
  vim.lsp.inlay_hint.enable(true)

  -- 5. 跳转键位 -------------------------------------------------------------
  -- 【修复】gt 在 Vim 里是“下一个标签页”，原配置把它占为“跳转类型定义”，
  -- 导致标签页导航不可用；这里 gt 还给内置行为，类型定义改到 <leader>ct。
  -- 返回上一个跳转位置用内置的 <C-o>（前进 <C-i>，标签栈 <C-t>），
  -- 跳转工具 util/jump.lua 已经保证这些都能用。
  local jump = require("util.jump")
  vim.keymap.set("n", "gd", jump.lsp("definition", "跳转到定义"), { desc = "跳转到定义" })
  vim.keymap.set("n", "gD", jump.lsp("declaration", "跳转到声明"), { desc = "跳转到声明" })
  vim.keymap.set("n", "gI", jump.lsp("implementation", "跳转到实现"), { desc = "跳转到实现" })
  vim.keymap.set("n", "<leader>ct", jump.lsp("type_definition", "跳转到类型定义"), { desc = "跳转到类型定义" })
end

return M

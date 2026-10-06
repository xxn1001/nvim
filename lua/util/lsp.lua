-- LSP 相关封装
--
-- 【修复】原配置里 <leader>c 这一组在“没有 LSP 客户端 / 服务器不支持 / 没有结果”时
-- 是完全静默的（telescope 的 call hierarchy 直接 return，诊断浮窗什么都不做），
-- 用起来像坏了。这里为每个动作补上明确反馈。

local M = {}

--- 当前缓冲区附着的 LSP 客户端
---@param method? string 只返回支持该方法的客户端
---@param bufnr? integer
---@return vim.lsp.Client[]
function M.clients(method, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if method then
    return vim.lsp.get_clients({ bufnr = bufnr, method = method })
  end
  local all = vim.lsp.get_clients({ bufnr = bufnr })
  return all
end

--- 统一前置检查：把“静默失败”变成一句明确的提示
---@param method string LSP 方法名，如 "textDocument/rename"
---@param label string 功能名
---@param fn fun() 检查通过后执行的动作
---@return fun()
function M.guard(method, label, fn)
  return function()
    local bufnr = vim.api.nvim_get_current_buf()
    if #M.clients(method, bufnr) > 0 then
      fn()
      return
    end
    if #M.clients(nil, bufnr) == 0 then
      vim.notify(label .. "：当前缓冲区没有 LSP 客户端（服务可能未启动）", vim.log.levels.WARN)
    else
      vim.notify(label .. "：当前 LSP 服务器不支持该功能", vim.log.levels.WARN)
    end
  end
end

--- 当前行诊断浮窗：没有诊断时给出提示，而不是什么都不发生
function M.diagnostic_float()
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
  if #vim.diagnostic.get(0, { lnum = lnum }) == 0 then
    vim.notify("本行没有诊断信息（<leader>ce 可查看整个文件）", vim.log.levels.INFO)
    return
  end
  vim.diagnostic.open_float({ scope = "line", border = "rounded" })
end

--- 调用层级（<leader>c[ 被调 / <leader>c] 调用）
--- telescope 自己的实现遇到“不支持 / 无结果”是直接 return 的，
--- 这里先做一次很便宜的预检（prepareCallHierarchy 是本地操作），
--- 确认有结果再交给 telescope 的 picker 展示。
---@param direction "incoming"|"outgoing"
function M.call_hierarchy(direction)
  local bufnr = vim.api.nvim_get_current_buf()
  local label = direction == "incoming" and "被调用列表" or "调用列表"
  local clients = M.clients("textDocument/prepareCallHierarchy", bufnr)
  if #clients == 0 then
    M.guard("textDocument/prepareCallHierarchy", label, function() end)()
    return
  end

  local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding)
  vim.lsp.buf_request_all(bufnr, "textDocument/prepareCallHierarchy", params, function(results)
    local found = false
    for _, res in pairs(results) do
      if res.result and #res.result > 0 then
        found = true
        break
      end
    end
    if not found then
      vim.notify(label .. "：光标处没有可查询调用层级的符号（请停在函数名上）", vim.log.levels.INFO)
      return
    end
    local picker = direction == "incoming" and "lsp_incoming_calls" or "lsp_outgoing_calls"
    vim.cmd("Telescope " .. picker)
  end)
end

return M

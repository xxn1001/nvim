-- LSP 跳转工具：去重 + 单结果直跳 / 多结果选择
--
-- 【修复】原实现 (dedupe_jump) 只做了 `normal! m'`，那只写了 jumplist，
-- 没有写 tagstack，所以 <C-t> 回不到跳转前的位置。这里补上 settagstack，
-- 同时保留原有 jumplist 行为：
--   <C-o>  回到上一个位置（可连续按）
--   <C-i>  前进到下一个位置
--   <C-t>  走标签栈回退

local M = {}

--- 把当前位置压入 tagstack（与 nvim 官方 vim.lsp.util.show_document 一致）
local function push_tagstack()
  local from = { vim.fn.bufnr("%"), vim.fn.line("."), vim.fn.col("."), 0 }
  local items = { { tagname = vim.fn.expand("<cword>"), from = from } }
  vim.fn.settagstack(vim.fn.win_getid(), { items = items }, "t")
end

---@param item vim.quickfix.entry
local function jump_to(item)
  local bufnr = item.bufnr or vim.fn.bufadd(item.filename)
  vim.bo[bufnr].buflisted = true
  vim.cmd("normal! m'") -- jumplist：<C-o> / <C-i> 可用
  push_tagstack() -- tagstack：<C-t> 可用
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.api.nvim_win_set_cursor(0, { item.lnum, math.max((item.col or 1) - 1, 0) })
  vim.cmd("normal! zv") -- 展开目标处折叠
end

--- 生成一个 LSP 跳转函数
---@param method string vim.lsp.buf 上的方法名，如 "definition"
---@param label string 提示文案
---@return fun()
function M.lsp(method, label)
  return function()
    vim.lsp.buf[method]({
      on_list = function(olist)
        -- 同一个位置可能被多个 server / 多次返回，先去重
        local seen, items = {}, {}
        for _, item in ipairs(olist.items) do
          local key = ("%s:%d:%d"):format(item.filename or "", item.lnum or 0, item.col or 0)
          if not seen[key] then
            seen[key] = true
            items[#items + 1] = item
          end
        end

        if #items == 0 then
          vim.notify(label .. "：没有找到位置", vim.log.levels.INFO)
          return
        end

        if #items == 1 then
          jump_to(items[1])
          return
        end

        vim.ui.select(items, {
          prompt = label .. "：选择目标",
          format_item = function(item)
            return ("%s:%d:%d"):format(vim.fn.fnamemodify(item.filename or "", ":~:."), item.lnum or 0, item.col or 0)
          end,
        }, function(choice)
          if choice then
            jump_to(choice)
          end
        end)
      end,
    })
  end
end

return M

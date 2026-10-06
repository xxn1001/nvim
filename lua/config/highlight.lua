-- 高亮微调
--
-- 【修复】原配置用 vim.api.nvim_set_hl(0, group, { bg = "NONE" }) 来“只改背景”，
-- 但那其实是整体替换语义：只给了 bg，该组原有的 fg / bold 等属性全部被清空。
-- 结果 Normal / LineNr / CursorLineNr / WinBar / StatusLine 全变成终端默认色（白），
-- 而 everforest 的高亮链是  LspInlayHint → InlayHints → LineNr，
-- 于是 clangd 的形参名 inlay hint（f(key: a, value: b) 里的 key:）也变成白色，
-- 和注释的灰色完全区分不开。
--
-- 现在改成：
--   1) 主窗口 / 状态栏的透明交给 everforest 的 transparent_background = 2，
--      不再重复覆盖（原来 18 个组里有 12 个本来就是透明的，纯属多余且有害）；
--   2) 确实需要透明的浮层用“读出原定义 → 只改 bg → 写回”的非破坏式覆盖；
--   3) 明确把 LspInlayHint 的前景色设成 Comment 的灰色，换主题也会自动跟随。

local M = {}

--- 需要透明背景的浮层（保留前景色）
local transparent_groups = {
  "NormalFloat",
  "FloatBorder",
  "Pmenu",
  "PmenuSbar",
  "PmenuThumb",
}

--- 只清除背景，保留前景 / 粗体 / 斜体等属性
---@param group string
local function clear_bg(group)
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
  if vim.tbl_isempty(hl) then
    return
  end
  hl.bg = "NONE"
  vim.api.nvim_set_hl(0, group, hl)
end

--- inlay hint（形参提示）与注释同色
local function grey_inlay_hints()
  local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
  local inlay = vim.api.nvim_get_hl(0, { name = "LspInlayHint", link = false })
  vim.api.nvim_set_hl(0, "LspInlayHint", {
    fg = comment.fg or 0x859289, -- everforest 的 grey1，仅作兜底
    bg = inlay.bg,
    italic = false,
  })
end

function M.apply()
  for _, group in ipairs(transparent_groups) do
    clear_bg(group)
  end
  grey_inlay_hints()
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("config.highlight", { clear = true }),
  desc = "主题切换后重新应用高亮微调",
  callback = M.apply,
})

-- 主题加载之前先应用一次（ColorScheme 触发时会用新主题的颜色重算）
M.apply()

return M

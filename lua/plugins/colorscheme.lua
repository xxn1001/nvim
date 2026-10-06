-- 主题：everforest（透明背景）
return {
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_transparent_background = 2 -- 主窗口 + 状态栏透明
      vim.cmd.colorscheme("everforest")
      -- 注意：浮层透明与 LspInlayHint 灰色化统一放在 lua/config/highlight.lua。
      -- 原配置在这里用 nvim_set_hl(0, g, { bg = "NONE" }) 逐个覆盖 18 个高亮组，
      -- 那是整体替换语义，会把前景色一并清空（行号/状态栏/形参提示全变白），
      -- 详见 config/highlight.lua 顶部说明。
    end,
  },
}

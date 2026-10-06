-- 自动命令

local augroup = vim.api.nvim_create_augroup

-- 复制高亮 ------------------------------------------------------------------
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("config.yank", { clear = true }),
  desc = "复制时短暂高亮",
  callback = function()
    -- 0.11+ 推荐 vim.hl.on_yank，旧版本回退
    local on_yank = vim.hl and vim.hl.on_yank or vim.highlight.on_yank
    on_yank({ timeout = 500 })
  end,
})

-- 文本 / Markdown ------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("config.filetype", { clear = true }),
  desc = "注释不自动换行",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("config.filetype", { clear = true }),
  desc = "文档类文件自动软换行，并把中文标点作为断行点",
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakat:append("，。！？；：")
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- 通知背景色跟随主题 --------------------------------------------------------
vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup("config.notify", { clear = true }),
  desc = "nvim-notify 背景色跟随 Normal",
  callback = function()
    local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
    bg = bg and string.format("#%06x", bg) or "#000000"
    vim.api.nvim_set_hl(0, "NotifyBackground", { bg = bg })
  end,
})

-- nixvim 遗留的 DeferredUIEnter 事件：UI 类插件（noice/bufferline/gitsigns/ibl）用它延迟加载
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("config.deferred_ui", { clear = true }),
  desc = "触发 DeferredUIEnter（等价 nixvim 内部事件）",
  once = true,
  callback = function()
    vim.schedule(function()
      vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter" })
    end)
  end,
})

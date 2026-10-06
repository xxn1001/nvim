-- ============================================================================
-- Neovim 配置入口
--
-- 目录结构：
--   lua/config/   纯设置与逻辑（options / keymaps / autocmds / highlight / lsp）
--   lua/plugins/  lazy.nvim 插件声明（一个功能域一个文件）
--   lua/util/     可复用小工具（jump / lsp / format）
--
-- 要求：Neovim >= 0.12（brew install neovim）
-- ============================================================================

-- 1. 引导 lazy.nvim（首次启动自动克隆）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("lazy.nvim 克隆失败：请检查 git 是否可用、网络是否通畅")
  end
end
vim.opt.rtp:prepend(lazypath)

-- 2. 基础设置（不依赖任何插件，先加载）
require("config.globals")
require("config.options")
require("config.misc")
require("config.highlight") -- 高亮微调（含 LspInlayHint 灰色化），内部注册 ColorScheme 钩子
require("config.keymaps")
require("config.autocmds")

-- 3. 插件
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = { lazy = true },
  install = { colorscheme = { "everforest" } },
  change_detection = { notify = false },
  checker = { enabled = false },
})

-- 编辑器选项
-- 说明：这里的取值与原配置保持一致，只做归类与注释，避免重构改变手感。

-- 外观 ----------------------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.showmode = false -- 模式已在 lualine 上显示
vim.opt.termguicolors = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.scrolloff = 8
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.mouse = "a"

-- 编辑 ----------------------------------------------------------------------
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.undofile = true
vim.opt.inccommand = "split" -- 实时预览替换结果
vim.opt.updatetime = 250

-- 搜索 ----------------------------------------------------------------------
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false

-- 键位超时：略长一点，避免 which-key 还没弹出就超时
vim.opt.timeoutlen = 300

-- 拼写 ----------------------------------------------------------------------
vim.opt.spell = true
vim.opt.spelllang = { "en_us", "cjk" }
vim.opt.spellsuggest = "best,4"

-- 折叠（由 nvim-ufo 接管）---------------------------------------------------
-- 【修复】不要设置 foldmethod = "expr" / foldexpr = "v:lua.vim.ufo.foldexpr()"！
-- nvim-ufo 的源码里既没有 vim.ufo 这个全局，也没有 foldexpr 函数，
-- 那样写会在每次计算折叠时报：
--     E5108: Lua: attempt to index field 'ufo' (a nil value)
-- 这行是从老配置（nixvim 时代的旧版 ufo）继承下来的死代码。
-- ufo 官方最小配置只需要 foldlevel / foldlevelstart / foldenable，
-- 折叠方法由插件自己在 setup 时接管。
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99

-- 会话（persistence.nvim 使用）---------------------------------------------
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

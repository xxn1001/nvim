-- 全局键位（不依赖插件，或只依赖已声明的插件）
-- leader = 空格
--
-- 完整快捷键表见 README.md

local map = vim.keymap.set

-- 保存 / 退出 ----------------------------------------------------------------
map({ "i", "n", "v", "s" }, "<C-s>", "<Cmd>w<CR>", { silent = true, desc = "保存文件" })
map("n", "<leader>qq", "<cmd>wqa<cr>", { desc = "保存全部并退出" })
map("n", "Q", "<cmd>bd<cr>", { silent = true, desc = "关闭缓冲区" })

-- 格式化（【修复】不再在保存时自动格式化，改为主动触发）----------------------
-- <leader>cf 的映射声明在 lua/plugins/conform.lua（普通模式=整个文件，可视模式=选区）

-- 移动 ----------------------------------------------------------------------
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "下移（软换行友好）" })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "上移（软换行友好）" })

map("n", "<A-j>", ":m .+1<CR>==", { silent = true, desc = "向下移动行" })
map("n", "<A-k>", ":m .-2<CR>==", { silent = true, desc = "向上移动行" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true, desc = "向下移动选区" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true, desc = "向上移动选区" })

-- 全选
map({ "i", "n" }, "<C-a>", "<Cmd>normal! ggVG<CR>", { silent = true, desc = "全选" })

-- 窗口 ----------------------------------------------------------------------
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "增加窗口高度" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "减少窗口高度" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "减少窗口宽度" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "增加窗口宽度" })

map("n", "<leader>wH", "<C-w>H", { silent = true, desc = "窗口移到左边" })
map("n", "<leader>wJ", "<C-w>J", { silent = true, desc = "窗口移到底部" })
map("n", "<leader>wK", "<C-w>K", { silent = true, desc = "窗口移到顶部" })
map("n", "<leader>wL", "<C-w>L", { silent = true, desc = "窗口移到右边" })

-- 窗口之间切换焦点（文件树 / Trouble 面板 / 分屏 / 终端都用同一套）-------
-- 在文件树或 Trouble 面板里按 <C-l> 就能回到代码区
map("n", "<C-h>", "<C-w>h", { silent = true, desc = "聚焦左侧窗口" })
map("n", "<C-j>", "<C-w>j", { silent = true, desc = "聚焦下方窗口" })
map("n", "<C-k>", "<C-w>k", { silent = true, desc = "聚焦上方窗口" })
map("n", "<C-l>", "<C-w>l", { silent = true, desc = "聚焦右侧窗口" })
-- 在终端里也能直接跳到相邻窗口（不用先按 <Esc><Esc>）
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { silent = true, desc = "终端：聚焦左侧窗口" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { silent = true, desc = "终端：聚焦下方窗口" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { silent = true, desc = "终端：聚焦上方窗口" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { silent = true, desc = "终端：聚焦右侧窗口" })

-- 说明：窗口切换的其它内置键（无需配置）
--   <C-w>w  在所有窗口间循环
--   <C-w>p  回到上一个窗口
--   <C-w>c  关闭当前窗口      <C-w>o  只保留当前窗口

-- 缓冲区 --------------------------------------------------------------------
map("n", "<leader>bn", "<cmd>bnext<CR>", { silent = true, desc = "下一个缓冲区" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { silent = true, desc = "上一个缓冲区" })

-- 标签页 --------------------------------------------------------------------
map("n", "<leader><tab><tab>", "<cmd>tabnew<CR>", { silent = true, desc = "新建标签页" })
map("n", "<leader><tab>d", "<cmd>tabclose<CR>", { silent = true, desc = "关闭当前标签页" })
map("n", "<leader><tab>o", "<cmd>tabonly<CR>", { silent = true, desc = "关闭其他标签页" })
map("n", "<leader><tab>l", "<cmd>tabnext<CR>", { silent = true, desc = "下一个标签页" })
map("n", "<leader><tab>h", "<cmd>tabprevious<CR>", { silent = true, desc = "上一个标签页" })
-- 内置 gt / gT 保持原义（原配置把 gt 抢去做了“跳转类型定义”，见 config/lsp.lua 已改为 <leader>ct）

-- 终端 ----------------------------------------------------------------------
map("t", "<Esc><Esc>", "<C-\\><C-n>", { silent = true, desc = "终端回到 Normal 模式" })

-- 查询 / 开关 ---------------------------------------------------------------
map("n", "<leader>H", "<CMD>Telescope help_tags theme=ivy layout_config={height=0.4}<CR>", {
  silent = true,
  desc = "帮助文档查询",
})
map("n", "<leader>ss", "<cmd>set spell!<cr>", { silent = true, desc = "切换拼写检查" })
map("n", "<leader>sd", "<cmd>lua ToggleDiagnostics()<CR>", { silent = true, desc = "切换语法诊断" })
map("n", "<leader>sh", function()
  local on = not vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(on)
  vim.notify(on and "形参提示已开启" or "形参提示已关闭", vim.log.levels.INFO)
end, { desc = "切换形参提示 (inlay hint)" })

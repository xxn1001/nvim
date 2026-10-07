-- 配置自检脚本（无需任何外部依赖，headless 运行）
--
-- 用法：
--     cd ~/.config/nvim
--     nvim --headless "+luafile scripts/healthcheck.lua"
--
-- 退出码：0 = 全部通过；1 = 有检查项失败（便于 CI / 脚本调用）
--
-- 设计原则：只检查「曾经真的踩过的坑」和「配置的核心承诺」，
-- 每一项失败都附带排查提示。新增修复时，请在这里补一条回归检查。

local results = {}

---@param name string
---@param ok boolean
---@param hint? string
local function check(name, ok, hint)
  results[#results + 1] = { name = name, ok = ok, hint = hint }
  io.write(("%s %s\n"):format(ok and "✅" or "❌", name))
  if not ok and hint then
    io.write("     ↳ " .. hint .. "\n")
  end
end

--- 等一个条件成立
---@param ms integer
---@param fn fun(): boolean
local function wait_for(ms, fn)
  return vim.wait(ms, fn, 50)
end

-- 0. 启动期报错 ---------------------------------------------------------------
local messages = vim.fn.execute("messages")
check("启动无报错信息（E5108 / module not found 等）", not messages:match("E%d+:") and not messages:match("not found"),
  "messages 里出现错误：" .. messages:gsub("\n", " "):sub(1, 160))

-- 1. 插件 ----------------------------------------------------------------
local names = {}
for name in pairs(require("lazy.core.config").plugins) do
  names[#names + 1] = name
end
table.sort(names)
local load_fail = {}
for _, name in ipairs(names) do
  if not pcall(function()
    require("lazy").load({ plugins = { name } })
  end) then
    load_fail[#load_fail + 1] = name
  end
end
vim.wait(3000)
local not_loaded = {}
for _, name in ipairs(names) do
  if not require("lazy.core.config").plugins[name]._.loaded then
    not_loaded[#not_loaded + 1] = name
  end
end
check(("全部插件可加载（%d 个）"):format(#names), #load_fail == 0 and #not_loaded == 0,
  "加载报错: " .. table.concat(load_fail, ",") .. " 未加载: " .. table.concat(not_loaded, ","))

-- 2. 高亮：形参提示必须和注释同色（修复 #1）----------------------------------
vim.cmd("edit! /tmp/healthcheck_dummy.lua")
vim.wait(500)
local inlay = vim.api.nvim_get_hl(0, { name = "LspInlayHint", link = false })
local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
check("LspInlayHint 与 Comment 同色（形参提示灰色化）", inlay.fg ~= nil and inlay.fg == comment.fg,
  ("LspInlayHint.fg=%s Comment.fg=%s（检查 config/highlight.lua）"):format(tostring(inlay.fg), tostring(comment.fg)))
local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
check("Normal/LineNr 前景色没有被 bg=NONE 覆盖清空", normal.fg ~= nil,
  "Normal.fg 为 nil：config/highlight.lua 里不要用 nvim_set_hl(g, {bg='NONE'}) 整体替换")

-- 3. 格式化：不允许保存时自动格式化（修复 #4）--------------------------------
local conform_auto = 0
for _, ac in ipairs(vim.api.nvim_get_autocmds({ event = "BufWritePre" })) do
  if ac.group_name == "Conform" then
    conform_auto = conform_auto + 1
  end
end
check("conform 没有挂 BufWritePre 自动格式化（改为 <leader>cf 手动）", conform_auto == 0,
  "发现 " .. conform_auto .. " 个 Conform 的 BufWritePre autocmd：conform.lua 里别设 format_on_save")

-- 4. 缩进：treesitter indent 必须关闭（修复：Enter 不缩进）--------------------
vim.fn.writefile({ "int main(void) {", "    return 0;", "}" }, "/tmp/healthcheck_ind.c")
vim.cmd("edit! /tmp/healthcheck_ind.c")
vim.wait(800)
check("C 文件 indentexpr 未被 treesitter 接管", vim.bo.indentexpr == "",
  "indentexpr=" .. vim.bo.indentexpr .. "（plugins/treesitter.lua 里 indent 应为 enable=false）")
local before = vim.api.nvim_buf_get_lines(0, 0, -1, false)
vim.api.nvim_win_set_cursor(0, { 1, #before[1] })
vim.api.nvim_feedkeys(vim.keycode("A<CR>x"), "x", false)
vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "x", false)
vim.wait(200)
local got = vim.api.nvim_buf_get_lines(0, 0, -1, false)[2] or ""
vim.api.nvim_buf_set_lines(0, 0, -1, false, before)
check("C 文件按 <CR> 有自动缩进", #(got:match("^%s*") or "") > 0,
  "新行内容=[" .. got .. "]（应为缩进后的行）")

-- 5. 跳转：<C-o> 能回到跳转前（修复 #2）--------------------------------------
vim.fn.writefile({ "a1", "a2", "a3", "a4", "a5" }, "/tmp/healthcheck_a.txt")
vim.cmd("edit! /tmp/healthcheck_a.txt")
vim.api.nvim_win_set_cursor(0, { 5, 0 })
vim.cmd("normal! m'") -- 记录跳转前位置（jumplist）
vim.api.nvim_win_set_cursor(0, { 1, 0 })
vim.api.nvim_feedkeys(vim.keycode("<C-o>"), "x", false)
vim.wait(200)
check("<C-o> 能回到上一个跳转位置", vim.api.nvim_win_get_cursor(0)[1] == 5,
  "光标停在 " .. vim.api.nvim_win_get_cursor(0)[1] .. "（util/jump.lua 里要写 normal! m'）")

-- 6. treesitter ---------------------------------------------------------------
local branch = vim.fn.system("git -C " .. vim.fn.stdpath("data") .. "/lazy/nvim-treesitter branch --show-current 2>/dev/null"):gsub("%s", "")
check("nvim-treesitter 处于 master 分支", branch == "master",
  "当前分支=" .. branch .. "（执行 :Lazy sync；main 分支的 API 与本配置不兼容）")
check("nvim-treesitter.configs 入口可用", pcall(require, "nvim-treesitter.configs"),
  "master 分支入口是 nvim-treesitter.configs（复数）")
check("nvim-treesitter 的 indent 模块已关闭", (function()
  local ok, c = pcall(require, "nvim-treesitter.configs")
  return ok and c.get_module("indent").enable == false
end)(), "indent 必须为 false，否则 C/C++ 的缩进会归零")

-- 7. 补全：Tab 必须支持 snippet 占位符跳转 -----------------------------------
require("lazy").load({ plugins = { "nvim-cmp", "LuaSnip" } })
vim.wait(1500)
local cmp_conf = require("cmp.config").get()
local tab_handler = cmp_conf.mapping and cmp_conf.mapping["<Tab>"] and cmp_conf.mapping["<Tab>"].i
check("cmp 的 <Tab> 是自定义处理函数（菜单 → snippet → 补全）", type(tab_handler) == "function",
  "plugins/completion.lua 里 <Tab> 应使用 cmp.mapping(function(fallback) ... end)")
local ok_ls, ls = pcall(require, "luasnip")
check("LuaSnip 的占位符跳转 API 可用", ok_ls and type(ls.expand_or_locally_jumpable) == "function",
  "LuaSnip 未加载或版本过旧")
-- 注意：cmp 内部会把按键名规范化成大写（<C-n> → <C-N>），两边都要查
check("cmp 基础按键未被丢弃（<C-n>/<C-p>/<C-y>/<C-e>）", (function()
  for _, k in ipairs({ "<C-n>", "<C-p>", "<C-y>", "<C-e>" }) do
    if not (cmp_conf.mapping and (cmp_conf.mapping[k] or cmp_conf.mapping[k:upper()])) then
      return false
    end
  end
  return true
end)(), "plugins/completion.lua 应以 cmp.mapping.preset.insert() 为基底")

-- 8. 折叠：不要再引用不存在的 vim.ufo.foldexpr -------------------------------
check("foldexpr 未引用 vim.ufo（nvim-ufo 不提供该函数）", not vim.wo.foldexpr:match("vim%.ufo"),
  "当前 foldexpr=" .. vim.wo.foldexpr .. "（options.lua 里删掉 foldmethod=expr / foldexpr）")

-- 9. 关键键位 ----------------------------------------------------------------
local keys = {
  "<leader>cf", "<leader>sh", "<leader>co", "<leader>ct",
  "<leader>ce", "<leader>cd", "<leader>cG", "<leader>ci", "<leader>cw",
  "<leader>c[", "<leader>c]", "<leader>cR", "<leader>ca", "<leader>cl", "<leader>cL",
  "<leader>wv", "<leader>ws", "<leader>wd", "<leader>wo", "<leader>w=",
  "<leader>e", "<leader>ff", "<leader>ft", "<leader>fp", "<leader>qq",
  "gd", "gD", "gI", "<C-h>", "<C-j>", "<C-k>", "<C-l>",
}
local missing = {}
for _, k in ipairs(keys) do
  local m = vim.fn.maparg(k, "n", false, true)
  if not (m.callback or (m.rhs and m.rhs ~= "")) then
    missing[#missing + 1] = k
  end
end
check(("关键键位齐全（%d 个）"):format(#keys), #missing == 0, "缺失: " .. table.concat(missing, ", "))

-- 汇总 -----------------------------------------------------------------------
local failed = 0
for _, r in ipairs(results) do
  if not r.ok then
    failed = failed + 1
  end
end
io.write(("\n===== 自检结果：%d 项，失败 %d 项 =====\n"):format(#results, failed))
if failed > 0 then
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end

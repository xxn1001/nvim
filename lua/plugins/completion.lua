-- 补全：nvim-cmp + LuaSnip
--
-- 【修复】snippet 形参占位符跳不过去，残留的形参只能手动删。
--
-- clangd 在某些设置下会插入带占位符的函数补全，例如：
--     kill(${1:__pid_t pid}, ${2:int sig})
-- 占位符是**真实文本**：输入第一个参数后，第二个 `int sig` 就留在缓冲区里。
-- 原配置的 <Tab> 只映射成 cmp 的「选下一个候选」，补全菜单一关，
-- cmp 就 fallback 成插入一个 Tab —— 于是没有任何键能跳到下一个占位符，
-- 只能手动删。printf 之所以"看着没问题"，是因为它只有一个形参（只有一个占位符）。
--
-- 现在 <Tab> / <S-Tab> 会依次尝试：
--     补全菜单可见 → 上下选候选
--     在 snippet 里   → 跳到下一个/上一个占位符（内容自动选中，直接输入即替换）
--     光标前有内容    → 主动弹出补全
--     否则            → 原生行为
--
-- 另外两处改进：
--   * 以 cmp.mapping.preset.insert() 为基底，找回原配置漏掉的
--     <C-n> / <C-p> / <C-y> / <C-e>；
--   * 接上 nvim-autopairs 的 cmp 联动，避免函数补全已自带括号时又补一层。
--
-- 想让 clangd 完全不插形参占位符（只插 `kill($0)`，光标停在括号内）：
-- 见 lua/config/lsp-servers.lua 里 clangd 的 --function-arg-placeholders=false。
return {
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      --- 光标前是否有非空白字符（决定 Tab 要不要主动弹补全）
      local function has_words_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        if col == 0 then
          return false
        end
        local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        return text:sub(col, col):match("%s") == nil
      end

      local imapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump() -- 跳到下一个形参占位符
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1) -- 回到上一个形参占位符
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      })

      local cmapping = cmp.mapping.preset.cmdline({
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "c" }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "c" }),
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "c" }),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "c" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      })

      cmp.setup({
        sources = {
          { name = "buffer" },
          { name = "path" },
          { name = "luasnip" },
          { name = "nvim_lsp" },
        },
        mapping = imapping,
        window = {
          completion = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          },
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
      })

      cmp.setup.cmdline("/", {
        mapping = cmapping,
        sources = {
          { name = "buffer" },
        },
      })
      cmp.setup.cmdline(":", {
        mapping = cmapping,
        sources = {
          { name = "path" },
          { name = "cmdline" },
        },
      })

      -- nvim-autopairs 联动（插件是懒加载的，拿不到就跳过）
      local ok_ap, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
      if ok_ap then
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },
}

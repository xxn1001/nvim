-- 补全（原 coding/nixvim/blink.nix，配置的其实是 nvim-cmp）
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

      local imapping = {
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }
      local cmapping = {
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "c" }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "c" }),
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "c" }),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "c" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }

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
    end,
  },
}

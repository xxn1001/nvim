-- 基础 UI（bufferline / gitsigns / indent-blankline / colorizer / which-key）
-- markdown 渲染相关已拆分到 lua/plugins/markdown.lua
return {
  -- 图标（其它插件的公共依赖，常驻）
  { "nvim-tree/nvim-web-devicons", lazy = false },

  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "User DeferredUIEnter",
    opts = {},
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "User DeferredUIEnter",
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        changedelete = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        untracked = { text = "┆" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
      },
      preview_config = {
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local function map(mode, l, r, desc, opts)
          opts = opts or {}
          opts.buffer = bufnr
          if desc then
            opts.desc = desc
          end
          vim.keymap.set(mode, l, r, opts)
        end
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, "跳转到下一个修改块")
        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, "跳转到上一个修改块")
        map("n", "<leader>hp", gitsigns.preview_hunk, "预览Hunk(弹窗)")
        map("n", "<leader>hi", gitsigns.preview_hunk_inline, "行内预览Hunk")
        map("n", "<leader>hb", function()
          gitsigns.blame_line({ full = true })
        end, "显示blame弹窗信息")
        map("n", "<leader>hd", gitsigns.diffthis, "显示文件差异(索引)")
        map("n", "<leader>hD", function()
          gitsigns.diffthis("~")
        end, "显示文件差异(HEAD)")
        map("n", "<leader>hQ", function()
          gitsigns.setqflist("all")
        end, "所有Git变更到Quickfix")
        map("n", "<leader>hq", gitsigns.setqflist, "当前文件变更到Quickfix")
        map("n", "<leader>ht", gitsigns.toggle_current_line_blame, "切换行内blame显示")
        map("n", "<leader>hw", gitsigns.toggle_word_diff, "切换行内单词差异")
        map({ "o", "x" }, "ih", gitsigns.select_hunk, "选择Git hunk")
      end,
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "User DeferredUIEnter",
    -- v3 起模块为 ibl（带 - 的模块名只是报错桩），显式 config 使用 ibl
    config = function()
      require("ibl").setup {}
    end,
  },
  {
    "NvChad/nvim-colorizer.lua",
    event = "VeryLazy",
    opts = {
      user_default_options = {
        mode = "virtualtext",
        css = true,
        css_fn = true,
        names = false,
        virtualtext = "■",
        virtualtext_inline = true,
        virtualtext_mode = "foreground",
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<Leader>f", group = "查找 / Telescope" },
        { "<Leader>c", group = "代码 / LSP" },
        { "<Leader>h", group = "Git Hunk" },
        { "<Leader>w", group = "窗口" },
        { "<Leader>x", group = "Trouble / 诊断" },
        { "<Leader>s", group = "开关" },
        { "<Leader>q", group = "退出 / 会话" },
        { "<Leader><tab>", group = "标签页" },
      },
    },
  },
}

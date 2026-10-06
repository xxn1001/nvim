-- 文件树（原 coding/nixvim/neo-tree.nix）
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = { "Neotree" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal_force_cwd<cr>", desc = "打开/关闭文件树" },
    },
    opts = {
      window = {
        width = 30,
        mappings = {
          -- 文件树窗口里 <space> 被禁用，leader 键不会触发；
          -- 所以单独给文件树补一个 <leader>e = 关闭它（和外面的 toggle 行为一致）。
          ["<space>"] = "none",
          ["<leader>e"] = "close_window",
          -- <C-l> 由 config/keymaps.lua 统一映射为“聚焦右侧窗口”，即回到代码区
        },
      },
      add_blank_line_at_top = false,
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        group_empty_dirs = true,
        hijack_netrw = true,
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "",
            renamed = "",
            untracked = "",
            unstaged = "",
            staged = "",
            ignored = "",
            conflict = "",
          },
        },
      },
    },
  },
}

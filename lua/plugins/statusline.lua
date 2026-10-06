-- 状态栏（原 coding/nixvim/lualine.nix）
return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
      },
      sections = {
        lualine_a = {
          { "mode", fmt = function(s) return string.lower(s) end },
        },
        lualine_b = {
          { "branch", icon = "" },
          { "diff" },
        },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = " ",
              warn = " ",
              info = " ",
              hint = " ",
            },
          },
        },
        lualine_x = {
          { "filetype", colored = true },
        },
        lualine_y = {
          { "filename", file_status = true, path = 1 },
        },
        lualine_z = {
          { "location" },
        },
      },
    },
  },
}

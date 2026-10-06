-- mini.nvim 模块（原 coding/nixvim/mini.nix）
return {
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      require("mini.align").setup()
      require("mini.hipatterns").setup {
        highlighters = {
          hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
        },
      }
      require("mini.indentscope").setup()
      require("mini.move").setup {
        mappings = {
          left = "<C-h>",
          right = "<C-l>",
          up = "<C-k>",
          down = "<C-j>",
          line_left = "<C-h>",
          line_right = "<C-l>",
          line_up = "<C-k>",
          line_down = "<C-j>",
        },
      }
    end,
  },
}

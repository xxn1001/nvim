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
        -- 说明：<C-h/j/k/l> 已让给“窗口之间切换焦点”（见 config/keymaps.lua），
        -- 所以 mini.move 只用 <A-h>/<A-l> 做左右移动（普通模式=改缩进，可视模式=整块移动）。
        -- 上下移动仍由 config/keymaps.lua 的 <A-j>/<A-k> 负责（会带 = 自动重排缩进）。
        mappings = {
          left = "<A-h>",
          right = "<A-l>",
          up = "",
          down = "",
          line_left = "<A-h>",
          line_right = "<A-l>",
          line_up = "",
          line_down = "",
        },
      }
    end,
  },
}

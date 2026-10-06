-- Flash 跳转（原 coding/nixvim/flash.nix）
return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      {
        "s",
        function()
          require("flash").jump()
        end,
        mode = { "n", "x", "o" },
        desc = "flash跳转",
      },
      {
        "S",
        function()
          require("flash").treesitter()
        end,
        mode = { "n", "x", "o" },
        desc = "flash Treesitter跳转",
      },
      {
        "r",
        function()
          require("flash").remote()
        end,
        mode = "o",
        desc = "远程跳转",
      },
      {
        "R",
        function()
          require("flash").treesitter_search()
        end,
        mode = { "o", "x" },
        desc = "treesitter搜索",
      },
    },
  },
}

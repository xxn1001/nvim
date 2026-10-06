-- UI 通知/输入弹窗（原 coding/nixvim/noice.nix）
return {
  {
    "folke/noice.nvim",
    event = "User DeferredUIEnter",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      notify = {
        enabled = true,
        view = "notify",
      },
      lsp = {
        signature = { enabled = false },
        progress = { enabled = false },
        hover = { enabled = false },
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      timeout = 2000,
      background_colour = "#000000",
    },
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },
}

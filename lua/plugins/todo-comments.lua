-- TODO / FIXME 等注释标记
return {
  {
    "folke/todo-comments.nvim",
    lazy = false,
    opts = {
      signs = true,
    },
    keys = {
      { "<leader>ft", "<cmd>Telescope todo-comments todo theme=dropdown<cr>", desc = "TODO 查询" },
    },
  },
}

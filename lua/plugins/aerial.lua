-- 符号面板（原 coding/nixvim/aerial.nix）
return {
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle" },
    keys = {
      { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "切换符号面板(Aerial)" },
    },
    opts = {
      attach_mode = "global",
      show_guides = true,
      filter_kind = false,
      disable_max_lines = 5000,
      highlight_on_hover = true,
      backends = { "treesitter", "lsp", "markdown", "man" },
      ignore = {
        filetypes = { "gomod" },
      },
      layout = {
        position = "right",
        width = 30,
        min_width = 15,
      },
    },
  },
}

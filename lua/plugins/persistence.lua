-- 会话持久化（原 coding/nixvim/persistence.nix）
return {
  {
    "folke/persistence.nvim",
    event = { "BufReadPre" },
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "恢复会话 (Persistence)" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "恢复上次会话 (Persistence)" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "不保存此会话 (Persistence)" },
    },
  },
}

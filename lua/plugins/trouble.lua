-- Trouble：诊断 / 引用 / 位置列表侧栏
return {
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    keys = {
      {
        "[q",
        function()
          local trouble = require("trouble")
          if trouble.is_open() then
            trouble.previous({ skip_groups = true, jump = true })
          else
            vim.cmd.cprev()
          end
        end,
        desc = "上一个故障/快速修复项目",
      },
      {
        "]q",
        function()
          local trouble = require("trouble")
          if trouble.is_open() then
            trouble.next({ skip_groups = true, jump = true })
          else
            vim.cmd.cnext()
          end
        end,
        desc = "下一个故障/快速修复项目",
      },
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "诊断面板（全部）" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "诊断面板（当前文件）" },
      -- 【修复】原 <leader>cl 用的是 trouble 的 "lsp" 聚合模式：一次请求
      -- Definitions + References + Implementations + TypeDefs + Declarations + 双向 Calls
      -- 共 7 类结果，并且挂在 CursorHold 上跟随刷新，clangd 大文件上会明显卡顿。
      -- 现在 cl = 只查引用（最常用、最轻），完整聚合模式挪到 cL 备用。
      { "<leader>cl", "<cmd>Trouble lsp_references toggle focus=false win.position=right<cr>", desc = "LSP 引用面板" },
      { "<leader>cL", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP 汇总面板（全部，较慢）" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "位置列表面板" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "quickfix 面板" },
    },
    opts = {},
  },
}

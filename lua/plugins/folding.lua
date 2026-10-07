-- 折叠（原 coding/nixvim/ufo.nix）
-- 变化点：setupLspCapabilities 移到了 lsp.lua 的 vim.lsp.config("*") 中
--
-- 说明：options.lua 里曾经设置过 foldmethod=expr + foldexpr=v:lua.vim.ufo.foldexpr()，
-- 但 nvim-ufo 并不提供 vim.ufo（源码里没有 foldexpr），那会导致每次算折叠都报 E5108。
-- 现已删除，折叠完全交给 ufo 自己接管，因此这里可以继续懒加载。
return {
  {
    "kevinhwang91/nvim-ufo",
    event = "VeryLazy",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "Comment" })
        return newVirtText
      end,
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
      preview = {
        mappings = {
          scrollU = "<C-u>",
          scrollD = "<C-d>",
          jumpTop = "[",
          jumpBot = "]",
        },
      },
    },
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "打开全部折叠",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "折叠全部代码",
      },
      {
        "K",
        function()
          local winid = require("ufo").peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover()
          end
        end,
        desc = "查看折叠/悬浮文档",
      },
    },
  },
}

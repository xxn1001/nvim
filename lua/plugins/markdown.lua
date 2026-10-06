-- Markdown 相关
return {
  -- 浏览器预览（首次使用前需 :MarkdownPreviewInstall）
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = function()
      pcall(function()
        vim.fn["mkdp#util#install"]()
      end)
    end,
  },

  -- 渲染（标题/表格/代码块等）
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
    opts = {
      file_types = { "markdown", "codecompanion" },
      latex = {
        enabled = true,
        converter = "latex2text",
      },
      win_options = {
        conceallevel = { rendered = 2 },
      },
    },
  },
}

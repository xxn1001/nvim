-- 编辑体验类小插件
return {
  -- 缩进探测（不需要懒加载，越早生效越好）
  { "tpope/vim-sleuth", lazy = false },

  -- 括号包围 / 环绕
  {
    "kylechui/nvim-surround",
    keys = { "cs", "ds", "ys" },
    opts = {},
  },

  -- 让 . 可以重复插件的操作
  { "tpope/vim-repeat", lazy = false },

  -- 打开文件时恢复上次光标位置
  { "farmergreg/vim-lastplace", event = { "BufReadPost" } },

  -- 自动配对括号
  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    opts = {},
  },

  -- if/end 之类的自动补全
  { "tpope/vim-endwise", event = { "InsertEnter" } },

  -- HTML/JSX 标签自动重命名
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "vue", "tsx", "svelte", "astro" },
    -- 注意：1.0 之后选项改成 setup({ opts = {...} }) 的新布局，
    -- 旧的扁平写法会告警 "Using the legacy setup opts!"
    opts = {
      opts = {
        enable_close = false,
        enable_close_on_slash = false,
        enable_rename = true,
      },
    },
  },
}

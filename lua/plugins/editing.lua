-- 编辑体验类小插件
return {
  -- 缩进探测（不需要懒加载，越早生效越好）
  { "tpope/vim-sleuth", lazy = false },

  -- 括号包围 / 环绕（普通模式 + 可视模式都要懒加载触发！）
  --
  -- 【修复】原来只写了 keys = { "cs", "ds", "ys" }，而 lazy.nvim 对「字符串形式的键位」
  -- 只在**普通模式**注册触发（core/handler/keys.lua 里 `value.mode = value.mode or "n"`），
  -- 于是可视模式下按 S / gS 时插件根本没被加载；而 flash.nvim 又把可视模式的 S 占作了
  -- treesitter 搜索，结果按 S 会进入 flash 搜索、选区包不上括号。
  -- 现在可视模式的 S / gS 单独用 mode = "x" 声明为触发键，这样：
  --   普通模式：ys / yss / yS / cs / ds（surround 默认键）
  --   可视模式：S 包裹选区、gS 换行包裹（surround 默认键，x 覆盖字符/行/块三种可视）
  -- 注意：这让可视模式的 S 从 flash 手里回到 surround（见 README「已知取舍」）。
  {
    "kylechui/nvim-surround",
    keys = {
      -- 普通模式：surround 默认键（ys/yss/yS/cs/ds）
      "ys",
      "yss",
      "yS",
      "cs",
      "ds",
      -- 可视模式：S = 包裹选区，gS = 换行包裹选区
      -- （mode = "x" 覆盖字符可视 v / 行可视 V / 块可视 <C-v>）
      --
      -- 注意：每个键必须单独写一个 table！lazy.nvim 解析 keys 时只把 value[1] 当 lhs、
      -- value[2] 当 rhs（core/handler/keys.lua 的 M.parse），所以 { "S", "gS", mode = "x" }
      -- 会被理解成「lhs=S，rhs=gS」这一把键，gS 会静默失效（踩过）。
      { "S", mode = "x", desc = "包裹选中文本（surround）" },
      { "gS", mode = "x", desc = "换行包裹选中文本（surround）" },
    },
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

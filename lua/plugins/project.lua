-- 项目切换（原 coding/nixvim/project.nix + ui.nix 的 <leader>fp）
-- 注意：<leader>fp 依赖 telescope 加载 "projects" 扩展，扩展已由 telescope.lua 注册
return {
  {
    "ahmedkhalf/project.nvim",
    cmd = { "Project" },
    keys = {
      { "<leader>fp", "<CMD>Telescope projects layout_config={height=0.6,width=0.6}<CR>", desc = "切换项目" },
    },
    -- 模块名是 project_nvim（lazy 按仓库名推断的 "project" 不存在），显式 config
    config = function()
      require("project_nvim").setup {}
    end,
  },
}

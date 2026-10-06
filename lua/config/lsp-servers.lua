-- LSP 服务器清单（数据表驱动）
--
-- 想增删服务器：只改这个文件。
--   * enabled  : 需要启用（并由 mason 自动安装）的 nvim-lspconfig 服务器名
--   * overrides: 需要覆盖默认配置的服务器（默认值来自 nvim-lspconfig 的 lsp/*.lua）
--
-- 逻辑部分见 lua/config/lsp.lua，插件声明见 lua/plugins/lsp.lua。

local M = {}

--- 启用的服务器（名字必须是 nvim-lspconfig 的服务器名，不是 mason 包名）
---@type string[]
M.enabled = {
  "clangd",
  "rust_analyzer",
  "basedpyright",
  "lua_ls",
  "gopls",
  "yamlls",
  "cmake",
  "bashls",
  "ts_ls",
  "ruff",
  "html",
  "cssls",
  "tailwindcss",
  "emmet_language_server",
  "eslint",
  "tinymist",
  "jsonls",
  "taplo",
  "marksman",
  "qmlls",
  "harper_ls",
}

--- 覆盖 nvim-lspconfig 的默认配置
---@type table<string, vim.lsp.Config>
M.overrides = {
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--completion-style=detailed",
      "--header-insertion=iwyu",
      "--function-arg-placeholders=false",
    },
  },

  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        check = { command = "clippy" },
        checkOnSave = true,
        inlayHints = {
          typeHints = true,
          parameterHints = true,
          chainingHints = true,
        },
      },
    },
  },

  basedpyright = {
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = "standard",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly",
        },
      },
    },
  },

  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        hint = { enable = false },
      },
    },
  },

  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        analyses = {
          unusedparams = true,
          unreachable = true,
          unusedvariable = true,
        },
        staticcheck = true,
      },
    },
  },

  yamlls = {
    settings = {
      yaml = {
        schemas = {
          ["https://json.schemastore.org/github-workflow"] = ".github/workflows/*",
          ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
            "docker-compose.{yml,yaml}",
            "*compose*.{yml,yaml}",
          },
        },
      },
    },
  },
}

return M

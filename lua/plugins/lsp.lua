return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = { "vtsls", "rescriptls" },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      local function find_local_bin(bufnr, bin)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        if filename == "" then
          return nil
        end

        return vim.fs.find("node_modules/.bin/" .. bin, {
          path = vim.fs.dirname(filename),
          upward = true,
          type = "file",
          limit = 1,
        })[1]
      end

      local function jump_to_mouse_definition()
        local pos = vim.fn.getmousepos()

        if pos.winid and pos.winid ~= 0 then
          vim.api.nvim_set_current_win(pos.winid)
          vim.api.nvim_win_set_cursor(0, { pos.line, math.max(pos.column - 1, 0) })
        end

        vim.lsp.buf.definition()
      end

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

      vim.diagnostic.config({
        float = { border = "rounded" },
        severity_sort = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        virtual_text = true,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gr", vim.lsp.buf.references, "References")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "<C-LeftMouse>", jump_to_mouse_definition, "Go to definition")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        end,
      })

      vim.lsp.config("vtsls", {
        settings = {
          vtsls = {
            autoUseWorkspaceTsdk = true,
          },
        },
      })

      vim.lsp.config("rescriptls", {
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        },
      })

      vim.lsp.config("oxlint", {
        cmd = function(dispatchers, config)
          local local_cmd = config and config.root_dir
            and vim.fs.find("node_modules/.bin/oxlint", {
              path = config.root_dir,
              upward = true,
              type = "file",
              limit = 1,
            })[1]

          if not local_cmd then
            return nil
          end

          return vim.lsp.rpc.start({ local_cmd, "--lsp" }, dispatchers)
        end,
        root_dir = function(bufnr, on_dir)
          if not find_local_bin(bufnr, "oxlint") then
            return
          end

          local root = vim.fs.root(bufnr, { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" })
          if root then
            on_dir(root)
          end
        end,
      })

      vim.lsp.enable("vtsls")
      vim.lsp.enable("rescriptls")
      vim.lsp.enable("oxlint")
    end,
  },
}
